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
// dest cop0 from decoder
input selector::destnation_cop0 dest_cop0_in,
input logic exception_happen,
input logic decoder_write,
input logic[31:0] status, rt,
output logic write,
output selector::destnation_cop0  dest_cop0,
output logic[31:0] y);

    selector::cop0_source exc_src;
    always_comb begin : modify_status
        dest_cop0 = dest_cop0_in;
        exc_src = src;
        write = decoder_write;
        if(exception_happen) begin
            exc_src = selector::COP0_SRC_STATUS_EXL;
            dest_cop0 = selector::DEST_COP0_STATUS;
            write = '1;
        end
    end

    logic[31:0] rt_out;
    cop0_write_filter unit_cop0_write_filter(
    .rd(rd),.sel(sel),
    .din(rt),.dout(rt_out));

    cop0_mux unit_cop0_mux(.src(exc_src),
        .status(status),.rt(rt_out),.y(y));
endmodule
`endif
