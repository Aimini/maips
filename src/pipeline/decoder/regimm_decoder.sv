`ifndef REGIMM_DECODER__
`define REGIMM_DECODER__
`include "src/common/encode/regimm.sv"
`include "src/common/signals.sv"
`include "src/pipeline/decoder/decoder_util.sv"

module regimm_decoder(input logic[31:0] instruction,output signals::control_t ctl);
    signals::unpack_t  unpack;
    extract_instruction unit_ei(instruction,unpack);
    always_comb begin
        ctl = decoder_util::get_default_control();
        case(unpack.rt)
            regimm::BLTZ,regimm::BLTZL,regimm::BLTZAL,regimm::BLTZALL: begin
                ctl.opd_use  = selector::OPERAND_USE_RS;
                ctl.alu_srcA = selector::ALU_SRCA_RS;
                ctl.alu_srcB = selector::ALU_SRCB_ZERO;
                decoder_util::branch_with(ctl,selector::FLAG_LT);
                if(unpack.rt === regimm::BLTZAL |unpack.rt === regimm::BLTZALL) begin
                    ctl.write_reg = '1;
                    ctl.reg_src = selector::REG_SRC_LINKADDR;
                    ctl.dest_reg = selector::DEST_REG_31;
                end
            end

            regimm::TGEI,regimm::TGEIU,
            regimm::TLTI,regimm::TLTIU,
            regimm::TEQI,regimm::TNEI: begin
                ctl = decoder_util::get_sign_immed_control();
                ctl.opd_use  = selector::OPERAND_USE_RS;
                ctl.exc_chk = selector::EXC_CHK_TRAP;
                case(unpack.rt)
                    regimm::TGEI: ctl.flag_sel = selector::FLAG_GE;
                    regimm::TGEIU:ctl.flag_sel = selector::FLAG_GEU;
                    regimm::TLTI: ctl.flag_sel = selector::FLAG_LT;
                    regimm::TLTIU:ctl.flag_sel = selector::FLAG_LTU;
                    regimm::TEQI: ctl.flag_sel = selector::FLAG_EQ;
                    regimm::TNEI: ctl.flag_sel = selector::FLAG_NE;
                    default:
                        ctl.flag_sel = selector::FLAG_NCARE;
                endcase
            end

            regimm::BGEZ,regimm::BGEZL,regimm::BGEZAL,regimm::BGEZALL: begin
                ctl.opd_use  = selector::OPERAND_USE_RS;
                ctl.alu_srcA = selector::ALU_SRCA_RS;
                ctl.alu_srcB = selector::ALU_SRCB_ZERO;
                decoder_util::branch_with(ctl,selector::FLAG_GE);
                if(unpack.rt === regimm::BGEZAL |unpack.rt === regimm::BGEZALL) begin
                    ctl.write_reg = '1;
                    ctl.reg_src = selector::REG_SRC_LINKADDR;
                    ctl.dest_reg = selector::DEST_REG_31;
                end
            end
            default:
            {ctl.opd_use, ctl.pc_src, ctl.exc_chk}  = 
            {selector::OPERAND_USE_NONE, selector::PC_SRC_EXECPTION, selector::EXC_CHK_RESERVERD};
        endcase
    end
endmodule

`endif
