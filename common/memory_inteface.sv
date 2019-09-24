interface memory_interface #(parameter N = 32)
   (input logic clk);
	localparam NN = $clog2(N);
    logic[N-1:0]  din,dout;
    logic[N-1:0] addr;
    logic[NN - 1:0] mask;
    logic write;

    modport  controller (input dout,  
                         output din, addr, mask, write);

    modport  memory(input  clk, dout, addr, mask, write,
                    output din);
endinterface: memory_interface