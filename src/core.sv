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
memory_interface.controller ins_mif, data_mif);

    pipeline_interface pif_fetch(.clk(clk),.reset(reset)),
	pif_decode(.clk(clk),.reset(reset)),
	pif_execute(.clk(clk),.reset(reset)),
    pif_memory(.clk(clk),.reset(reset)),
    pif_write_back(.clk(clk),.reset(reset));

    logic address_error;
    logic load_pc;
    logic[31:0] pc_value;
    logic data_memory_busy,instruction_memory_busy;

    stage_fetch unit_fetch(.clk(clk),.reset(reset),
    .stall(1'b0), .nullify(1'b0),
    .load(load_pc), .pc_in(pc_value),
    .iaddr(ins_mif.addr), .idata(ins_mif.dout),
    .wait_memory(ins_mif.busy),
    .instruction(pif_decode.signal_in.instruction),
    .pc(pif_decode.signal_in.pc),
    .pc_add4(pif_decode.signal_in.pcadd4));



    forward_info_t decode_forward_info,execute_forward_info;
    main_forwarder unit_forwarder( 
    .ps_decode(pif_decode.signal_out),
    .ps_execute(pif_execute.signal_out),
    .ps_memory(pif_memory.signal_out),
    .ps_write_back(pif_write_back.signal_out),
    .decode_forward_info(decode_forward_info),
    .execute_forward_info(execute_forward_info));



    pipeline_flow_controller unit_flow_controller
    (.ps_decode(pif_decode.signal_out),
    .ps_execute(pif_execute.signal_out),
    .ps_memory(pif_memory.signal_out),
    .ps_write_back(pif_write_back.signal_out),
    .load(load_pc),
    .pc(pc_value),
    .nullify_decode(pif_decode.nullify),
    .nullify_execute(pif_execute.nullify));



    stage_decode unit_decode(.pif(pif_decode),
        .forward(decode_forward_info));
    


    stage_execute unit_execute(.pif(pif_execute),
        .forward(execute_forward_info),
        .llbit(1'b0));


    stage_memory  unit_memory(.pif(pif_memory), .mif(data_mif)
        ,.busy(data_memory_busy));



    stage_write_back unit_write_back(.pif(pif_write_back));


    always_comb begin
        pif_execute.signal_in = pif_decode.signal_out;
        pif_memory.signal_in  = pif_execute.signal_out;
        pif_write_back.signal_in = pif_memory.signal_out;

        pif_decode.signal_in.dest_reg = pif_write_back.signal_out.dest_reg;
        pif_decode.signal_in.dest_reg_data = pif_write_back.signal_out.dest_reg_data;
        pif_decode.signal_in.control.write_reg = pif_write_back.signal_out.control.write_reg;
        pif_decode.signal_in.control.write_hi  = pif_memory.signal_out.control.write_hi;
        pif_decode.signal_in.control.write_lo  = pif_memory.signal_out.control.write_lo;
        pif_decode.signal_in.dest_hi_data  = pif_memory.signal_out.dest_hi_data;
        pif_decode.signal_in.dest_lo_data  = pif_memory.signal_out.dest_lo_data;

        pif_memory.nullify = 0;
        pif_write_back.nullify = 0;

        pif_decode.stall = 0;
        pif_execute.stall = 0;
        pif_memory.stall = 0;
        pif_write_back.stall = 0;
    end
endmodule

`endif
