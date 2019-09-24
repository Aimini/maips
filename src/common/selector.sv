`ifndef PACKAGE_SELECTOR__
`define PACKAGE_SELECTOR__

package selector;
/*directly generate by main decoder */
typedef enum logic[2:0] {branch_next,branch_zero,branch_nozero,branch_jump} branch_type;
/* combine with branch_type and flag signal*/
typedef enum logic[1:0] {PC_SRC_NEXT,PC_SRC_SIGNIMMED,PC_SRC_JUMP} pc_source;

/*typedef enum logic[1:0] {ALU_DECODE_ADD,ALU_DECODE_SUB,ALU_DECODE_FUNCT,ALU_DECODE_NCARE = 'x} alu_decoder_mode;*/
typedef enum logic[2:0] {ALU_ADD,ALU_SUB,ALU_AND,ALU_OR,ALU_XOR,ALU_SLT,ALU_NCARE = 'x} alu_function;

typedef enum logic[1:0] {ALU_SRCA_RS,ALU_SRCA_ZERO,ALU_SRCA_NCARE = 'x} alu_sourceA;
typedef enum logic[1:0] {ALU_SRCB_RT,ALU_SRCB_SIGN_IMMED,ALU_SRCB_IMMED,ALU_SRCB_UP_IMMED,ALU_SRCB_NCARE = 'x} alu_sourceB;

typedef enum logic[3:0]{WRITE_REG_RD,WRITE_REG_RT,WRITE_REG_NCARE = 'x} write_regiter;

/* memory stage control signal */
typedef enum logic[3:0] {MEM_READ_BYTE, MEM_READ_HALF, MEM_READ_WORD, MEM_READ_LWL, MEM_READ_LWR, MEM_READ_UNSIGN_HALF,MEM_READ_NCARE = 'x} mem_read_type;
typedef enum logic[3:0] {MEM_WRITE_BYTE,MEM_WRITE_HALF,MEM_WRITE_WORD,MEM_WRITE_SWL,MEM_WRITE_SWR,MEM_WRITE_NCARE = 'x} mem_write_type;
endpackage : selector

`endif