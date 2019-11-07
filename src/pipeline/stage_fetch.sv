`ifndef  __STAGE_FETCH__
`define  __STAGE_FETCH__
module stage_fetch(
 input clk,reset,
 input logic stall, load,
 input logic[31:0]  pc_in,
 memory_interface.rom_controller mif,
 output logic[31:0] instruction, pc, pc_add4,pc_add8,pc_sub4);
    logic[31:0] pc_reg;

    
    always_ff @(posedge clk)
        if(reset)
            pc_reg <= 32'h8000_0000;//32'h8000_0000;
        /*consider instructions:
   	        mul	v1,a1,s3
   	        jal	4040e0 <printf_.constprop.0>
   	        subu	a1,v0,v1
        mul in excute stage
        jal in decode stage
        subu in fetch stage and in delay slot

        
        jal send load signal to fetch stage and want pc load target address
        in normal case, jal jump to target address and
        subu transition from fetch stage to decode stage

        but,mul send stall signal to all stage, we also want
        subu stall in fetch stage too.
        */
        else if(!stall)
            if(load)
                pc_reg <= pc_in;
            else
                pc_reg <= pc_add4;
    
    assign mif.read = '1;
    always_comb begin
        mif.addr = pc_reg;

        instruction =  mif.dout;
        pc = pc_reg;
        pc_add4 = pc_reg + 4;
        pc_add8 = pc_reg + 8;
        pc_sub4 = pc_reg - 4;
    end
endmodule
`endif