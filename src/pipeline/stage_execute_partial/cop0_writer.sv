`ifndef __COP0_WRITER__
`define __COP0_WRITER__

`include "src/pipeline/stage_execute_partial/cop0_mux.sv"
`include "src/memory/cop0/cop0_write_filter.sv"
/*
    WHY:
    1. cpu only write CP0 when execute mtc0,  when we 
    execute other instruction, the pipeline of write cop0 
    is idle. therefore, we can use it to write Status when
    exception  happen.

    WHY Status:
    1. for other register like cause, EPC, alougth we write it
    implicity in exception happened, by the pipline is also be
    cleared from fetch to execute, so in the pipline we don't need
    to foward these register. but interrupt won't affected by clear,
    it's always check ERL,EXE,IE in Status register in stage execute.    
*/
module cop0_writer(input selector::cop0_source src,
input logic[4:0] rd,input logic[2:0] sel,
input logic[31:0] status, rt, mem_addr,
output logic[31:0] y);
    logic[31:0] rt_out;
    cop0_write_filter unit_cop0_write_filter(
    .rd(rd),.sel(sel),
    .din(rt),.dout(rt_out));

    cop0_mux unit_cop0_mux(.src(src),
        .status(status),.rt(rt_out),.mem_addr(mem_addr),.y(y));
endmodule
`endif
