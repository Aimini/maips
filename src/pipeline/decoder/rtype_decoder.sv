`ifndef RTYPE_DECODER__
`define RTYPE_DECODER__

`include "src/common/encode/rtype_funct.sv"
`include "src/common/signals.sv"

module rtype_decoder(input logic[31:0] instruction,output signals::control_t ctl);

    signals::unpack_t  unpack;
    extract_instruction unit_ei(instruction,unpack);
    always_comb begin
        ctl = '{selector::ALU_NCARE,     selector::ALU_SRCA_RS,   selector::ALU_SRCB_RT,
                selector::DEST_REG_RD,   selector::PC_SRC_NEXT,   selector::FLAG_NCARE,
                selector::REG_SRC_NCARE, selector::MEM_READ_NCARE,selector::MEM_WRITE_NCARE,
                selector::EXC_CHK_NONE,
                1'b1,1'b0,1'b0,1'b0,1'b0};
        case(unpack.funct)
            rtype::SYSCALL: begin
                {ctl.alu_srcA, ctl.alu_srcB,
                    ctl.dest_reg, ctl.pc_src,
                    ctl.exc_chk}  = 
                {selector::ALU_SRCA_NCARE, selector::ALU_SRCB_NCARE,
                    selector::DEST_REG_NCARE, selector::PC_SRC_EXECPTION,
                    selector::EXC_CHK_SYSCALL};
                    ctl.write_reg = 0;
            end
            default:begin
                {ctl.alu_srcA, ctl.alu_srcB,
                ctl.dest_reg, ctl.pc_src,
                ctl.exc_chk}  = 
                {selector::ALU_SRCA_NCARE,selector::ALU_SRCB_NCARE,
                selector::DEST_REG_NCARE, selector::PC_SRC_EXECPTION,
                selector::EXC_CHK_RESERVERD};
                ctl.write_reg = 0;
            end
        endcase
    end
endmodule

`endif