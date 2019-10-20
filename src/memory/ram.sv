/* 
 N is address line , M is bits width;
*/
`include "src/memory/memory_interface.sv"
module ram #(parameter  N = 10, M = 32)
(input logic clk, memory_interface.memory mif);
    localparam NN = (M + 7)/8;
    logic[M-1:0] datas[2**N-1:0];
    logic[8*NN-1:0] bit_mask;
    always_comb begin
        for(int i = 0; i < NN; ++i)
            bit_mask[8*i +:8] = {8{mif.mask[i]}};
    end
    always_ff @(posedge clk)
        if(mif.write) 
            datas[mif.addr] <= mif.din & bit_mask | ~bit_mask & datas[mif.addr];

    assign mif.dout = datas[mif.addr];
    assign mif.busy = 0;
endmodule