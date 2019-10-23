package special3;
    typedef enum logic[5:0] { 
        EXT    = 6'b000000,
        INS    = 6'b000100,
        BSHFL  = 6'b100000
     } funct;

    typedef enum logic[4:0] { 
        WSBH    = 5'b00010,
        SEB     = 5'b10000,
        SEH     = 5'b11000
    } sa;
endpackage : special3