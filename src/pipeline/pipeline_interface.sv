`ifndef PIPLINE_INTERFACE__
`define PIPLINE_INTERFACE__

`include "src/common/signals.sv"


typedef struct 
{
    /*signal::unpack_t unpack;*/
    signals::control_t control;
    signals::flag_t flag;
    logic[31:0] pc,pcadd4; //fetch
    logic[31:0] instruction,rs,rt,cp0; //decode
    logic[31:0] pcjump;
    logic[31:0] alu_out,dest_reg_data; //execute
    logic[31:0] mem_data;  // memory
    logic[4:0]  dest_reg; //fetch->write_back
} pipeline_signal_t;


interface pipeline_interface (input logic clk,reset);
    logic nullify,stall;
    pipeline_signal_t signal_in;
    pipeline_signal_t signal_out;

    modport port(input clk,reset,nullify,stall,signal_in,
    output signal_out);
endinterface

`endif

