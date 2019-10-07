package special2
    typedef enum lgoic[5:0] { 
        MADD    = 6'b000000,
        MADDU   = 6'b000001,
        MUL     = 6'b000010,
        //x
        MSUB    = 6'b000100,
        MSUBU   = 6'b000101,
        //----
        CLZ     = 6'b100000,
        CLO     = 6'b100001,
     } funct;

endpackage : special2