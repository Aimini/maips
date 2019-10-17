`ifndef SPECIAL2_DECODER__
`define SPECIAL2_DECODER__

`include "src/common/encode/special2.sv"
`include "src/common/signals.sv"
`include "src/pipeline/decoder/decoder_util.sv"

module special2_decoder(input logic[31:0] instruction,output signals::control_t ctl);

    signals::unpack_t  unpack;    
    extract_instruction unit_ei(instruction,unpack);
    always_comb begin
        ctl = signals::get_clear_control();
        case(unpack.funct)
            special2::MADD,special2::MADDU,special2::MSUB,special2::MSUBU: begin
                ctl = decoder_util::get_standard_control();
                ctl.write_hi = '1;
                ctl.write_lo = '1;
                ctl.hilo_src =  selector::HILO_SRC_MULDIV;
                case(unpack.funct)
                    special2::MADD:  ctl.muldiv_funct = selector::MULDIV_MADD;
                    special2::MADDU: ctl.muldiv_funct = selector::MULDIV_MADDU;
                    special2::MSUB:  ctl.muldiv_funct = selector::MULDIV_MSUB;
                    special2::MSUBU :ctl.muldiv_funct = selector::MULDIV_MSUBU;
                    default:
                    ctl.muldiv_funct = selector::MULDIV_NCARE;
                endcase
            end

            default: begin
                { ctl.pc_src, ctl.exc_chk}  = 
                { selector::PC_SRC_EXECPTION, selector::EXC_CHK_RESERVERD};
            end 
        endcase
    end
endmodule

`endif
