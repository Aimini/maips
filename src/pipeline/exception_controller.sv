`ifndef __EXCEPTION_CONTROLLER__
`define __EXCEPTION_CONTROLLER__

`include "src/memory/cop0/cop0_info.sv"
`include "src/pipeline/pipeline_interface.sv"
`include "src/pipeline/stage_execute_partial/address_error_checker.sv"
module exception_controller(
 input pipeline_signal_t ps_execute, ps_memory,
 output cop0_info::cop0_exc_data_t exc_data,
 input logic[5:0] hardware_int,
 output logic[31:0] exc_addr,
 output logic exception_happen, any_interrupt, accept_hardware_interrupt);
    
    const logic[4:0] EXCCODE_INT  =  5'h0;
    const logic[4:0] EXCCODE_ADEL =  5'h4;
    const logic[4:0] EXCCODE_ADES =  5'h5;
    const logic[4:0] EXCCODE_SYS =   5'h8;
    const logic[4:0] EXCCODE_BP =    5'h9;
    const logic[4:0] EXCCODE_RI =    5'hA;
    const logic[4:0] EXCCODE_CU =    5'hB;
    const logic[4:0] EXCCODE_OV =    5'hC;
    const logic[4:0] EXCCODE_TR =    5'hD;

    logic[31:0] addr_offset;
    logic[31:0] status,cause;
    logic in_kernel_mode,read_mem,write_mem;
    logic read_error,store_error;
    logic interrupt_main_enable;
    signals::control_t p_ctl;
    signals::unpack_t unpack;

    /*****************  check interrupt ************************/
    logic[1:0] soft_interrupt;
    logic[7:0] interrupt_masked;
    // 6 interrupt, 2 level synchronizer
    always_comb begin
    `ifndef GET_STATUS_SOFT_INT
    `define GET_STATUS_SOFT_INT(_PS) \
        (_PS.cop0_excreg.Cause[cop0_info::IDX_CAUSE_IP_S +: 2])
    `endif
        
        
        
        // rasing edge
        interrupt_main_enable = status[cop0_info::IDX_STATUS_IE] 
         & ~(status[cop0_info::IDX_STATUS_EXL] | status[cop0_info::IDX_STATUS_ERL]);

        soft_interrupt = (`GET_STATUS_SOFT_INT(ps_execute) & ~`GET_STATUS_SOFT_INT(ps_memory));
        interrupt_masked =  {hardware_int,soft_interrupt} & status[cop0_info::IDX_STATUS_IM_E:cop0_info::IDX_STATUS_IM_S];
        interrupt_masked =  {8{interrupt_main_enable}} & interrupt_masked;
        any_interrupt =  | (interrupt_masked);
        exc_data.ext_int = interrupt_masked[7:2];
        accept_hardware_interrupt = | (exc_data.ext_int);
    end
    `undef GET_STATUS_SOFT_INT


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
    assign read_mem  = p_ctl.read_mem;
    assign write_mem = p_ctl.write_mem;

    assign status = ps_execute.cop0_excreg.Status;
    assign cause  = ps_execute.cop0_excreg.Cause;
    assign in_kernel_mode = status[cop0_info::IDX_STATUS_ERL] 
        | status[cop0_info::IDX_STATUS_EXL] | ~status[cop0_info::IDX_STATUS_UM];

    always_comb begin : generate_exception_code_control
        exception_happen = '0;
        exc_data.exc_code = 'x;

        exc_data.load_addr = '0;
        exc_data.badvaddr = 'x;

        exc_data.load_ce = '0;
        exc_data.ce = 'x;
        
     // prevent nullified pipeline signal cause accident exception
        if(any_interrupt) begin
            exception_happen = '1;
            exc_data.exc_code = EXCCODE_INT;
        end else if(ps_execute.fetch) begin            
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
            if(~in_kernel_mode & unpack.opcode === main_opcode::COP0) begin
                exc_data.load_ce = '1;
                exc_data.ce = '0;
                exc_data.exc_code = EXCCODE_CU;
                exception_happen = '1;
            end
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
        if(exc_data.exc_code === EXCCODE_INT && cause[cop0_info::IDX_CAUSE_IV])
            addr_offset = 32'h200;
        else
            addr_offset = 32'h180;
        if(ps_execute.cop0_excreg.Status[cop0_info::IDX_STATUS_BEV])
            exc_addr = 32'hBFC0_0200 + addr_offset;
        else
            exc_addr = ps_execute.cop0_excreg.EBase + addr_offset;
    end
    
endmodule
`endif