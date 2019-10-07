`ifndef STAGE_EXECUTE__
`define STAGE_EXECUTE__

`include "src/pipeline/pipeline_interface.sv"
`include "src/pipeline/pipeline_base.sv"
`include "src/pipeline/stage_execute_partial/alu_source_mux.sv"
`include "src/pipeline/stage_execute_partial/register_partial_data_mux.sv"
`include "src/pipeline/stage_execute_partial/compare_flag_mux.sv"
`include "src/pipeline/stage_execute_partial/dest_reg_mux.sv"
`include "src/alu/alu.sv"
`include "src/common/util.sv"
`include "src/common/sign_extend.sv"

module stage_execute(pipeline_interface.port pif,
input logic[31:0] hi,lo, //forward
input logic llbit); //forward

    logic[31:0] alu_a,alu_b;
    logic[4:0] alu_sa; 
    logic[15:0] immed;
    selector::alu_sourceA src_a;
    selector::alu_sourceB src_b;
    signals::flag_t alu_flag;  
    signals::unpack_t unpack;

    selector::flag_select   fs;
    selector::register_source reg_src;
    logic[31:0] pcadd4,cp0,rs_data,rt_data;/*,rs,hi,lo,cp0;*/
    logic[31:0] dest_reg_data,alu_out;
    logic flag;//,llbit;
    
    selector::destnation_regiter dest_reg_select;
    logic[4:0] dest_reg;


    extract_instruction uint_ei(pif.signal_out.instruction, unpack);

    alu #(32) uint_alu(.a(alu_a),.b(alu_b),.sa(alu_sa),
    .funct(pif.signal_out.control.alu_funct),
    .y(alu_out),
    .flag(alu_flag));


    alu_source_mux unit_alu_src_mux( 
        .src_a(src_a),.src_b(src_b),
        .rs(rs_data),.rt(rt_data),.immed(immed),
        .a(alu_a),.b(alu_b));

    register_partial_data_mux unit_reg_partial_data_mux(
        .reg_src(reg_src),
        .alu_out(alu_out),.pcadd4(pcadd4),.rs(rs_data),
        .hi(hi),.lo(lo),.cp0(cp0),
        .flag(flag),.llbit(llbit),
        .data(dest_reg_data));

    compare_flag_mux unit_cmp_flag_mux(
        .select(fs), .f(alu_flag.compare),.o(flag));

    dest_reg_mux unit_dest_reg_mux(.select(dest_reg_select),
        .rd(unpack.rd), .rt(unpack.rt),
        .dest_reg(dest_reg));

    pipeline_interface reconnect(.clk(pif.clk),.reset(pif.reset));
    pipeline_base unit_pb(reconnect);

    always_comb begin
        reconnect.signal_in = pif.signal_in;
        reconnect.nullify = pif.nullify;
        reconnect.stall = pif.stall;

        pif.signal_out = reconnect.signal_out;
        pif.signal_out.flag = alu_flag;
        pif.signal_out.dest_reg_data = dest_reg_data;
        pif.signal_out.alu_out = alu_out;
        pif.signal_out.dest_reg = dest_reg;

        fs    =  pif.signal_out.control.flag_sel;
        src_a =  pif.signal_out.control.alu_srcA;
        src_b =  pif.signal_out.control.alu_srcB;
        reg_src = pif.signal_out.control.reg_src;
        dest_reg_select = pif.signal_out.control.dest_reg;
        alu_sa = unpack.sa;
        
        rs_data    =  pif.signal_out.rs;
        rt_data    =  pif.signal_out.rt;
        pcadd4 = pif.signal_out.pcadd4;
        cp0    = pif.signal_out.cp0;

        immed =  unpack.immed;
    end

endmodule


`endif

