`ifndef MULTIPLY_DIV_WRAPPER__
`define MULTIPLY_DIV_WRAPPER__


`include "src/common/selector.sv"
`include "src/alu/div_mul/div_mul.sv"
/**
    rs / rt
    rs * rt
    (hi,low) - rs*rt
    (hi,low) + rs*rt
**/
module multiply_div_wrapper(
input clk,reset,
input  selector::muldiv_function muldiv_funct,
input  logic clear, hold_result,
input  logic[31:0] rs,rt,
input  logic[31:0] hi_in,lo_in,
output logic[31:0] hi_out,lo_out,
output logic wait_result);

    logic mul,div,using_sign;
    logic sub,add;

    logic write_hi_lo;

    div_mul #(32) unit(.clk(clk),.reset(reset),
      .clear(clear), .hold_result(hold_result),
      .mul(mul),.div(div),.using_sign(using_sign),
      .sub(sub),.add(add),
      .a(rs),.b(rt),.hi_in(hi_in),.lo_in(lo_in),
      .hi_out(hi_out),.lo_out(lo_out),
      .write_hi_lo(write_hi_lo),.waiting_result(wait_result));
    
    always_comb begin
        {mul, div} = '0;
        {sub, add, using_sign} = 'x;
        case(muldiv_funct)
            selector::MULDIV_MULTU: begin
                mul = '1;
                using_sign = '0;
                sub = '0;
                add = '0;
            end
            default: begin
            
            end
        endcase
    end
endmodule

`endif