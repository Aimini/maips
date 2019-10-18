`include "src/common/signals.sv"

package decoder_util;
    function automatic signals::control_t get_default_control();
        signals::control_t ret =signals::get_clear_control();
        ret.opd_use  = selector::OPERAND_USE_BOTH;
        return ret;
    endfunction

    function automatic signals::control_t get_standard_control();
        signals::control_t ret =signals::get_clear_control();
        ret.alu_srcA = selector::ALU_SRCA_RS;
        ret.alu_srcB = selector::ALU_SRCB_RT;
        ret.opd_use  = selector::OPERAND_USE_BOTH;
        return ret;
    endfunction

    function automatic signals::control_t get_sign_immed_control();
        signals::control_t ret = get_default_control();
        ret.alu_srcA = selector::ALU_SRCA_RS;
        ret.alu_srcB = selector::ALU_SRCB_SIGN_IMMED;
        return ret;
    endfunction

    function automatic signals::control_t get_zero_immed_control();
        signals::control_t ret = get_default_control();
        ret.alu_srcA = selector::ALU_SRCA_RS;
        ret.alu_srcB = selector::ALU_SRCB_IMMED;
        return ret;
    endfunction

    function automatic signals::control_t get_up_immed_control();
        signals::control_t ret = get_default_control();
        ret.alu_srcA = selector::ALU_SRCA_RS;
        ret.alu_srcB = selector::ALU_SRCB_UP_IMMED;
        return ret;
    endfunction

    function automatic signals::control_t get_mem_addr_control();
        signals::control_t ret = get_default_control();
        ret.alu_srcA = selector::ALU_SRCA_RS;
        ret.alu_srcB = selector::ALU_SRCB_SIGN_IMMED;
        ret.alu_funct = selector::ALU_ADD;
        return ret;
    endfunction

    function automatic void write_rt(ref signals::control_t  ctl,input selector::register_source reg_src);
        ctl.write_reg = '1;
        ctl.dest_reg = selector::DEST_REG_RT;
        ctl.reg_src = reg_src;
    endfunction

    function automatic void write_alu_to_rt(ref signals::control_t  ctl,input selector::alu_function funct);
        write_rt(ctl,selector::REG_SRC_ALU);
        ctl.alu_funct = funct;
    endfunction

    function automatic void write_flag_to_rt(ref signals::control_t  ctl,input selector::flag_select sel);
        write_rt(ctl,selector::REG_SRC_FLAG);
        ctl.flag_sel = sel;
    endfunction

    function automatic void branch_with(ref signals::control_t  ctl,input selector::flag_select sel);
        ctl.pc_src = selector::PC_SRC_BRANCH;
        ctl.flag_sel = sel;
    endfunction


    /** rtype **/
    function automatic void write_rd(ref signals::control_t  ctl,input selector::register_source src);
        ctl.write_reg = '1;
        ctl.dest_reg = selector::DEST_REG_RD;
        ctl.reg_src = src;
    endfunction

    function automatic void write_alu_to_rd(ref signals::control_t  ctl,input selector::alu_function funct);
        write_rd(ctl,selector::REG_SRC_ALU);
        ctl.alu_funct = funct;
    endfunction

    function automatic void write_flag_to_rd(ref signals::control_t  ctl,input selector::flag_select sel);
        write_rd(ctl,selector::REG_SRC_FLAG);
        ctl.flag_sel = sel;
    endfunction
    
    // exclude shift
    function automatic signals::control_t get_alu_rtype_control(input selector::alu_function funct);
        signals::control_t ctl = get_standard_control();
        write_alu_to_rd(ctl,funct);
        return ctl;
    endfunction

    function automatic signals::control_t get_shift_rtype_control(input selector::alu_function funct,input logic using_rs);
        signals::control_t ctl = get_default_control();
        ctl.alu_srcB = selector::ALU_SRCB_RT;
        if(using_rs) begin
            ctl.alu_srcSa = selector::ALU_SRCSA_RS;
        end else begin
            ctl.alu_srcSa = selector::ALU_SRCSA_SA;
        end
        write_alu_to_rd(ctl,funct);
        return ctl;
    endfunction
endpackage