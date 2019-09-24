//
interface instruction_signal();
    logic [5:0] opcode, funct;
    logic [4:0] rs,rt,rd,sa;
    logic [15:0] immed;
endinterface

module extract_instruction(input logic[31:0] instruction,
                           output instruction_signal ei);
    assign {ei.opcode,ei.rs,ei.rt,ei.rd,ei.sa,ei.funct} = instruction;
    assign ei.immed = instruction[15:0];
endmodule