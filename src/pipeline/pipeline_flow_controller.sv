`ifndef PIPELINE_FLOW_CONTROLLER__
`define PIPELINE_FLOW_CONTROLLER__


`include "src/common/util.sv"
`include "src/common/encode/main_opcode.sv"
`include "src/pipeline/pipeline_interface.sv"
/*

*/

module pipeline_flow_controller(
pipeline_interface.controller pif_decode,pif_execute,
pif_memory,pif_write_back,
input logic execute_busy,
output logic load,
output logic[31:0] pc,
output logic stall_fetch);

    pipeline_signal_t ps_decode,ps_execute,ps_memory,ps_write_back;

    assign ps_decode = pif_decode.signal_out;
    assign ps_execute = pif_execute.signal_out;
    assign ps_memory = pif_memory.signal_out;
    assign ps_write_back = pif_write_back.signal_out;

    signals::unpack_t execute_unpack,decode_unpack;
    extract_instruction execute_ei(.instruction( pif_execute.signal_out.instruction),
    .ei(execute_unpack));

    extract_instruction decode_ei(.instruction( pif_decode.signal_out.instruction),
    .ei(decode_unpack));

    always_comb begin
        load = '0;
        pc = 'x;
        stall_fetch = '0;
        pif_decode.nullify = '0;     pif_decode.stall = '0;
        pif_execute.nullify = '0;    pif_execute.stall = '0;
        pif_memory.nullify = '0;     pif_memory.stall = '0;
        pif_write_back.nullify = '0; pif_write_back.stall = '0;

        pif_decode.bubble = '0;
        pif_execute.bubble = '0;
        pif_memory.bubble = '0;
        pif_write_back.bubble = '0;

/******************** clear control hazard  ****************/
        //decode  J,JAL
        if(ps_decode.control.pc_src == selector::PC_SRC_JUMP) begin
            load = '1;
            pc = ps_decode.pcjump;
            pif_decode.nullify = '1;
        end

        //execute BEQ,BNE,BEQL,BNEL,BLEZ,BGTZ
        if(ps_execute.control.pc_src === selector::PC_SRC_BRANCH & 
            ps_execute.flag_selected === '1) begin
                load = '1;
                pc = ps_execute.pc_branch;
                pif_decode.nullify = '1;
                pif_execute.nullify = '1;
        end
/************** stall or bubble to clear data hazard  **********/
        if(execute_busy) begin
            stall_fetch = '1;
            pif_decode.stall = '1;
            pif_execute.stall = '1;
            pif_memory.stall = '1;
            pif_write_back.stall = '1;
        end
    end
endmodule

`endif
