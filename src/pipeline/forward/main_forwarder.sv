`ifndef MAIN_FORWARD__
`define MAIN_FORWARD__


`include "src/common/util.sv"
typedef struct{
    logic f;
    logic[31:0] data;
} fowrad_element_t;


typedef struct {
    fowrad_element_t rs,rt,lo,hi;
} forward_info_t;


module main_forwarder(
input pipeline_signal_t ps_decode,ps_execute,
ps_memory,ps_write_back,
output forward_info_t decode_forward_info,
execute_forward_info);

    signals::unpack_t execute_unpack,decode_unpack;
    extract_instruction execute_ei(.instruction(ps_execute.instruction),
    .ei(execute_unpack));

    extract_instruction decode_ei(.instruction(ps_decode.instruction),
    .ei(decode_unpack));

    function  automatic  fowrad_element_t get_clear_element();
        return fowrad_element_t'{1'b0 ,  32'bx};
    endfunction

    function automatic forward_info_t get_clear_info();
        return forward_info_t'{ fowrad_element_t :  get_clear_element() };
    endfunction


     function automatic fowrad_element_t test_one(input pipeline_signal_t ps, logic [4:0] target);
        if(ps.dest_reg !== 0 & ps.control.write_reg) begin
            if(target === ps.dest_reg) begin
                return fowrad_element_t'{f:'1 , data: ps.dest_reg_data};
            end
        end
        return get_clear_element();
    endfunction

    always_comb begin
        execute_forward_info = get_clear_info(); 
        decode_forward_info  = get_clear_info();

        execute_forward_info.rs = test_one(ps_memory, execute_unpack.rs);
        execute_forward_info.rt = test_one(ps_memory, execute_unpack.rt);

        if(execute_forward_info.rs.f === '0)
            execute_forward_info.rs = test_one(ps_write_back, execute_unpack.rs);
        if(execute_forward_info.rt.f === '0)
            execute_forward_info.rt = test_one(ps_write_back, execute_unpack.rt);


        decode_forward_info.rs = test_one(ps_write_back, decode_unpack.rs);
        decode_forward_info.rt = test_one(ps_write_back, decode_unpack.rt);


        /********* lo hi ****************/
        if( ps_memory.control.write_lo) begin
            execute_forward_info.lo.f = '1;
            execute_forward_info.lo.data = ps_memory.dest_lo_data;
            decode_forward_info.lo.f = '1;
            decode_forward_info.lo.data = ps_memory.dest_lo_data;
        end

        if( ps_memory.control.write_hi) begin
            execute_forward_info.hi.f = '1;
            execute_forward_info.hi.data = ps_memory.dest_hi_data;
            decode_forward_info.hi.f = '1;
            decode_forward_info.hi.data = ps_memory.dest_hi_data;
        end 
        
    end
  
endmodule

`endif
