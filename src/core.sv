`ifndef CORE__
`define CORE__
`include "src/pipeline/stage_fetch.sv"
`include "src/pipeline/stage_decode.sv"
`include "src/pipeline/stage_execute.sv"
`include "src/pipeline/stage_memory.sv"
`include "src/pipeline/stage_write_back.sv"
`include "src/pipeline/forward/main_forwarder.sv"
`include "src/pipeline/pipeline_flow_controller.sv"
module core(input logic clk,reset,
memory_interface.read_only_controller ins_mif,
memory_interface.controller data_mif);

    pipeline_interface pif_fetch(.clk(clk),.reset(reset)),
	pif_decode(.clk(clk),.reset(reset)),
	pif_execute(.clk(clk),.reset(reset)),
    pif_memory(.clk(clk),.reset(reset)),
    pif_write_back(.clk(clk),.reset(reset));

    logic load_pc;
    logic[31:0] pc_value;
    logic data_memory_busy,instruction_memory_busy;
    logic execute_busy;
    logic stall_fetch;



    forward_info_t decode_forward_info,execute_forward_info;
    main_forwarder unit_forwarder( 
    .ps_decode(pif_decode.signal_out),
    .ps_execute(pif_execute.signal_out),
    .ps_memory(pif_memory.signal_out),
    .ps_write_back(pif_write_back.signal_out),
    .decode_forward_info(decode_forward_info),
    .execute_forward_info(execute_forward_info));


    pipeline_flow_controller unit_flow_controller
    (.pif_decode(pif_decode),
    .pif_execute(pif_execute),
    .pif_memory(pif_memory),
    .pif_write_back(pif_write_back),
    .execute_busy(execute_busy),.data_memory_busy(data_memory_busy),
    .instruction_memory_busy(instruction_memory_busy),
    .load(load_pc),
    .pc(pc_value),
    .stall_fetch(stall_fetch));


    stage_fetch unit_fetch(.clk(clk),.reset(reset),
    .stall(stall_fetch), .load(load_pc), .pc_in(pc_value),
    .mif(ins_mif),
    .instruction(pif_decode.signal_in.instruction),
    .pc(pif_decode.signal_in.pc),
    .pc_add4(pif_decode.signal_in.pcadd4));

    stage_decode unit_decode(.pif(pif_decode),
        .forward(decode_forward_info));
    


    stage_execute unit_execute(.pif(pif_execute),
        .forward(execute_forward_info),.wait_result(execute_busy),
        .llbit(1'b0));


    stage_memory  unit_memory(.pif(pif_memory), .mif(data_mif)
        ,.busy(data_memory_busy));


    stage_write_back unit_write_back(.pif(pif_write_back));


    assign pif_execute.signal_in = pif_decode.signal_out;
    assign pif_memory.signal_in  = pif_execute.signal_out;
    assign pif_write_back.signal_in = pif_memory.signal_out;

    assign pif_decode.signal_in.dest_reg       = pif_write_back.signal_out.dest_reg;
    assign pif_decode.signal_in.dest_reg_data  = pif_write_back.signal_out.dest_reg_data;
    assign pif_decode.signal_in.control.write_reg = pif_write_back.signal_out.control.write_reg;
    assign pif_decode.signal_in.control.write_hi  = pif_memory.signal_out.control.write_hi;
    assign pif_decode.signal_in.control.write_lo  = pif_memory.signal_out.control.write_lo;
    assign pif_decode.signal_in.dest_hi_data  = pif_memory.signal_out.dest_hi_data;
    assign pif_decode.signal_in.dest_lo_data  = pif_memory.signal_out.dest_lo_data;
    assign instruction_memory_busy = ins_mif.busy;

endmodule

`endif
