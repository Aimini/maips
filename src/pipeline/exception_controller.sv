`ifndef __EXCEPTION_CONTROLLER__
`define __EXCEPTION_CONTROLLER__

`include "src/memory/cop0/cop0_info.sv"
`include "src/pipeline/pipeline_interface.sv"

module exception_controller(
 input pipeline_signal_t ps_execute, ps_memory,
 output cop0_info::cop0_exc_data_t exc_data,
 output logic[31:0] exc_addr,
 output logic exception_happen);
    
    const logic[4:0] EXCCODE_ADEL =  5'h4;
    const logic[4:0] EXCCODE_ADES =  5'h5;
    const logic[4:0] EXCCODE_SYS =   5'h8;
    const logic[4:0] EXCCODE_BP =    5'h9;
    const logic[4:0] EXCCODE_RI =    5'hA;
    const logic[4:0] EXCCODE_CU =    5'hB;
    const logic[4:0] EXCCODE_OV =    5'hC;
    const logic[4:0] EXCCODE_TR =    5'hD;
    logic[31:0] addr_offset;
    always_comb begin : generate_exception_code_control
        exception_happen = '1;
        case(ps_execute.control.exc_chk)
            selector::EXC_CHK_SYSCALL: begin
                exc_data.exc_code = EXCCODE_SYS;
            end
            selector::EXC_CHK_BREAK: begin
                exc_data.exc_code = EXCCODE_BP;
            end
            selector::EXC_CHK_TRAP: begin
                exc_data.exc_code = EXCCODE_TR;
                if(!ps_execute.flag_selected)
                    exception_happen = '0;
            end
            selector::EXC_CHK_OVERFLOW: begin
                exc_data.exc_code = EXCCODE_OV;
                if(!ps_execute.flag.overflow)
                    exception_happen = '0;
            end
            default: begin 
                exc_data.exc_code = 'x;
                exception_happen = '0;
            end
        endcase
        exc_data.exception_happen = exception_happen;
    end

    always_comb begin : generate_target_epc
        exc_data.in_bd = 'x;
        exc_data.epc = 'x;
        if(exception_happen) begin
            if(ps_memory.control.pc_src !== selector::PC_SRC_NEXT) begin
                 exc_data.epc   = ps_execute.pcsub4;
                 exc_data.in_bd = '1;
            end
            else begin
                exc_data.epc = ps_execute.pc;
                exc_data.in_bd = '0;
            end
        end
    end

    always_comb begin : exception_address
        addr_offset = 32'h180;
        if(ps_execute.cop0excreg.Status[cop0_info::IDX_STATUS_BEV])
            exc_addr = 32'hBFC0_0200 + addr_offset;
        else
            exc_addr = ps_execute.cop0excreg.EBase + addr_offset;
    end
    
endmodule
`endif