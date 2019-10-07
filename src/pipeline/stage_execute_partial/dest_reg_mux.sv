`ifndef DEST_REG_MUX__
`define DEST_REG_MUX__

`include "src/common/selector.sv"

module dest_reg_mux(input selector::destnation_regiter select,
 input logic[4:0] rd,rt,
 output logic[4:0] dest_reg);
    always_comb begin
        case(select)
            selector::DEST_REG_RD: dest_reg = rd;
            selector::DEST_REG_RT: dest_reg = rt;
            selector::DEST_REG_31: dest_reg = 31;
            default:     dest_reg = 'x;
        endcase
    end

endmodule

`endif