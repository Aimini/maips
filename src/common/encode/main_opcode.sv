package main_opcode;

typedef enum logic[5:0] {
    RTYPE    = 6'b000000,
    REGIMM   = 6'b000001,
    J        = 6'b000010,
    JAL      = 6'b000011,
    BEQ      = 6'b000100,
    BNE      = 6'b000101,
    BLEZ     = 6'b000110,
    BGTZ     = 6'b000111,
    ADDI     = 6'b001000,
    ADDIU    = 6'b001001,
    SLTI     = 6'b001010,
    SLTIU    = 6'b001011,
    ANDI     = 6'b001100,
    ORI      = 6'b001101,
    XORI     = 6'b001110,
    LUI      = 6'b001111,
    COP0     = 6'b010000,
    //--
    BEQL     = 6'b010100,
    BNEL     = 6'b010101,
    BLEZL    = 6'b010110,
    BGTZL    = 6'b010111,
    //--
    SPECIAL2 = 6'b011100,
    SPECIAL3 = 6'b011111,
    LB       = 6'b100000,
    LH       = 6'b100001,
    LWL      = 6'b100010,
    LW       = 6'b100011,
    LBU      = 6'b100100,
    LHU      = 6'b100101,
    LWR      = 6'b100110,
    // Reversed 6'b100111;
    SB       = 6'b101000,
    SH       = 6'b101001,
    SWL      = 6'b101010,
    SW       = 6'b101011,
    //Reversed
    SWR      = 6'b101110,
    // CACHE    = 6'b101111,
    LL       = 6'b110000,
    SC       = 6'b111000
} opcode;
endpackage : main_opcode