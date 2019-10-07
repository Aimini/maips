`ifndef TOP__
`define TOP__
`include "src/core.sv"
`include "src/memory/uniform_memory.sv"
`include "src/memory/uniform_memory.sv"

module top(input logic clk,reset);

    memory_interface ins_mif(),data_mif();
    uniform_memory unit_memory(.clk(clk),.status_erl(1'b0),
        .ins_i(ins_mif), .data_i(data_mif));

    core unit_core(.clk(clk),.reset(reset),
        .ins_mif(ins_mif), .data_mif(data_mif));

endmodule

`endif