`ifndef STAGE_MEMORY__
`define STAGE_MEMORY__

`include "src/common/signals.sv"
`include "src/pipeline/pipeline_interface.sv"
`include "src/pipeline/pipeline_base.sv"
`include "src/pipeline/stage_memory_partial/stage_memory_load_store.sv"

module stage_memory(pipeline_interface.port pif,
    memory_interface.controller mif, output logic busy);

    logic[31:0] register_data,processed_data;
    logic[31:0] mem_data_out,mem_data_in,mem_addr;
    logic[3:0] byte_mask;
    logic write_mem;
    logic prev_stall;
    
    selector::mem_read_type read_mode;
    selector::mem_write_type write_mode;

    pipeline_interface reconnect(.clk(pif.clk),.reset(pif.reset));

    pipeline_base unit_pb(.pif(reconnect),.nullify_instruction('0));

    stage_memory_load_store #(32) unit_load_store
        (.read_mode(read_mode),.write_mode(write_mode),
        .register_data(register_data), .mem_data_out(mem_data_out),
        .processed_data(processed_data), .mem_data_in(mem_data_in),
        .addr(mem_addr),.byte_mask(byte_mask));
     /* control signal*/


    `COPY_PIPELINE_BASE(assign,pif,reconnect);
    
    always_ff @(posedge pif.clk) begin
        if(pif.reset)
            prev_stall <= 0;
        else
            prev_stall <= pif.stall | pif.bubble;
    end

    always_comb begin
        pif.signal_out = reconnect.signal_out;        
        if(pif.signal_out.cop0_excdata.exception_happen) begin
            pif.signal_out.dest_llbit_data = '0;
            pif.signal_out.control.write_llbit = '1;
        end
        pif.signal_out.mem_data = processed_data;
    end

    always_comb begin
        register_data  = pif.signal_out.rt;

        write_mem   = pif.signal_out.control.write_mem;
        read_mode   = pif.signal_out.control.read_mode;
        write_mode  = pif.signal_out.control.write_mode;
        mem_addr    = pif.signal_out.mem_addr;

        mif.addr = pif.signal_out.mem_addr;
        mif.din  = mem_data_in;
        mif.write  =  write_mem & ~(prev_stall);
        mif.mask = byte_mask;
        mif.read = pif.signal_out.control.read_mem;

        mem_data_out = mif.dout;
    end
endmodule
`endif
