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
        ctl = signals::get_clear_control();

        case(unpack.funct)
            rtype::SLL: begin
                ctl = decoder_util::get_shift_rtype_control(selector::ALU_SHIFT_LEFT, '0);
            end

            rtype::SYSCALL: begin
                { ctl.pc_src,                ctl.exc_chk}  = 
                { selector::PC_SRC_EXECPTION,selector::EXC_CHK_SYSCALL};
            end

            rtype::MFHI: begin
                decoder_util::write_rd(ctl, selector::REG_SRC_HI);
            end

            rtype::MTHI: begin
                ctl.hilo_src = selector::HILO_SRC_RS;
                ctl.write_hi =  1'b1;
            end

            rtype::MFLO: begin
                decoder_util::write_rd(ctl, selector::REG_SRC_LO);
            end

            rtype::MTLO: begin
                ctl.hilo_src = selector::HILO_SRC_RS;
                ctl.write_lo =  1'b1;
            end

            rtype::MULT, rtype::MULTU, rtype::DIVU, rtype::DIV: begin
                ctl.opd_use  = selector::OPERAND_USE_BOTH;
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
                { ctl.pc_src, ctl.exc_chk}  = 
                { selector::PC_SRC_EXECPTION, selector::EXC_CHK_RESERVERD};
            end
        endcase
    end
endmodule

`endif