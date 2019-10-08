module stage_fetch(
 input clk,reset,
 input logic stall,nullify, load,
 input logic[31:0]  pc_in,
 input logic[31:0]  idata,
 output logic[31:0] iaddr, input logic wait_memory,
 output logic[31:0] instruction, pc, pc_add4);
    logic[31:0] pc_reg;

    assign pc = pc_reg;
    assign pc_add4 = pc_reg + 4;

    always_ff @(posedge clk)
        if(reset)
            pc_reg <= 32'h0040_0000;//32'hBFC0_0000;
        else if(load)
            pc_reg <= pc_in;
        else if(!stall & !wait_memory)
            pc_reg <= pc_add4;
    
    always_comb begin
        iaddr = pc_reg;
        if(wait_memory | nullify)
            instruction = 0;
        else
            instruction = idata;
    end
endmodule
