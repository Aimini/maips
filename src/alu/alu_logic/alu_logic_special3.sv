/**
    for special3 instruction  
    name                  function                                             
   ALU_SWAP_BYTE_IN_HALF  swap byte in high and low half byte respectively in a
   ALU_SIGN_EXT_BYTE      sign extend the least significant byte in a      
   ALU_SIGN_EXT_HALF      sign extend the least significant lalfword in a      
   ALU_EXTRACT_BIT        extract bit form a than start with lsb and end with msbd [msbd:lsb]
   ALU_INSERT_BIT         insert bit from a to b ....
*/

`ifndef ALU_LOGIC_SPECIAL3__
`define ALU_LOGIC_SPECIAL3__
`include "src/common/selector.sv"
module alu_logic_special3(input logic[31:0] a,b,
input logic[4:0] msbd,lsb, // using for extract bit and insert bit
output logic[31:0] y,input selector::alu_function funct);
    logic[31:0] msbd_mask, field_mask;
    assign msbd_mask = 32'hFFFFFFFF >> ~msbd;
    assign field_mask  = msbd_mask << lsb;
    always_comb begin
        case(funct)
            selector::ALU_SWAP_BYTE_IN_HALF : y = {a[23:16],a[31:24],a[7:0],a[15:8]};
            selector::ALU_SIGN_EXT_BYTE :     y = {{24{a[7]}},a[7:0]};
            selector::ALU_SIGN_EXT_HALF :     y = {{16{a[15]}},a[15:0]};
            selector::ALU_EXTRACT_BIT:  y =  (a >> lsb) & msbd_mask;
            selector::ALU_INSERT_BIT:  y = (msbd_mask & a ) << lsb | ~field_mask & b;
            default: y = 'x;
        endcase
    end
endmodule

`endif
