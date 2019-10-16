`ifndef UTIL__
`define UTIL__

`include "src/common/signals.sv"

module extract_instruction(input logic[31:0] instruction,output signals::unpack_t ei);
    assign {ei.opcode,ei.rs,ei.rt,ei.rd,ei.sa,ei.funct} = instruction;
    assign ei.immed = instruction[15:0];
    assign ei.sel = instruction[2:0];
endmodule

// for low speed devices
module freq_divder(input logic clk,input logic[2:0] select,output logic clko);
    logic[6:0] flip_flops;
    logic[7:0] select_clks;
    always@(posedge clk)
        flip_flops <= flip_flops + 1;
    assign select_clks = {flip_flops,clk};
    assign clko = select_clks[select];
endmodule

module sign_extend #(parameter NI = 16,parameter NO = 32)
(input logic[NI - 1:0] i, output logic[NO - 1:0] o);
    assign o =  {{NO - NI{i[NI - 1]}},i};
endmodule

typedef enum  {COUNTER_RESET, COUNTER_HOLD,COUNTER_UP,COUNTER_DOWN,COUNTER_LOAD} counter_function;
module counter #(parameter N = 5)
(input logic clk, reset,
 input counter_function funct, input logic[N - 1:0] din, output logic[N - 1:0] dout, logic carry);

    logic[N - 1:0] count_reg, next_count_value;
    always_ff @(posedge clk,posedge reset) begin
        if(reset)
            count_reg <= 0;
        else
            count_reg <= next_count_value;
    end

    always_comb begin
        case(funct)
            COUNTER_RESET:
                next_count_value = '0;
            COUNTER_HOLD:
                next_count_value = count_reg;
            COUNTER_UP:
                next_count_value = count_reg + 1;
            COUNTER_DOWN:
                next_count_value = count_reg - 1;
            COUNTER_LOAD:
                next_count_value = din;
        endcase
        dout = count_reg;
        carry = & count_reg;
    end
endmodule

`endif