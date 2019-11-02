`ifndef MEMORY_INTERFACE__
`define MEMORY_INTERFACE__

interface memory_interface #(parameter DN = 32,AN = 32);
	localparam DWIDTH = (DN + 7)/ 8;
    logic[DN-1:0]  din,dout;
    logic[AN-1:0] addr;
    logic[DWIDTH - 1:0] mask;
    logic write;
    logic read;
    logic busy;

    modport  rom_controller (input dout, busy,
                        output addr,read);
                        
    modport  controller (input dout, busy,
                        output din, mask, addr,read, write);

    modport memory(input din, mask, addr, read, write,
                  output  dout, busy);
    modport rom(input  addr, read,
                  output  dout, busy);
   modport  simple_memory(input din, addr, write, output dout);
endinterface: memory_interface

`endif