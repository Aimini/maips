`ifndef ALU_ARITHMATIC__
`define ALU_ARITHMATIC__

module alu_arithmatic #(parameter N = 32)
(input logic[N - 1:0] a,b, 
 input logic sub,
 output logic[N - 1:0] y,
 output logic carry,overflow);

    logic[N - 1:0] add_result,sub_result;
    logic add_carry,sub_carry;
    assign {add_carry,add_result} = a + b;
    assign {sub_carry,sub_result} = a - b;
    assign y = sub ? sub_result : add_result;
    assign carry = sub ? sub_carry : add_carry;
    assign overflow = ~a[N-1] & y[N - 1] &~(sub ^ b[N-1]) + a[N-1] & ~y[N - 1] & (sub ^ b[N-1]);
endmodule

`endif