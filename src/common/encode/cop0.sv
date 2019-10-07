package cop0
typedef enum logic[4:0] {
    MFC0 = 5'b00000,
    MTC0 = 5'b00100,
    C0   = 5'b1xxxx,
  } rs;

  typedef enum logic[5:0] { 
      ERET = 011000
   } C0funct;

endpackage: cop0