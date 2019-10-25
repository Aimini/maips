`ifndef STAGE_EXECUTE__
`define STAGE_EXECUTE__

`include "src/pipeline/pipeline_interface.sv"
`include "src/pipeline/pipeline_base.sv"
`include "src/pipeline/stage_execute_partial/alu_source_mux.sv"
`include "src/pipeline/stage_execute_partial/register_partial_data_mux.sv"
`include "src/pipeline/stage_execute_partial/compare_flag_mux.sv"
`include "src/pipeline/stage_execute_partial/dest_reg_mux.sv"
`include "src/pipeline/stage_execute_partial/multiply_div_wrapper.sv"
`include "src/alu/alu.sv"
`include "src/alu/alu_logic/alu_logic_special3.sv"
`include "src/alu/div_mul/div_mul.sv"
`include "src/common/util.sv"
`include "src/pipeline/forward/main_forwarder.sv"
`include "src/memory/cop0/cop0_write_filter.sv"

module stage_execute(pipeline_interface.port pif,
input forward_info_t forward, output logic wait_result,
input logic using_delay_slot,
input logic llbit); //forward

    logic[31:0] alu_a,alu_b;
    logic[4:0] alu_sa; 
    logic[31:0] sign_immed;

    signals::flag_t alu_flag;  
    signals::unpack_t unpack;
    selector::register_source reg_src;

    logic[31:0] dest_reg_data,alu_out,special3_out;
    logic flag_selected;
    logic write_reg_selected;

    logic[4:0] dest_reg;
    pipeline_signal_t p_out;
    signals::control_t p_ctl;

    logic[31:0] dest_cop0_data;

    extract_instruction unit_ei(p_out.instruction, unpack);

    sign_extend #(.NI(16),.NO(32)) 
    unit_sign_extend(.i(unpack.immed), .o(sign_immed));

 /************************* cop0 write filter **********************/
    cop0_write_filter unit_cop0_write_filter(
    .rd(p_out.dest_cop0_rd),.sel(p_out.dest_cop0_sel),
    .din(p_out.rt),.dout(dest_cop0_data));

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
    multiply_div_wrapper  unit_div_mul(
          .clk(pif.clk),          .reset(pif.reset),
        .clear(pif.bubble), .hold_result(pif.stall),
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
        .flag(flag_selected),.llbit(llbit),

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


    assign reconnect.signal_in = pif.signal_in;
    assign reconnect.stall     = pif.stall;
    assign reconnect.bubble    = pif.bubble;
    assign reconnect.nullify   = pif.nullify;

    always_comb begin
        pif.signal_out = reconnect.signal_out;    
        process_forward_data(pif.signal_out, forward);

        pif.signal_out.flag = alu_flag;
        pif.signal_out.dest_reg_data  = dest_reg_data;
        pif.signal_out.dest_cop0_data  = dest_cop0_data;
        pif.signal_out.alu_out   = alu_out;
        pif.signal_out.dest_reg  = dest_reg;
        pif.signal_out.flag_selected = flag_selected;
        pif.signal_out.pc_branch  = p_out.pcadd4 + (sign_immed << 2);
        pif.signal_out.mem_addr   = p_out.rs     + sign_immed;
        pif.signal_out.control.write_reg = write_reg_selected;
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
    end
    
    /** write signal select**/
    always_comb begin
        case(p_out.control.write_cond)
            selector::REG_WRITE_WHEN_FLAG:  write_reg_selected = flag_selected;
            selector::REG_WRITE_WHEN_LLBIT: write_reg_selected = llbit;
            selector::REG_WRITE_ALWAYS: write_reg_selected = reconnect.signal_out.control.write_reg;
            default:
                write_reg_selected = 'x;
        endcase
    end
    
    assign p_out = pif.signal_out;
    assign p_ctl = p_out.control;
endmodule


`endif

