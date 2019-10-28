`ifndef __COP0_MUX__
`define __COP0_MUX__

module cop0_mux(input selector::cop0_source src,
input logic[31:0] status,rt,
output logic[31:0] y);
    logic[31:0] status_out;

    always_comb begin : cop0_select
        status_out = status;
        case(src)
            selector::COP0_SRC_STATUS_ERET:
                if(status[cop0_info::IDX_STATUS_ERL]) begin
                    status_out[cop0_info::IDX_STATUS_ERL] = '0;
                end else begin
                    status_out[cop0_info::IDX_STATUS_EXL] = '0;
                end
            selector::COP0_SRC_STATUS_IE:
                status_out[cop0_info::IDX_STATUS_IE] = '1;
            selector::COP0_SRC_STATUS_DI:   
                status_out[cop0_info::IDX_STATUS_IE] = '0;    
            selector::COP0_SRC_STATUS_EXL:
                status_out[cop0_info::IDX_STATUS_EXL] <= '1;
        endcase
    end
    assign y = src ===  selector::COP0_SRC_RT ? rt : status_out;
endmodule

`endif