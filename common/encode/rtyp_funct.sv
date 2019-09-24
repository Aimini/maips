package rtype
    typedef logic [6:0]
    {
        SLL   = 6'b000000,
        //MOVCI = 6'b000001,
        SRL     = 6'b000010,
        SRA     = 6'b000011,
        SLLV    = 6'b000100,
        SLL     = 6'b000101,
        SRLV    = 6'b000110,
        SRAV    = 6'b000111,
        JR      = 6'b001000,
        JALR    = 6'b001001,
        MOVZ    = 6'b001010,
        MOVN    = 6'b001011,
        SYSCALL = 6'b001100;
        BREAK   = 6'b001101;
        MFHI    = 6'b010000;
        MTHI    = 6'b010001;
        MFLO    = 6'b010010;
        MTLO    = 6'b010011;
        MULT    = 6'b011000;
        MULTU   = 6'b011001;
        DIV     = 6'b011010;
        DIVU    = 6'b011011;
        ADD     = 6'b100000;
        ADDU    = 6'b100001;
        SUB     = 6'b100010;
        SUBU    = 6'b100011;
        AND     = 6'b100100;
        OR      = 6'b100101;
        XOR     = 6'b100110;
        NOR     = 6'b100111;
        TGE     = 6'b110000;
        TGEU    = 6'b110001;
        TLT     = 6'b110010;
        TLTU    = 6'b110011;
        TEQ     = 6'b110100;
        TNE     = 6'b110110;
    } funct;

endpackage: rtype;