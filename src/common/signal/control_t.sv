

typedef struct{
    selector::alu_function alu_funct;
    selector::alu_sourceA alu_srcA;
    selector::alu_sourceB alu_srcB; 
    selector::alu_sourceShift alu_srcSa;
    selector::destnation_regiter dest_reg;
    selector::pc_source pc_src;
    selector::flag_select flag_sel;
    selector::register_source reg_src;
    selector::mem_read_type read_mode;
    selector::mem_write_type write_mode;
    selector::operand_use opd_use;
    
    selector::execption_check_t exc_chk;
    logic write_reg;
    logic write_cp0;
    logic write_mem;
    logic di,ie;
} control_t;

function control_t nullify_control(input control_t ctl);
    ctl.pc_src  = selector::PC_SRC_NEXT;
    ctl.exc_chk = selector::EXC_CHK_NONE;
    ctl.write_mem = '0;
    ctl.write_reg = '0;
    ctl.write_cp0 = '0;
    ctl.di = '0;
    ctl.ie = '0;
    return ctl;
endfunction