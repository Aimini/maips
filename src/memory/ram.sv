/* 
 N is address line , M is bits width;
*/
module ram #(parameter  N = 10, M = 32)
(input logic clk,
input logic we,
input logic[N-1:0] addr,
input logic[M-1:0] din,
output logic[M-1:0] dout);

    logic[M-1:0] datas[2**N-1:0];
    always_ff @(posedge clk)
        if(we) datas[addr] <= din;

    assign dout = datas[addr];
endmodule