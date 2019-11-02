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
        else if(load)
            pc_reg <= pc_in;
        else if(!stall)
            pc_reg <= pc_add4;
    
    always_comb begin
        mif.addr = pc_reg;
        mif.read = '1;

        instruction =  mif.dout;
        pc = pc_reg;
        pc_add4 = pc_reg + 4;
        pc_add8 = pc_reg + 8;
        pc_sub4 = pc_reg - 4;
    end
endmodule
