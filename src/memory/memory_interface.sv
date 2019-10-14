`ifndef MEMORY_INTERFACE__
`define MEMORY_INTERFACE__

interface memory_interface #(parameter N = 32);
	localparam NN = $clog2(N);
    logic[N-1:0]  din,dout;
    logic[N-1:0] addr;
    logic[NN - 1:0] mask;
    logic write;
    logic busy;

    modport  read_only_controller (input dout, busy,
                        output addr);
    modport  controller (input dout, busy,
                        output din, mask, addr, write);
    modport memory(input din, mask, addr, write,
                  output  dout, busy);

   modport  simple_memory(input din, addr, write, output dout);
endinterface: memory_interface

`endif