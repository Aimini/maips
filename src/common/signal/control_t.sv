typedef struct{
    /** alu function ***/
    selector::alu_function alu_funct;
    selector::alu_sourceA alu_srcA;
    selector::alu_sourceB alu_srcB; 
    selector::alu_shift_source alu_srcSa;

    selector::muldiv_function muldiv_funct;
    selector::hilo_source hilo_src;

    selector::destnation_regiter dest_reg;
    selector::pc_source pc_src;
    selector::flag_select flag_sel;
    selector::register_source reg_src;

    selector::mem_write_condition mem_write_cond;
    selector::mem_read_type read_mode;
    selector::mem_write_type write_mode;

    selector::operand_use opd_use;
    selector::write_register_condition write_cond;
    selector::execption_check_t exc_chk;
    
    selector::cop0_source cop0_src;
    selector::destnation_cop0 dest_cop0;


    logic write_cop0;
    logic write_reg;
    logic read_mem;
    logic write_mem;
    logic write_hi,write_lo;
    logic write_llbit;
    
} control_t;

function automatic control_t nullify_control(input control_t ctl);
    ctl.pc_src  = selector::PC_SRC_NEXT;
    ctl.exc_chk = selector::EXC_CHK_NONE;
    ctl.write_cond =selector::REG_WRITE_ALWAYS;
    ctl.mem_write_cond = selector::MEM_WRITE_KEEP;
    ctl.read_mem ='0;
    ctl.write_cop0 =  '0;
    ctl.write_mem = '0;
    ctl.write_reg = '0;
    ctl.write_hi = '0;
    ctl.write_lo = '0;
    ctl.write_llbit = '0;
    return ctl;
endfunction


function automatic control_t get_clear_control();
    return control_t'{
        selector::ALU_NCARE,        selector::ALU_SRCA_NCARE,   selector::ALU_SRCB_NCARE,
        selector::ALU_SRCSA_NCARE,  selector::MULDIV_NCARE,     selector::HILO_SRC_NCARE,
        selector::DEST_REG_NCARE,   selector::PC_SRC_NEXT,      selector::FLAG_NCARE,
        selector::REG_SRC_NCARE,    selector::MEM_WRITE_KEEP,   selector::MEM_READ_NCARE,   selector::MEM_WRITE_NCARE,
        selector::OPERAND_USE_NONE, selector::REG_WRITE_ALWAYS, selector::EXC_CHK_NONE,
        selector::COP0_SRC_NCARE,   selector::DEST_COP0_NCARE,
        1'b0,1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0
    };
endfunction
