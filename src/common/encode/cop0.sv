package cop0;
typedef enum logic[4:0] {
    MFC0 = 5'b00000,
    MTC0 = 5'b00100,
    MFMC0= 5'b01011
  } rs;

  function automatic logic match_c0funct(input logic[4:0] rs);
    return rs[4] === 1;
  endfunction

  typedef enum logic[5:0] { 
      ERET = 6'b011000
   } C0funct;

  
endpackage: cop0