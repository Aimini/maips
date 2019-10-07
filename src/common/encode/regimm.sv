package regimm
    typedef enum logic[4:0] {
        BLTZ    = 5'b00000,
        BGEZ    = 5'b00001,
        BLTZL   = 5'b00010,
        BGEZL   = 5'b00011,
        //---  
        TGEI    = 5'b01000,
        TGEIU   = 5'b01001,
        TLTI    = 5'b01010,
        TLTIU   = 5'b01011,
        TEQI    = 5'b01100,
        TNEI    = 5'b01110,
        BLTZAL  = 5'b10000,
        BGEZAL  = 5'b10001,
        BLTZALL = 5'b10010,
        BGEZALL = 5'b10011
    } rt;
endpackage: regimm