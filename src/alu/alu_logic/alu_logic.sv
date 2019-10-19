`ifndef ALU_LOGIC__
`define ALU_LOGIC__

`include "src/common/selector.sv"
`include "src/alu/alu_logic/alu_logic_clz.sv"

module alu_logic #(parameter N = 32)
(input logic[N - 1:0] a,b,
 input selector::alu_function funct,
 input logic[$clog2(N) - 1:0] sa,
output logic[N - 1:0] y);

    logic[$clog2(N):0] clz_y,clo_y;
    logic clz_all_zero,clo_all_zero;
    logic signed[N - 1:0] bs;
    alu_logic_clz #(N) unit_clz(.a(a),.y(clz_y),.all_zero(clz_all_zero));
    alu_logic_clz #(N) unit_clo(.a(~a),.y(clo_y),.all_zero(clo_all_zero));
    assign bs = b;
    always_comb begin
        case(funct)
            selector::ALU_AND : y = a & b;
            selector::ALU_OR :  y = a | b;
            selector::ALU_XOR:  y = a^b;
            selector::ALU_NOR:  y = ~(a|b);
            selector::ALU_SHIFT_LEFT:             y = b << sa;
            selector::ALU_SHIFT_LOGIC_RIGHT:      y = b >> sa;
            selector::ALU_SHIFT_ARITHMATIC_RIGHT: y = bs >>> sa;
            selector::ALU_ROTATE_RIGHT:           y = (b >> sa) | (b << N - sa);
            selector::ALU_CLZ: y = clz_y;
            selector::ALU_CLO: y = clo_y;
            default: y = 'x;
        endcase
    end
endmodule
`endif



