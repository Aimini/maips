`ifndef ALU_LOGIC_CLZ__
`define ALU_LOGIC_CLZ__


module alu_logic_clz #(parameter N = 32)
(input logic[N - 1:0] a,
output logic[$clog2(N):0] y, //should be log2(N) ,but I not found
output logic all_zero);
    logic single;
    logic [$clog2(N/2): 0] high_clz;
    logic [$clog2(N/2): 0]  low_clz;
    logic high_all_zero,low_all_zero;
    generate 
        if(N == 1) begin
            assign y = ~a;
            assign all_zero = ~a;
        end else begin
            if(N%2 == 1) begin
                assign msb_zero = ~a[N - 1];
                alu_logic_clz   #(N/2) high(a[N - 2:N/2],high_clz,high_all_zero);
                alu_logic_clz   #(N/2)  low(a[N/2 - 1:0], low_clz, low_all_zero);
                assign y = msb_zero ? (1 + (high_all_zero ? (high_clz + low_clz) : high_clz)) : 0;
                assign all_zero = msb_zero & high_all_zero & low_all_zero;
            end else begin
                alu_logic_clz   #(N/2) high(a[N - 1:N/2],high_clz,high_all_zero);
                alu_logic_clz   #(N/2)  low(a[N/2 - 1:0], low_clz, low_all_zero);
                assign y = high_all_zero ? (high_clz + low_clz) : high_clz;
                assign all_zero =  high_all_zero & low_all_zero;
            end
        end
    endgenerate
endmodule

`endif