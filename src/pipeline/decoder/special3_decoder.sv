`ifndef SPECIAL3_DECODER__
`define SPECIAL3_DECODER__

`include "src/common/encode/special3.sv"
`include "src/common/signals.sv"
`include "src/pipeline/decoder/decoder_util.sv"

module special3_decoder(input logic[31:0] instruction,output signals::control_t ctl);

    signals::unpack_t  unpack;    
    extract_instruction unit_ei(instruction,unpack);
    always_comb begin
        ctl = decoder_util::get_default_control();
        case(unpack.funct)
            special3::EXT: begin
                ctl.opd_use = selector::OPERAND_USE_RS;
                ctl.alu_funct = selector::ALU_EXTRACT_BIT;
                ctl.alu_srcA = selector::ALU_SRCA_RS;
                decoder_util::write_rt(ctl,selector::REG_SRC_SPECIAL3);
            end

            special3::INS: begin
                ctl.alu_funct = selector::ALU_INSERT_BIT;
                ctl.alu_srcA = selector::ALU_SRCA_RS;
                ctl.alu_srcB = selector::ALU_SRCB_RT;
                decoder_util::write_rt(ctl,selector::REG_SRC_SPECIAL3);
            end

            special3::BSHFL: begin
                ctl.opd_use = selector::OPERAND_USE_RS;
                ctl.alu_srcA = selector::ALU_SRCA_RT;
                case(unpack.sa)
                    special3::WSBH: ctl.alu_funct = selector::ALU_SWAP_BYTE_IN_HALF;
                    special3::SEB:  ctl.alu_funct = selector::ALU_SIGN_EXT_BYTE;
                    special3::SEH:  ctl.alu_funct = selector::ALU_SIGN_EXT_HALF;
                endcase
                decoder_util::write_rd(ctl,selector::REG_SRC_SPECIAL3);
            end
            
            default: begin
                {ctl.opd_use, ctl.pc_src, ctl.exc_chk}  = 
                {selector::OPERAND_USE_NONE, selector::PC_SRC_EXECPTION, selector::EXC_CHK_RESERVERD};
            end 
        endcase
    end
endmodule

`endif
