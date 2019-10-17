`ifndef PACKAGE_SELECTOR__
`define PACKAGE_SELECTOR__

package selector;
/*directly generate by main decoder */
typedef enum  {
    FLAG_EQ,  FLAG_NE,
    FLAG_LE,  FLAG_GE,
    FLAG_GT,  FLAG_LT,
    FLAG_LEU, FLAG_GEU,
    FLAG_GTU, FLAG_LTU,
    FLAG_NCARE} flag_select;

/* combine with branch_type and flag signal*/
typedef enum { 
    PC_SRC_NEXT, PC_SRC_BRANCH,
    PC_SRC_JUMP, PC_SRC_REGISTER,
    PC_SRC_EXECPTION} pc_source;
/* exception check*/
typedef enum {
    EXC_CHK_TRAP,          EXC_CHK_SYSCALL,
    EXC_CHK_BREAK,         EXC_CHK_INTERRUPT,
    EXC_CHK_RESERVERD,     EXC_CHK_OVERFLOW,
    EXC_CHK_FETCH_ADDRESS, EXC_CHK_LOAD_STORE_ADDRESS,
    EXC_CHK_NONE} execption_check_t;
/*typedef enum logic[1:0] {ALU_DECODE_ADD,ALU_DECODE_SUB,ALU_DECODE_FUNCT,ALU_DECODE_NCARE = 'x} alu_decoder_mode;*/
typedef enum  {
    ALU_ADD                     ,ALU_SUB,
    ALU_AND,ALU_OR              ,ALU_XOR,ALU_NOR,
    ALU_SHIFT_LEFT              ,ALU_SHIFT_LOGIC_RIGHT,
    ALU_SHIFT_ARITHMATIC_RIGHT  ,ALU_ROTATE_RIGHT,
    ALU_CLO                     ,ALU_CLZ,
    ALU_NCARE} alu_function;

        //SPECIAL FUNCTION
typedef enum{
    MULDIV_MULT, MULDIV_MULTU,
    MULDIV_DIV,  MULDIV_DIVU,
    MULDIV_MADD,MULDIV_MADDU,
    MULDIV_MSUB,MULDIV_MSUBU,
    MULDIV_NCARE
} muldiv_function;

typedef enum{
    HILO_SRC_RS, HILO_SRC_MULDIV,
    HILO_SRC_NCARE
} hilo_source;
/** register source **/
typedef enum {
    REG_SRC_ALU,   REG_SRC_PCADD4,
    REG_SRC_RS,    REG_SRC_FLAG,
    REG_SRC_LLBIT, REG_SRC_HI,
    REG_SRC_LO,    REG_SRC_MUL,
    REG_SRC_CP0,   REG_SRC_MEM,
    REG_SRC_NCARE
} register_source;

typedef enum  {
    ALU_SRCA_RS,   ALU_SRCA_RT,
    ALU_SRCA_NCARE} alu_sourceA;
typedef enum  {
    ALU_SRCB_RT,    ALU_SRCB_SIGN_IMMED,
    ALU_SRCB_IMMED, ALU_SRCB_UP_IMMED,
    ALU_SRCB_NCARE} alu_sourceB;
typedef enum  { ALU_SRCSA_SA,ALU_SRCSA_RS,
ALU_SRCSA_NCARE  } 
alu_sourceShift;

typedef enum {
    DEST_REG_RD, DEST_REG_RT,
    DEST_REG_31, DEST_REG_NCARE} destnation_regiter;

/* memory stage control signal */
typedef enum  {
    MEM_READ_BYTE,        MEM_READ_HALF, 
    MEM_READ_WORD,        MEM_READ_LWL,
    MEM_READ_LWR,         MEM_READ_UNSIGN_BYTE,
    MEM_READ_UNSIGN_HALF, MEM_READ_NCARE} mem_read_type;

typedef enum  {
    MEM_WRITE_BYTE, MEM_WRITE_HALF,
    MEM_WRITE_WORD, MEM_WRITE_SWL,
    MEM_WRITE_SWR , MEM_WRITE_NCARE} mem_write_type;

//to avoid unnecessary stall, you must announce which
// operand you are using.
typedef enum {
    OPERAND_USE_BOTH,
    OPERAND_USE_RS,
    OPERAND_USE_RT,
    OPERAND_USE_NONE
} operand_use;
endpackage : selector

`endif