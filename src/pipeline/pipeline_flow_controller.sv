`ifndef PIPELINE_FLOW_CONTROLLER__
`define PIPELINE_FLOW_CONTROLLER__


`include "src/common/util.sv"
`include "src/common/encode/main_opcode.sv"
/*

*/

module pipeline_flow_controller(
input pipeline_signal_t ps_decode,ps_execute,
ps_memory,ps_write_back,
output logic load,
output logic[31:0] pc,
output logic nullify_decode,nullify_execute
  );

    signals::unpack_t execute_unpack,decode_unpack;
    extract_instruction execute_ei(.instruction(ps_execute.instruction),
    .ei(execute_unpack));

    extract_instruction decode_ei(.instruction(ps_decode.instruction),
    .ei(decode_unpack));

    always_comb begin
       load = '0;
       pc = 'x;

       nullify_decode = '0;
       nullify_execute = '0;

        //decode  J,JAL
       if(ps_decode.control.pc_src == selector::PC_SRC_JUMP) begin
            load = '1;
            pc = ps_decode.pcjump;
            nullify_decode = '1;
        end

        //execute BEQ,BNE,BEQL,BNEL,BLEZ,BGTZ
        if(ps_execute.control.pc_src == selector::PC_SRC_BRANCH & 
          ps_execute.flag_selected == '1) begin
            load = '1;
            pc = ps_execute.pc_branch;
            nullify_decode = '1;
            nullify_execute = '1;
        end    
    end
  
endmodule

`endif