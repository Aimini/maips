typedef struct
{
        logic [5:0] opcode, funct;
        logic [4:0] rs,rt,rd,sa;
        logic [15:0] immed;
    
} instruction_t;

