`ifndef STAGE_EXECUTE__
`define STAGE_EXECUTE__

`include "src/pipeline/pipeline_interface.sv"
`include "src/pipeline/pipeline_base.sv"
`include "src/pipeline/stage_execute_partial/alu_source_mux.sv"
`include "src/pipeline/stage_execute_partial/register_partial_data_mux.sv"
`include "src/pipeline/stage_execute_partial/compare_flag_mux.sv"
`include "src/pipeline/stage_execute_partial/dest_reg_mux.sv"
`include "src/pipeline/stage_execute_partial/multiply_div_wrapper.sv"
`include "src/pipeline/stage_execute_partial/cop0_writer.sv"
`include "src/alu/alu.sv"
`include "src/alu/alu_logic/alu_logic_special3.sv"
`include "src/alu/div_mul/div_mul.sv"
`include "src/common/util.sv"
`include "src/pipeline/forward/main_forwarder.sv"

module stage_execute(pipeline_interface.port pif,
input forward_info_t forward, 
input bit_replace_info_t replace,
input logic using_delay_slot,
output logic wait_result); //forward

    logic[31:0] alu_a,alu_b;
    logic[4:0] alu_sa; 
    logic[31:0] sign_immed;

    signals::flag_t alu_flag;  
    signals::unpack_t unpack;
    selector::register_source reg_src;

    logic[31:0] dest_reg_data,alu_out,special3_out;
    logic flag_selected;

    logic[4:0] dest_reg;
    pipeline_signal_t p_out;
    signals::control_t p_ctl;

    logic[31:0] dest_cop0_data;
    extract_instruction unit_ei(p_out.instruction, unpack);

    sign_extend #(.NI(16),.NO(32)) 
    unit_sign_extend(.i(unpack.immed), .o(sign_immed));

    /************************* cop0 write filter **********************/
    cop0_writer unit_cop0_writer(.src(p_ctl.cop0_src),
    .rd(p_out.dest_cop0_rd),.sel(p_out.dest_cop0_sel),
    .rt(p_out.rt) ,.status(p_out.cop0_excreg.Status),.mem_addr(p_out.mem_addr),
    .y(dest_cop0_data));


/********************************* alu  **************************/
    alu #(32) unit_alu(.a(alu_a),.b(alu_b),.sa(unpack.sa),.rs(p_out.rs),
    .funct(p_ctl.alu_funct),.sa_src(p_ctl.alu_srcSa),
    .y(alu_out),
    .flag(alu_flag));

    alu_logic_special3 unit_special3(.a(alu_a),.b(alu_b),
    .msbd(unpack.rd),.lsb(unpack.sa),
    .y(special3_out),
    .funct(p_out.control.alu_funct));


    /** div mul module  signal **/
    logic[31:0] hi_out_mul_div,lo_out_mul_div;
    logic clear_mul_div;
    assign clear_mul_div =  pif.bubble | pif.nullify;
    multiply_div_wrapper  unit_div_mul(
          .clk(pif.clk),            .reset(pif.reset),
        .clear(clear_mul_div),.hold_result(pif.stall),
        .muldiv_funct(p_ctl.muldiv_funct),
           .rs(p_out.rs),       .rt(p_out.rt),
        .hi_in(p_out.hi),    .lo_in(p_out.lo),
        // output ---------------
        .hi_out(hi_out_mul_div),
        .lo_out(lo_out_mul_div),
        .wait_result(wait_result));


    alu_source_mux unit_alu_src_mux( 
        .src_a(p_ctl.alu_srcA),.src_b(p_ctl.alu_srcB),
           .rs(p_out.rs),         .rt(p_out.rt),  
        .immed(unpack.immed),
        .a(alu_a),.b(alu_b));

    /****************** select data than write back to gpr *******************/
    register_partial_data_mux unit_reg_partial_data_mux(
        //-------- control
        .reg_src(p_ctl.reg_src),
        .using_delay_slot(using_delay_slot),

        //----------- mux input
        .alu_out(alu_out),
        .pcadd4(p_out.pcadd4),.pcadd8(p_out.pcadd8),
            .rs(p_out.rs),        .hi(p_out.hi),
            .lo(p_out.lo),       .cop0(p_out.cop0),
        .mul_div_lo(lo_out_mul_div),
        .special3(special3_out),
        .flag(flag_selected),.llbit(p_out.llbit),

        //----------- output 
        .data(dest_reg_data));

    compare_flag_mux unit_cmp_flag_mux(
        .select(p_ctl.flag_sel), .f(alu_flag.compare), .o(flag_selected));

    dest_reg_mux unit_dest_reg_mux(
        //-------- control
        .select(p_ctl.dest_reg),
        //----------- mux input
        .rd(unpack.rd), .rt(unpack.rt),
        //----------- output 
        .dest_reg(dest_reg));

    pipeline_interface reconnect(.clk(pif.clk),.reset(pif.reset));
    pipeline_base unit_pb(.pif(reconnect),.nullify_instruction('0));


    `COPY_PIPELINE_BASE(assign,pif,reconnect);

    always_comb begin
        pif.signal_out = reconnect.signal_out;    
        process_forward_data(pif.signal_out, forward);
        process_bit_replace(pif.signal_out,replace);
        pif.signal_out.flag = alu_flag;
        pif.signal_out.dest_reg_data  = dest_reg_data;
        pif.signal_out.dest_cop0_data = dest_cop0_data;
        pif.signal_out.alu_out   = alu_out;
        pif.signal_out.dest_reg  = dest_reg;
        pif.signal_out.flag_selected = flag_selected;

        pif.signal_out.pc_branch  = p_out.pcadd4 + (sign_immed << 2);
        pif.signal_out.mem_addr   = p_out.rs     + sign_immed;


        case(pif.signal_out.control.hilo_src)
            selector::HILO_SRC_RS: begin
                pif.signal_out.dest_hi_data = p_out.rs;
                pif.signal_out.dest_lo_data = p_out.rs;
            end
            selector::HILO_SRC_MULDIV:  begin
                pif.signal_out.dest_hi_data = hi_out_mul_div;
                pif.signal_out.dest_lo_data = lo_out_mul_div;
            end
            default: begin
                pif.signal_out.dest_hi_data = 'x;
                pif.signal_out.dest_lo_data = 'x;
            end
        endcase
  
        set_write_reg(
            .write_reg    (pif.signal_out.control.write_reg),
            .flag_selected(flag_selected),
            .cond         (pif.signal_out.control.write_cond));

        set_rd_sel(
            .rd  (pif.signal_out.dest_cop0_rd),
            .sel (pif.signal_out.dest_cop0_sel),
            .dest(pif.signal_out.control.dest_cop0));

        set_write_mem( 
            .write_mem(pif.signal_out.control.write_mem),
            .llbit    (pif.signal_out.llbit),
            .cond     (pif.signal_out.control.mem_write_cond));
    end


    function automatic void set_rd_sel(ref logic[4:0] rd, ref logic[2:0] sel,input selector::destnation_cop0 dest);
    `ifndef _SE_SET_RD_SEL
    `define _SE_SET_RD_SEL(_RD, _SEL) \
        begin                     \
            rd  = _RD;            \
            sel = _SEL;           \
        end   
    `endif

    case(pif.signal_out.control.dest_cop0)
        selector::DEST_COP0_RDSEL: ;
        selector::DEST_COP0_STATUS:`_SE_SET_RD_SEL(cop0_info::RD_STATUS,cop0_info::SEL_STATUS)
        selector::DEST_COP0_LLADDR:`_SE_SET_RD_SEL(cop0_info::RD_LLADDR,cop0_info::SEL_LLADDR)
        default:                   `_SE_SET_RD_SEL('x,'x)
    endcase
    `undef _SE_SET_RD_SEL
    endfunction

    function automatic void set_write_mem(ref logic write_mem, input logic llbit,input selector::mem_write_condition cond);
    `ifndef _SE_SET_WRITE_MEM
    `define _SE_SET_WRITE_MEM(_C,_R)  \
        selector:: _C : begin         \
            write_mem = _R;           \
        end   
    `endif

    case(cond)
        `_SE_SET_WRITE_MEM(MEM_WRITE_ALWAYS,        '1)
        `_SE_SET_WRITE_MEM(MEM_WRITE_WHEN_LLBIT, llbit)
        `_SE_SET_WRITE_MEM(MEM_WRITE_KEEP,          '0)
        default: write_mem  = '0;
    endcase
    `undef _SE_SET_WRITE_MEM
    endfunction

    function automatic void set_write_reg(ref logic write_reg, input logic flag_selected, input selector::write_register_condition cond);
        case(cond)
            selector::REG_WRITE_WHEN_FLAG: write_reg = flag_selected;
            selector::REG_WRITE_ALWAYS:;
            default: write_reg  = 'x;
        endcase
    endfunction
    
    assign p_out = pif.signal_out;
    assign p_ctl = p_out.control;
endmodule


`endif

