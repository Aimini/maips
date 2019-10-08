`ifndef SINGLE_FORWARDER__
`define SINGLE_FORWARDER__



module single_forwarder(input pipeline_signal_t ps_forward,ps_accept,
output forward_info_t finfo
 );
     signals::unpack_t unpack;
    automatic function  logic[32:0] check_fowrd(
        input pipeline_signal_t ps_forward,
        input pipeline_signal_t ps_accept,
        input signals::unpack_t up
        logic rs_nrt);
        logic[4:0] dest_reg = rs_nrt ? up.rs : up.rt;
        selector::operand_use ope = (rs_nrt ? selector::OPERAND_USE_RS : selector::OPERAND_USE_RT);
        if(ps.control.write_reg & ps.dest_reg == dest_reg)
            if(ps_accept.control.opd_use == ope |
               ps_accept.control.opd_use == selector::OPERAND_USE_BOTH)
            return {1'b1, ps_forward.dset_reg_data};
        return {1'b0, 32'bx};
    endfunction

    extract_instruction execute_ei(.instruction(ps_accept.instruction),
    .ei(unpack));

    alway_comb begin
         {froward_execute_info.forward_rs,
        froward_execute_info.rs} = 
        check_fowrd(ps_forward,ps_accept,unpack, 1);
        {froward_execute_info.forward_rt,
        froward_execute_info.rt} = 
        check_fowrd(ps_forward,ps_accept,unpack, 0);
    end
endmodule

`endif