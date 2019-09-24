`ifndef UTIL__
`define UTIL__

module extract_instruction(input logic[31:0] instruction,output instruction_t ei);
    assign {ei.opcode,ei.rs,ei.rt,ei.rd,ei.shamt,ei.funct} = instruction;
    assign ei.immed = instruction[15:0];
endmodule

`endif