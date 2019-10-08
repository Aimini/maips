`ifndef MAIN_DECODER__
`define MAIN_DECODER__

`include "src/common/signals.sv"
`include "src/common/util.sv"
`include "src/common/encode/main_opcode.sv"
`include "src/pipeline/decoder/rtype_decoder.sv"


module main_decoder(input logic[31:0] instruction,output signals::control_t ctl);
    signals::control_t rtype_control;
    signals::control_t regimm_control;
    signals::control_t cop0_control;
    signals::control_t special2_control;
    signals::unpack_t  unpack;

    extract_instruction unit_ei(instruction,unpack);
    rtype_decoder unit_rtype(instruction, rtype_control);
    

    always_comb begin
        ctl = '{selector::ALU_NCARE,       selector::ALU_SRCA_NCARE, selector::ALU_SRCB_NCARE,
                selector::DEST_REG_NCARE,  selector::PC_SRC_NEXT,    selector::FLAG_NCARE,
                selector::REG_SRC_NCARE,   selector::MEM_READ_NCARE, selector::MEM_WRITE_NCARE,
                selector::OPERAND_USE_BOTH,selector::EXC_CHK_NONE,
                1'b0,1'b0,1'b0,1'b0,1'b0};
        case(unpack.opcode)
            main_opcode::RTYPE:   ctl = rtype_control;
            main_opcode::REGIMM:  ctl = regimm_control;
            main_opcode::J, main_opcode::JAL: begin
                ctl.pc_src = selector::PC_SRC_JUMP;
                ctl.opd_use = selector::OPERAND_USE_NONE;
                if(unpack.opcode == main_opcode::JAL) begin
                    ctl.write_reg = 1;
                    ctl.reg_src = selector::REG_SRC_PCADD4;
                    ctl.dest_reg = selector::DEST_REG_31;
                end  
            end
            
            main_opcode::BEQ,  main_opcode::BNE,
            main_opcode::BLEZ, main_opcode::BGTZ,
            main_opcode::BEQL, main_opcode::BNEL,
            main_opcode::BLEZL,main_opcode::BGTZL: begin
                {ctl.pc_src,  ctl.alu_srcA,
                 ctl.alu_srcB}  =
                {selector::PC_SRC_BRANCH, selector::ALU_SRCA_RS,
                 selector::ALU_SRCB_RT};
                case(unpack.opcode)
                    main_opcode::BEQ, main_opcode::BEQL:
                        ctl.flag_sel = selector::FLAG_EQ;
                    main_opcode::BNE,main_opcode::BNEL:
                        ctl.flag_sel = selector::FLAG_NE;
                    main_opcode::BLEZ,main_opcode::BLEZL:
                        ctl.flag_sel = selector::FLAG_LE;
                    main_opcode::BGTZ,main_opcode::BGTZL:
                        ctl.flag_sel = selector::FLAG_GT;
                endcase
            end

            main_opcode::ADDI,main_opcode::ADDIU: begin
                {ctl.alu_funct ,ctl.reg_src,
                 ctl.alu_srcA, ctl.alu_srcB  ,ctl.dest_reg} = 
                {selector::ALU_ADD,     selector::REG_SRC_ALU,
                 selector::ALU_SRCA_RS, selector::ALU_SRCB_SIGN_IMMED,
                 selector::DEST_REG_RT};
                ctl.write_reg = 1;
                if(unpack.opcode == main_opcode::ADDI)
                    ctl.exc_chk = selector::EXC_CHK_OVERFLOW;
            end

            main_opcode::SLTI,main_opcode::SLTIU: begin
                {ctl.alu_funct, ctl.reg_src,
                 ctl.alu_srcA,  ctl.alu_srcB, ctl.dest_reg} = 
                {selector::ALU_ADD,     selector::REG_SRC_FLAG,
                 selector::ALU_SRCA_RS, selector::ALU_SRCB_SIGN_IMMED,
                 selector::DEST_REG_RT};
                if(unpack.opcode == main_opcode::SLTIU)
                    ctl.flag_sel = selector::FLAG_LTU;
                else
                    ctl.flag_sel = selector::FLAG_LT;
            end

            main_opcode::ANDI,main_opcode::ORI,main_opcode::XORI: begin
                {ctl.alu_funct, ctl.reg_src,
                 ctl.alu_srcA,  ctl.alu_srcB, ctl.dest_reg} = 
                {selector::ALU_ADD,     selector::REG_SRC_ALU,
                 selector::ALU_SRCA_RS, selector::ALU_SRCB_SIGN_IMMED,
                 selector::DEST_REG_RT};
                case(unpack.opcode)
                    main_opcode::ANDI:
                        ctl.alu_funct = selector::ALU_AND;
                    main_opcode::ORI:
                        ctl.alu_funct = selector::ALU_OR;
                    main_opcode::XORI:
                        ctl.alu_funct = selector::ALU_XOR;
                endcase
            end
            
            // main_opcode::LUI: begin /************NOT COMPETE**********/
            //     ctl = '{ALU_NCARE,      ALU_SRCA_RS,   ALU_SRCB_IMMED,
            //             DEST_REG_RT,    PC_SRC_NEXT,   FLAG_NCARE, 
            //             EXC_CHK_NONE,   REG_SRC_ALU,   1'b1,     1'b0};
            // end
            

            default:
                ctl.exc_chk = selector::EXC_CHK_RESERVERD;
        endcase
    end
endmodule

`endif
