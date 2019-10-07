module instruction_extractor(input logic[31:0] instruction,
output logic[5:0] opcode,funct,
output logic[4:0] rs,rt,rd,shamt,
output logic[15:0] immed);
    assign {opcode,rs,rt,rd,shamt,funct} = instruction;
    assign immed = instruction[15:0];
endmodule