`ifndef RTYPE_DECODER__
`define RTYPE_DECODER__

`include "src/common/encode/rtype_funct.sv"
`include "src/common/signals.sv"
`include "src/pipeline/decoder/decoder_util.sv"

module rtype_decoder(input logic[31:0] instruction,output signals::control_t ctl);

    signals::unpack_t  unpack;
    
    extract_instruction unit_ei(instruction,unpack);
    /*** note
        for rtype , it's default use $rs as alu A, $rt as alu b,
        and $rd for destination register, It's also write $rd and
        use alu as data source.
        alu_a alu_b 
        dest_reg write_reg reg_src.
        opd_use
    ***/


    always_comb begin
        ctl = decoder_util::get_default_control();

        case(unpack.funct)
            rtype::SLL: begin
                ctl = decoder_util::get_shift_rtype_control(selector::ALU_SHIFT_LEFT, '0);
                ctl.opd_use = selector::OPERAND_USE_RT;
            end

            rtype::SYSCALL: begin
                ctl.opd_use = selector::OPERAND_USE_NONE;
                { ctl.pc_src,                ctl.exc_chk}  = 
                { selector::PC_SRC_EXECPTION,selector::EXC_CHK_SYSCALL};
            end

            rtype::JR: begin
                ctl.opd_use = selector::OPERAND_USE_RS;
                ctl.pc_src =  selector::PC_SRC_REGISTER;
            end

            rtype::JALR: begin
                ctl.opd_use = selector::OPERAND_USE_RS;
                ctl.pc_src =  selector::PC_SRC_REGISTER;
                decoder_util::write_rd(ctl, selector::REG_SRC_PCADD4);
            end

            rtype::MOVZ,rtype::MOVN: begin
                decoder_util::write_rd(ctl, selector::REG_SRC_RS);
                ctl.alu_srcA = selector::ALU_SRCA_RT;
                ctl.alu_srcB = selector::ALU_SRCB_ZERO;
                ctl.write_cond = selector::REG_WRITE_WHEN_FLAG;
                if(unpack.funct == rtype::MOVZ)
                    ctl.flag_sel = selector::FLAG_EQ;
                else
                    ctl.flag_sel = selector::FLAG_NE;
            end

            rtype::MFHI: begin
                decoder_util::write_rd(ctl, selector::REG_SRC_HI);
            end

            rtype::MTHI: begin
                ctl.opd_use = selector::OPERAND_USE_RS;
                ctl.hilo_src = selector::HILO_SRC_RS;
                ctl.write_hi =  1'b1;
            end

            rtype::MFLO: begin
                decoder_util::write_rd(ctl, selector::REG_SRC_LO);
            end

            rtype::MTLO: begin
                ctl.opd_use = selector::OPERAND_USE_RS;
                ctl.hilo_src = selector::HILO_SRC_RS;
                ctl.write_lo =  1'b1;
            end

            rtype::MULT, rtype::MULTU, rtype::DIVU, rtype::DIV: begin
                ctl.hilo_src = selector::HILO_SRC_MULDIV;
                ctl.write_hi =  1'b1;
                ctl.write_lo =  1'b1;
                case(unpack.funct)
                    rtype::MULT : ctl.muldiv_funct = selector::MULDIV_MULT;
                    rtype::MULTU: ctl.muldiv_funct = selector::MULDIV_MULTU;
                    rtype::DIVU : ctl.muldiv_funct = selector::MULDIV_DIVU;
                    rtype::DIV  : ctl.muldiv_funct = selector::MULDIV_DIV;
                    default:
                        ctl.muldiv_funct = selector::MULDIV_NCARE;
                endcase
            end

            rtype::ADDU: begin
                ctl = decoder_util::get_alu_rtype_control(selector::ALU_ADD);
            end

            default:begin
                {ctl.opd_use, ctl.pc_src, ctl.exc_chk}  = 
                {selector::OPERAND_USE_NONE, selector::PC_SRC_EXECPTION, selector::EXC_CHK_RESERVERD};
            end
        endcase
    end
endmodule

`endif