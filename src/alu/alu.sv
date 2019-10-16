`ifndef ALU__
`define ALU__
`include "src/common/selector.sv"
`include "src/alu/alu_logic/alu_logic.sv"
`include "src/alu/alu_arithmatic.sv"
`include "src/alu/compare/comparator.sv"
module alu #(parameter N = 32)
(input logic[N - 1:0] a,b,
 input logic[$clog2(N) - 1:0] sa,
 input selector::alu_function funct,
 output logic[N - 1:0] y,
 output signals::flag_t flag);

    logic[N - 1:0] alu_logic_y,alu_arithmatic_y;
    logic sub;
    logic carry;
    signals::compare_t compare_result;

    assign flag.carry = carry;
    assign flag.compare = compare_result;
    assign sub = (funct === selector::ALU_SUB);
    alu_logic #(N) unit_alu_logic(.a(a),.b(b),
    .funct(funct),.sa(sa),
    .y(alu_logic_y));

    alu_arithmatic #(N) unit_alu_arithmatic(.a(a),.b(b),
    .sub(sub),
    .y(alu_arithmatic_y),.carry(carry));

    comparator  #(N) unit_comparator(.a(a),.b(b),.signal(compare_result));

    always_comb begin
        case(funct)
            selector::ALU_ADD,selector::ALU_SUB:
                y = alu_arithmatic_y;
            selector::ALU_AND,selector::ALU_OR,
            selector::ALU_XOR,selector::ALU_NOR,
            selector::ALU_SHIFT_LEFT,
            selector::ALU_SHIFT_LOGIC_RIGHT,
            selector::ALU_SHIFT_ARITHMATIC_RIGHT,
            selector::ALU_ROTATE_RIGHT,
            selector::ALU_CLO,selector::ALU_CLZ:
                y = alu_logic_y;
            default:
                y = 'x;
        endcase
    end

endmodule
`endif