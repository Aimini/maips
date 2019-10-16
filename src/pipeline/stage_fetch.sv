module stage_fetch(
 input clk,reset,
 input logic stall, load,
 input logic[31:0]  pc_in,
 memory_interface.read_only_controller mif,
 output logic[31:0] instruction, pc, pc_add4);
    logic[31:0] pc_reg;

    

    always_ff @(posedge clk)
        if(reset)
            pc_reg <= 32'h0040_0000;//32'hBFC0_0000;
        else if(load)
            pc_reg <= pc_in;
        else if(!stall)
            pc_reg <= pc_add4;
    
    always_comb begin
        mif.addr = pc_reg;
        instruction =  mif.dout;
        pc = pc_reg;
        pc_add4 = pc_reg + 4;
    end
endmodule
