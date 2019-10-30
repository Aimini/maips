`ifndef __EXCEPTION_CONTROLLER__
`define __EXCEPTION_CONTROLLER__

`include "src/memory/cop0/cop0_info.sv"
`include "src/pipeline/pipeline_interface.sv"
`include "src/pipeline/stage_execute_partial/address_error_checker.sv"

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
    logic[31:0] status;
    logic in_kernel_mode,read_mem,write_mem;
    logic read_error,store_error;
    signals::control_t p_ctl;
    signals::unpack_t unpack;

   /************* generate address exception *******************/
    address_error_checker unit_address_error_checker(
    .read_mode(p_ctl.read_mode),.write_mode(p_ctl.write_mode),
    .addr(ps_execute.mem_addr),  .pc(ps_execute.pc),
    .in_kernel_mode(in_kernel_mode),.read_mem(read_mem),.write_mem(write_mem),
    //------------ output 
    .read_error(read_error),.store_error(store_error));
    /*************  extract instruction *******************/
    extract_instruction unit_ei(ps_execute.instruction, unpack);

    assign p_ctl = ps_execute.control;
    assign read_mem  = (p_ctl.reg_src === selector::REG_SRC_MEM);
    assign write_mem = p_ctl.write_mem;

    assign status = ps_execute.cop0excreg.Status;
    assign in_kernel_mode = status[cop0_info::IDX_STATUS_ERL] 
        | status[cop0_info::IDX_STATUS_EXL] | ~status[cop0_info::IDX_STATUS_UM];

    always_comb begin : generate_exception_code_control
        exception_happen = '0;
        exc_data.load_addr = '0;
        exc_data.badvaddr = 'x;
        exc_data.exc_code = 'x;
        
     // prevent nullified pipeline signal cause accident exception
        if(ps_execute.fetch) begin            
            if(read_error | store_error) begin
                exception_happen = '1;
                exc_data.load_addr = '1;
                exc_data.badvaddr = ps_execute.pc;
                if(read_error) begin
                    exc_data.exc_code = EXCCODE_ADEL;
                end else begin
                    exc_data.exc_code = EXCCODE_ADES;
                end
            end else begin
                case(ps_execute.control.exc_chk)
                    selector::EXC_CHK_SYSCALL: begin
                        exc_data.exc_code = EXCCODE_SYS;
                        exception_happen = '1;
                    end
                    selector::EXC_CHK_BREAK: begin
                        exc_data.exc_code = EXCCODE_BP;
                        exception_happen = '1;
                    end
                    selector::EXC_CHK_TRAP: begin
                        exc_data.exc_code = EXCCODE_TR;
                        if(ps_execute.flag_selected)
                            exception_happen = '1;
                    end
                    selector::EXC_CHK_OVERFLOW: begin
                        exc_data.exc_code = EXCCODE_OV;
                        if(ps_execute.flag.overflow)
                            exception_happen = '1;
                    end
                    selector::EXC_CHK_RESERVERD: begin
                        exc_data.exc_code = EXCCODE_RI;
                        exception_happen = '1;
                    end
                    default: begin 
                        exc_data.exc_code = 'x;
                        exception_happen = '0;
                    end
                endcase
            end
        //if(ps_execute.instruction)
        end
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