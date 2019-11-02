`ifndef PIPLINE_INTERFACE__
`define PIPLINE_INTERFACE__

`include "src/common/signals.sv"
`include "src/memory/cop0/register_cop0.sv"

typedef struct 
{
    /*signal::unpack_t unpack;*/
    signals::control_t control;
    signals::flag_t flag;
    logic[31:0] pc,pcadd4,pcadd8,pcsub4; //fetch
    logic fetch; // you can use it to determine a valid pipline
    logic[31:0] instruction,rs,rt; //decode
    logic llbit;
    
    logic[31:0] cop0;               //decode
    logic[31:0] dest_cop0_data;     //memory, write cop0
    logic[4:0]  dest_cop0_rd;     //memory, write cop0
    logic[2:0]  dest_cop0_sel;     //memory, write cop0
    logic dest_llbit_data;
    cop0_info::cop0_excreg_t cop0_excreg;
    
    logic[31:0] lo,hi;
    logic[31:0] pcjump,pc_branch;
    logic[31:0] alu_out,dest_reg_data; //execute
    logic[31:0] dest_lo_data,dest_hi_data;
    logic[31:0] mem_addr; //execute
    
    cop0_info::cop0_exc_data_t cop0_excdata;

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
         mult $s0,$s1   # Ops ! I' need $s0 and execute!
         # in this case, lw will produce a bubble for mult, mult can't 
         start caculate before get $s0.
        and for example:
          lw $s0, 0($t0)   # writeback
          xori $s1,$0, 0x3 # memory
          mult $s0,$s1    # execute
          # in this case, when lw wait memory read, lw create a
          # stall;but mult can caculate with correct operand!
        
    **/
    logic nullify,stall,bubble,keep_exception;
    
    pipeline_signal_t signal_in;
    pipeline_signal_t signal_out;

    modport port(input clk,reset,nullify,stall,bubble,signal_in,keep_exception,
    output signal_out);
    modport controller(input signal_out,
    output nullify,stall,bubble,keep_exception);
endinterface

/*** copy pipline's base signal***/
`define  COPY_PIPELINE_BASE(ASSIGN,FROM,TO)          \
    ASSIGN TO.signal_in = FROM.signal_in;           \
    ASSIGN TO.nullify = FROM.nullify;               \
    ASSIGN TO.stall = FROM.stall;                   \
    ASSIGN TO.bubble = FROM.bubble;                 \
    ASSIGN TO.keep_exception = FROM.keep_exception; \

    
`endif

