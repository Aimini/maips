`ifndef MAIN_FORWARD__
`define MAIN_FORWARD__


`include "src/common/util.sv"
`include "src/pipeline/pipeline_interface.sv"

typedef struct{
    logic f;
    logic[31:0] data;
} fowrad_element_t;


typedef struct {
    fowrad_element_t rs,rt,lo,hi,cop0;

    fowrad_element_t EPC,ErrorEPC,Status,EBase;
} forward_info_t;


function automatic void process_forward_data(
    ref pipeline_signal_t ps,
    input forward_info_t forward_info);
`define PROC_GPR(name)  ps.name = forward_info.name.f ? forward_info.name.data : ps.name;
        `PROC_GPR(rs)
        `PROC_GPR(rt)
`undef PROC_GPR

        ps.hi = forward_info.hi.f   ? forward_info.hi.data   : ps.hi;
        ps.lo = forward_info.lo.f   ? forward_info.lo.data   : ps.lo;
        ps.cop0 = forward_info.cop0.f  ? forward_info.cop0.data :  ps.cop0;
`define PROC_EXEREG(name)  ps.cop0excreg.name = forward_info.name.f ? forward_info.name.data : ps.cop0excreg.name;
        `PROC_EXEREG(EPC)
        `PROC_EXEREG(ErrorEPC)
        `PROC_EXEREG(Status)
        `PROC_EXEREG(EBase)
`undef PROC_EXEREG
endfunction

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

    function automatic fowrad_element_t test_cp0(input pipeline_signal_t ps, logic [4:0] rd,logic [4:0] sel);
        if(ps.control.write_cop0 !== 0) begin
            if(ps.dest_cop0_rd === rd &&  ps.dest_cop0_sel === sel) begin
                return fowrad_element_t'{f:'1 , data: ps.dest_cop0_data};
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
        /********* cop0 *********************/
        if(ps_memory.control.write_cop0) begin
            execute_forward_info.cop0 = test_cp0(ps_memory,execute_unpack.rd,execute_unpack.sel);
            decode_forward_info.cop0  = test_cp0(ps_memory,decode_unpack.rd, decode_unpack.sel);
        end

        /********* cop0  exception associated register*********************/
        if(ps_memory.control.write_cop0) begin
            execute_forward_info.EPC = test_cp0(ps_memory,cop0_info::RD_EPC,cop0_info::SEL_EPC);
            decode_forward_info.EPC  = test_cp0(ps_memory,cop0_info::RD_EPC,cop0_info::SEL_EPC);

            execute_forward_info.ErrorEPC = test_cp0(ps_memory,cop0_info::RD_ERROREPC,cop0_info::SEL_ERROREPC);
            decode_forward_info.ErrorEPC  = test_cp0(ps_memory,cop0_info::RD_ERROREPC,cop0_info::SEL_ERROREPC);

            execute_forward_info.Status = test_cp0(ps_memory,cop0_info::RD_STATUS,cop0_info::SEL_STATUS);
            decode_forward_info.Status  = test_cp0(ps_memory,cop0_info::RD_STATUS,cop0_info::SEL_STATUS);

            execute_forward_info.EBase = test_cp0(ps_memory,cop0_info::RD_EBASE,cop0_info::SEL_EBASE);
            decode_forward_info.EBase  = test_cp0(ps_memory,cop0_info::RD_EBASE,cop0_info::SEL_EBASE);
        end
    end
  
endmodule

`endif
