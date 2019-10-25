`ifndef __COP0_DECODER__
`define __COP0_DECODER__
`include "src/common/encode/cop0.sv"
`include "src/common/signals.sv"
`include "src/pipeline/decoder/decoder_util.sv"

module cop0_decoder(input logic[31:0] instruction,output signals::control_t ctl);
  signals::unpack_t  unpack;
    extract_instruction unit_ei(instruction,unpack);
    always_comb begin
        ctl = decoder_util::get_default_control();
        case(unpack.rs)
            cop0::MTC0: begin
                ctl.opd_use  = selector::OPERAND_USE_RT;
                ctl.write_cop0 = '1;
            end
            
            cop0::MFC0: begin
                ctl.opd_use  = selector::OPERAND_USE_NONE;
                decoder_util::write_rt(ctl,selector::REG_SRC_COP0);
            end
        
            default:
                {ctl.opd_use, ctl.pc_src, ctl.exc_chk}  = 
                {selector::OPERAND_USE_NONE, selector::PC_SRC_EXECPTION, selector::EXC_CHK_RESERVERD};
        endcase
    end
endmodule
`endif