`ifndef __COP0_MUX__
`define __COP0_MUX__

module cop0_mux(input selector::cop0_source src,
input logic[31:0] status,rt,
output logic[31:0] y);

    always_comb begin : cop0_select
        case(src)
            selector::COP0_SRC_RT:
                y = rt;
            selector::COP0_SRC_STATUS:
                y = status;
            default:
                y = 'x;
        endcase
    end
endmodule

`endif