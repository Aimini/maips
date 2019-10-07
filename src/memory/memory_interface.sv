`ifndef MEMORY_INTERFACE__
`define MEMORY_INTERFACE__

interface memory_interface #(parameter N = 32);
	localparam NN = $clog2(N);
    logic[N-1:0]  din,dout;
    logic[N-1:0] addr;
    logic[NN - 1:0] mask;
    logic write;
    logic busy;
    modport  controller (input dout,  
                         output din, addr, mask, write, busy);

    modport  memory(input  dout, addr, mask, write, busy,
                    output din);
endinterface: memory_interface

`endif