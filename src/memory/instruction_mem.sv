module instruction_mem # (parameter addr_wdith = 10,parameter width = 32)
(input logic[addr_wdith - 1:0] addr,
output logic[width - 1:0] dout);
    logic[width - 1:0] im[2**addr_wdith - 1:0];
    assign dout = im[addr];


endmodule