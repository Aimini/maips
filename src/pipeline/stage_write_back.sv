`ifndef STAGE_WRITE_BACK__
`define STAGE_WRITE_BACK__

`include "src/pipeline/pipeline_interface.sv"
module stage_write_back(pipeline_interface.port pif);
    
    pipeline_interface reconnect(.clk(pif.clk),.reset(pif.reset));

    pipeline_base unit_pb(.pif(reconnect),.nullify_instruction('0));
    
    `COPY_PIPELINE_BASE(assign,pif,reconnect);

    always_comb begin
        pif.signal_out = reconnect.signal_out;
        pif.signal_out.dest_reg_data = 
            (pif.signal_out.control.reg_src == selector::REG_SRC_MEM) ?
                reconnect.signal_out.mem_data : reconnect.signal_out.dest_reg_data;             
    end
endmodule

`endif
