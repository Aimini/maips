`ifndef PIPLINE_INTERFACE__
`define PIPLINE_INTERFACE__

`include "src/common/signals.sv"


typedef struct 
{
    /*signal::unpack_t unpack;*/
    signals::control_t control;
    signals::flag_t flag;
    logic[31:0] pc,pcadd4,pcadd8,pcsub4; //fetch
    logic[31:0] instruction,rs,rt; //decode
    
    logic[31:0] cop0;               //decode
    logic[31:0] dest_cop0_data;     //memory, write cop0
    logic[4:0]  dest_cop0_rd;     //memory, write cop0
    logic[2:0]  dest_cop0_sel;     //memory, write cop0

    logic[31:0] lo,hi;
    logic[31:0] pcjump,pc_branch;
    logic[31:0] alu_out,dest_reg_data; //execute
    logic[31:0] dest_lo_data,dest_hi_data;
    logic[31:0] mem_addr; //execute

    logic flag_selected;
    logic[31:0] mem_data;  // memory
    logic[4:0]  dest_reg; //fetch->write_back
} pipeline_signal_t;


interface pipeline_interface (input logic clk,reset);
    /**
        stall and bubble have same effect at most time, but
        for multiple cycle element like multiplyer and divider,
        stall meaning you can still caculate with correct operand.
        bubble meaning that you must wait some instruction  
        to get result anf forwarding to you.
        for example :
         lw $s0, 0($t0) # foward result at writeback
         mult $s0,$s1   # Ops ! I' need $s0 and excute!
         # in this case, lw will produce a bubble for mult, mult can't 
         start caculate before get $s0.
        and for example:
          lw $s0, 0($t0)   # writeback
          xori $s1,$0, 0x3 # memory
          mult $s0,$s1    # excute
          # in this case, when lw wait memory read, lw create a
          # stall;but mult can caculate with correct operand!
        
    **/
    logic nullify,stall,bubble;
    
    pipeline_signal_t signal_in;
    pipeline_signal_t signal_out;

    modport port(input clk,reset,nullify,stall,bubble,signal_in,
    output signal_out);
    modport controller(input signal_out,
    output nullify,stall,bubble);
endinterface

`endif

