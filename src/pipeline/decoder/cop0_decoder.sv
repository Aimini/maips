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
                ctl.cop0_src =  selector::COP0_SRC_RT;
                ctl.dest_cop0 =  selector::DEST_COP0_RDSEL;
                ctl.write_cop0 = '1;
            end
            
            cop0::MFC0: begin
                ctl.opd_use  = selector::OPERAND_USE_NONE;
                decoder_util::write_rt(ctl,selector::REG_SRC_COP0);
            end

        
            default:
                if(cop0::match_c0funct(unpack.rs)) begin
                    case(unpack.funct)
                         cop0::ERET: begin
                            ctl.opd_use =   selector::OPERAND_USE_NONE;

                            ctl.pc_src =    selector::PC_SRC_ERET;
                            ctl.cop0_src =  selector::COP0_SRC_STATUS;
                            ctl.dest_cop0 = selector::DEST_COP0_STATUS;
                            ctl.write_cop0 = '1;
                            ctl.eret = '1;
                         end

                         default:
                            {ctl.opd_use, ctl.pc_src, ctl.exc_chk}  = 
                            {selector::OPERAND_USE_NONE, selector::PC_SRC_EXECPTION, selector::EXC_CHK_RESERVERD};
                    endcase
                end else begin
                    {ctl.opd_use, ctl.pc_src, ctl.exc_chk}  = 
                    {selector::OPERAND_USE_NONE, selector::PC_SRC_EXECPTION, selector::EXC_CHK_RESERVERD};
                end
        endcase
    end
endmodule
`endif