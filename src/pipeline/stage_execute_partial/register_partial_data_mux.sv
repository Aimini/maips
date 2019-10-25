`ifndef REGISTER_PARTIAL_DATA_MUX__
`define REGISTER_PARTIAL_DATA_MUX__

module register_partial_data_mux(
 input selector::register_source reg_src,input logic using_delay_slot,
 input logic[31:0] alu_out,pcadd4,pcadd8,rs,hi,lo,cop0,mul_div_lo,special3,
 input logic flag,llbit,
output logic[31:0] data);
    always_comb begin
        case(reg_src)
            selector::REG_SRC_ALU:
                data = alu_out;
            selector::REG_SRC_MUL:
                data = mul_div_lo;
            selector::REG_SRC_LINKADDR: begin
                    if(using_delay_slot)
                        data = pcadd8;
                    else
                        data = pcadd4;
                end
            selector::REG_SRC_RS:
                data = rs;  
            selector::REG_SRC_FLAG:
                data = {31'b0,flag};
            selector::REG_SRC_LLBIT:
                data = {31'b0,llbit};
            selector::REG_SRC_HI:
                data = hi;
            selector::REG_SRC_LO:
                data = lo;
            selector::REG_SRC_COP0:
                data = cop0;
            selector::REG_SRC_SPECIAL3:
                data = special3;
            default:
                data = 'x;
        endcase
    end
        
endmodule

`endif