`ifndef ALU_SOURCE_MUX__
`define ALU_SOURCE_MUX__
`include "src/common/selector.sv"

module alu_source_mux(
input selector::alu_sourceA src_a,
input selector::alu_sourceB src_b,
input logic[31:0] rs,rt,
input logic[15:0] immed,
output logic[31:0] a,b); 

    logic[31:0] sign_immed, zero_immed,up_immed;
    sign_extend #(.NI(16),.NO(32)) 
    unit_ses(immed,sign_immed);

    sign_extend #(.NI(17),.NO(32)) 
    unit_sez({1'b0,immed},zero_immed);

    assign up_immed = immed << 16;
    always_comb begin
        case(src_a)
            selector::ALU_SRCA_RS:
                a = rs;
            selector::ALU_SRCA_RT:
                a = rt;
            default:
                a = 'x;
        endcase

        case(src_b)
            selector::ALU_SRCB_RT:
                b = rt;
            selector::ALU_SRCB_SIGN_IMMED:
                b = sign_immed;
            selector::ALU_SRCB_IMMED:
                b = zero_immed;
            selector::ALU_SRCB_UP_IMMED:
                b = up_immed;
            default:
                b = 'x;
        endcase
    end
endmodule

`endif
