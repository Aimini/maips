`ifndef MAIN_DECODER__
`define MAIN_DECODER__

`include "src/common/signals.sv"
`include "src/common/util.sv"
`include "src/common/encode/main_opcode.sv"
`include "src/pipeline/decoder/rtype_decoder.sv"
`include "src/pipeline/decoder/special2_decoder.sv"
`include "src/pipeline/decoder/decoder_util.sv"

module main_decoder(input logic[31:0] instruction,output signals::control_t ctl);
    signals::control_t rtype_control;
    signals::control_t regimm_control;
    signals::control_t cop0_control;
    signals::control_t special2_control;
    signals::unpack_t  unpack;

    extract_instruction unit_ei(instruction,unpack);
    rtype_decoder unit_rtype(instruction, rtype_control);
    special2_decoder unit_special2(instruction, special2_control);

    always_comb begin
        ctl =  decoder_util::get_default_control();

        case(unpack.opcode)
            main_opcode::RTYPE:   ctl = rtype_control;
            main_opcode::REGIMM:  ctl = regimm_control;
            main_opcode::SPECIAL2:ctl = special2_control;

            
            main_opcode::J, main_opcode::JAL: begin
                ctl.opd_use = selector::OPERAND_USE_NONE;
                ctl.pc_src = selector::PC_SRC_JUMP;
                if(unpack.opcode == main_opcode::JAL) begin
                    ctl.write_reg = 1;
                    ctl.reg_src =  selector::REG_SRC_PCADD4;
                    ctl.dest_reg = selector::DEST_REG_31;
                end  
            end
            
            main_opcode::BEQ,  main_opcode::BNE,
            main_opcode::BLEZ, main_opcode::BGTZ, //rt are hard encoding as $0
            main_opcode::BEQL, main_opcode::BNEL,
            main_opcode::BLEZL,main_opcode::BGTZL: begin
                ctl = decoder_util::get_standard_control();
                case(unpack.opcode)
                    main_opcode::BEQ, main_opcode::BEQL:
                        decoder_util::branch_with(ctl,selector::FLAG_EQ);
                    main_opcode::BNE,main_opcode::BNEL:
                        decoder_util::branch_with(ctl,selector::FLAG_NE);
                    main_opcode::BLEZ,main_opcode::BLEZL:
                        decoder_util::branch_with(ctl,selector::FLAG_LE);
                    main_opcode::BGTZ,main_opcode::BGTZL:
                        decoder_util::branch_with(ctl,selector::FLAG_GT);
                endcase
            end

            main_opcode::ADDI,main_opcode::ADDIU: begin
                ctl = decoder_util::get_sign_immed_control();
                ctl.opd_use = selector::OPERAND_USE_RS;
                decoder_util::write_alu_to_rt(ctl,selector::ALU_ADD);

                if(unpack.opcode == main_opcode::ADDI)
                    ctl.exc_chk = selector::EXC_CHK_OVERFLOW;
            end

            main_opcode::SLTI,main_opcode::SLTIU: begin
                ctl = decoder_util::get_sign_immed_control();
                ctl.opd_use = selector::OPERAND_USE_RS;
                if(unpack.opcode == main_opcode::SLTIU)
                    decoder_util::write_flag_to_rt(ctl,selector::FLAG_LTU);
                else
                    decoder_util::write_flag_to_rt(ctl,selector::FLAG_LT);
            end

            main_opcode::ANDI,main_opcode::ORI,main_opcode::XORI: begin
                ctl = decoder_util::get_zero_immed_control();
                ctl.opd_use = selector::OPERAND_USE_RS;
                case(unpack.opcode)
                    main_opcode::ANDI:
                        decoder_util::write_alu_to_rt(ctl, selector::ALU_AND);
                    main_opcode::ORI:
                        decoder_util::write_alu_to_rt(ctl, selector::ALU_OR);
                    main_opcode::XORI:
                        decoder_util::write_alu_to_rt(ctl, selector::ALU_XOR);
                    default:
                        decoder_util::write_alu_to_rt(ctl, selector::ALU_NCARE);
                endcase
            end

            main_opcode::LB, main_opcode::LH,  main_opcode::LW: begin
                ctl = decoder_util::get_mem_addr_control();
                ctl.opd_use = selector::OPERAND_USE_RS;
                case(unpack.opcode)
                    main_opcode::LB: ctl.read_mode = selector::MEM_READ_BYTE;
                    main_opcode::LH: ctl.read_mode = selector::MEM_READ_HALF;
                    main_opcode::LW: ctl.read_mode = selector::MEM_READ_WORD;
                    default: ctl.read_mode = selector::MEM_READ_NCARE;
                endcase
                decoder_util::write_rt(ctl, selector::REG_SRC_MEM);
            end

            main_opcode::SW: begin
                ctl = decoder_util::get_mem_addr_control();
                {ctl.write_mode,           ctl.write_mem } = 
                {selector::MEM_WRITE_WORD, 1'b1};
            end

            main_opcode::LUI: begin
                ctl = decoder_util::get_up_immed_control();
                ctl.opd_use = selector::OPERAND_USE_NONE;
                decoder_util::write_alu_to_rt(ctl,selector::ALU_ADD);
            end
            
            default:begin
                {ctl.opd_use, ctl.pc_src, ctl.exc_chk}  = 
                {selector::OPERAND_USE_NONE, selector::PC_SRC_EXECPTION, selector::EXC_CHK_RESERVERD};
            end
        endcase
    end
endmodule

`endif
