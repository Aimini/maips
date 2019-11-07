`ifndef __COP0_MUX__
`define __COP0_MUX__

module cop0_mux(input selector::cop0_source src,
input logic[31:0] status,rt,mem_addr, wmask_mtc0,
output logic[31:0] y,wmask);
    logic[31:0] status_out;

    always_comb begin : set_status
        status_out = status;
        case(src)
            selector::COP0_SRC_STATUS_ERET:
                if(status[cop0_info::IDX_STATUS_ERL]) begin
                    status_out[cop0_info::IDX_STATUS_ERL] = '0;
                end else begin
                    status_out[cop0_info::IDX_STATUS_EXL] = '0;
                end
            selector::COP0_SRC_STATUS_EI:
                status_out[cop0_info::IDX_STATUS_IE] = '1;
            selector::COP0_SRC_STATUS_DI:   
                status_out[cop0_info::IDX_STATUS_IE] = '0;    
            selector::COP0_SRC_STATUS_EXL:
                status_out[cop0_info::IDX_STATUS_EXL] <= '1;
        endcase
    end

    always_comb begin : cop0_select
        case(src)
            selector::COP0_SRC_RT:
                y = rt;
            selector::COP0_SRC_LLADDR:
                y = mem_addr;
            default:
                y = status_out;
        endcase

         case(src)
            selector::COP0_SRC_RT:
                wmask = wmask_mtc0;
            default:
                wmask = 32'hFFFFFFFF;
        endcase
    end
endmodule

`endif