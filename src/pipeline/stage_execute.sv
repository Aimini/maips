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

module stage_execute(pipeline_interface.port pif,
input forward_info_t forward, output logic wait_result,
input logic llbit); //forward

    logic[31:0] alu_a,alu_b;
    logic[4:0] alu_sa; 
    logic[15:0] immed;
    logic[31:0] sign_immed;

    selector::alu_sourceA src_a;
    selector::alu_sourceB src_b;
    signals::flag_t alu_flag;  
    signals::unpack_t unpack;
    signals::control_t ctl;
    selector::flag_select   flag_sel;
    selector::register_source reg_src;
    logic[31:0] pcadd4,cp0,rs_data,rt_data;
    logic[31:0] hi_data,lo_data;//forwarded result
    logic[31:0] dest_reg_data,alu_out,special3_out;
    logic flag_selected;//
    logic write_reg_selected;
    selector::destnation_regiter dest_reg_select;
    logic[4:0] dest_reg;
    pipeline_signal_t p_out;
    signals::control_t p_ctl;

    /** div mul module  signal **/
    logic[31:0] hi_out_mul_div,lo_out_mul_div;
    logic write_hi_lo_mul_div;
    extract_instruction unit_ei(p_out.instruction, unpack);

    sign_extend #(.NI(16),.NO(32)) 
    unit_sign_extend(.i(immed),.o(sign_immed));

    alu #(32) unit_alu(.a(alu_a),.b(alu_b),.sa(alu_sa),
    .funct(p_out.control.alu_funct),
    .y(alu_out),
    .flag(alu_flag));

    alu_logic_special3 unit_special3(.a(alu_a),.b(alu_b),
    .msbd(unpack.rd),.lsb(unpack.sa),
    .y(special3_out),
    .funct(p_out.control.alu_funct));

    multiply_div_wrapper  unit_div_mul(
        .clk(pif.clk),          .reset(pif.reset),
        .clear(pif.bubble),     .hold_result(pif.stall),
        .muldiv_funct(p_out.control.muldiv_funct),
        .rs(rs_data),           .rt(rt_data),
        .hi_in(hi_data),        .lo_in(lo_data),
        .hi_out(hi_out_mul_div),.lo_out(lo_out_mul_div),
        .wait_result(wait_result));

    alu_source_mux unit_alu_src_mux( 
        .src_a(src_a),.src_b(src_b),
        .rs(rs_data),.rt(rt_data),.immed(immed),
        .a(alu_a),.b(alu_b));

    register_partial_data_mux unit_reg_partial_data_mux(
        .reg_src(reg_src),
        .alu_out(alu_out),.pcadd4(pcadd4),.rs(rs_data),
        .hi(hi_data),.lo(lo_data),.cp0(cp0),
        .mul_div_lo(lo_out_mul_div),.special3(special3_out),
        .flag(flag_selected),.llbit(llbit),
        .data(dest_reg_data));

    compare_flag_mux unit_cmp_flag_mux(
        .select(flag_sel), .f(alu_flag.compare),.o(flag_selected));

    dest_reg_mux unit_dest_reg_mux(.select(dest_reg_select),
        .rd(unpack.rd), .rt(unpack.rt),
        .dest_reg(dest_reg));

    pipeline_interface reconnect(.clk(pif.clk),.reset(pif.reset));
    pipeline_base unit_pb(.pif(reconnect),.nullify_instruction('0));


    assign reconnect.signal_in = pif.signal_in;
    assign reconnect.stall = pif.stall;
    assign reconnect.bubble = pif.bubble;
    assign reconnect.nullify =  pif.nullify;

    always_comb begin
        pif.signal_out = reconnect.signal_out;    
        pif.signal_out.rs = rs_data;
        pif.signal_out.rt = rt_data;
        pif.signal_out.hi = hi_data;
        pif.signal_out.lo = lo_data;
        pif.signal_out.flag = alu_flag;
        pif.signal_out.dest_reg_data = dest_reg_data;
        pif.signal_out.alu_out = alu_out;
        pif.signal_out.dest_reg = dest_reg;
        pif.signal_out.flag_selected = flag_selected;
        pif.signal_out.pc_branch = pif.signal_out.pcadd4 + (sign_immed << 2);
        pif.signal_out.mem_addr = rs_data + sign_immed;
        pif.signal_out.control.write_reg = write_reg_selected;

        case(pif.signal_out.control.hilo_src)
            selector::HILO_SRC_RS: begin
                pif.signal_out.dest_hi_data = rs_data;
                pif.signal_out.dest_lo_data = rs_data;
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
    
    always_comb begin
        case(p_out.control.write_cond)
            selector::REG_WRITE_WHEN_FLAG:  write_reg_selected = flag_selected;
            selector::REG_WRITE_WHEN_LLBIT: write_reg_selected = llbit;
            default:      
                write_reg_selected = '1;
        endcase
    end
    
    always_comb begin
        case(p_out.control.alu_srcSa)
            selector::ALU_SRCSA_SA: alu_sa = unpack.sa;
            selector::ALU_SRCSA_RS: alu_sa = rs_data[4:0];
            default:      
                alu_sa = 'x;
        endcase
    end

    assign p_out = pif.signal_out;
    assign p_ctl = p_out.control;

    assign rs_data = forward.rs.f ? forward.rs.data : reconnect.signal_out.rs;
    assign rt_data = forward.rt.f ? forward.rt.data : reconnect.signal_out.rt;
    assign hi_data = forward.hi.f ? forward.hi.data : reconnect.signal_out.hi;
    assign lo_data = forward.lo.f ? forward.lo.data : reconnect.signal_out.lo;
    
    assign flag_sel        = p_ctl.flag_sel;
    assign src_a           = p_ctl.alu_srcA;
    assign src_b           = p_ctl.alu_srcB;
    assign reg_src         = p_ctl.reg_src;
    assign dest_reg_select = p_ctl.dest_reg;

    assign pcadd4 = p_out.pcadd4;
    assign cp0    = p_out.cp0;
    assign immed  = unpack.immed;

endmodule


`endif

