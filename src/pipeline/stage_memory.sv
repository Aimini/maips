`ifndef STAGE_MEMORY__
`define STAGE_MEMORY__

`include "src/common/signals.sv"
`include "src/pipeline/pipeline_interface.sv"
`include "src/pipeline/pipeline_base.sv"
`include "src/pipeline/stage_memory_partial/stage_memory_load_store.sv"

module stage_memory(pipeline_interface.port pif,
    memory_interface.memory mif,
    output logic address_error);

    logic[31:0] mem_data_out,mem_data_in,mem_addr;
    logic write_mem;

    selector::mem_read_type read_mode;
    selector::mem_write_type write_mode;

    pipeline_interface reconnect(.clk(pif.clk),.reset(pif.reset));

    pipeline_base unit_pb(reconnect);

    stage_memory_load_store #(32) unit_load_store
        (.read_mode(read_mode),.write_mode(write_mode),
        .write_mem(write_mem),.data_in(mem_data_in),
        .mif(mif),
        .addr_in(mem_addr),
        .data_out(mem_data_out),
        .address_error(address_error));
     /* control signal*/


    always_comb begin
        reconnect.signal_in = pif.signal_in;
        reconnect.nullify = pif.nullify;
        reconnect.stall = pif.stall;

        pif.signal_out = reconnect.signal_out;
        pif.signal_out.mem_data = mem_data_out;

        mem_data_in = pif.signal_out.rt;
        mem_addr    = pif.signal_out.alu_out;
        write_mem   = pif.signal_out.control.write_mem;
        read_mode   = pif.signal_out.control.read_mode;
        write_mode  = pif.signal_out.control.write_mode;
    end
endmodule
`endif
