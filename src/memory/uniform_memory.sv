`ifndef UNIFORM_MEMORY__
`define UNIFORM_MEMORY__
`include "src/memory/fixed_memory_map.sv"
`include "src/memory/memory_interface.sv"
`include "src/memory/ram.sv"
`include "src/memory/instruction_mem.sv"

module uniform_memory(input logic clk, status_erl,
memory_interface.memory ins_i,data_i);
    logic[31:0] ins_paddr,data_paddr;

     fixed_memory_map instruction_fmt
     (ins_i.addr,status_erl,ins_paddr);
     fixed_memory_map data_fmt
     (data_i.addr,status_erl,data_paddr);
     
     // 1K kernel space at 32'hA000_0000
     logic[31:0] kernel_data_offset, user_data_offset;
     logic kernel_we,user_we;
     logic[31:0] kernel_din, user_din;
     logic[31:0] kernel_dout,user_dout;
    
    // 1K kernel space
    ram #(10,32) unit_kernel_ram(.clk(clk),
    .we(kernel_we),.addr(kernel_data_offset[11:2]),
    .din(kernel_din),.dout(kernel_dout));
        
    // 4K user space
    ram #(12,32) unit_user_ram(.clk(clk),
    .we(user_we),.addr(user_data_offset[13:2]),
    .din(user_din),.dout(user_dout));

    logic[31:0] user_ins_offset;
     logic[31:0] user_ins_out;
    // 1K user text
    instruction_mem #(10,32) unit_ins_rom(
        .addr(user_ins_offset[11:2]),
        .dout(user_ins_out));

     always_comb begin
        user_we = 1'b0;
        kernel_we = 1'b0;
        user_data_offset  = 'x;
        kernel_data_offset = 'x;
        user_din  = data_i.din;
        kernel_din = data_i.din;
        data_i.dout = 'x;
        

        if(32'h1000_0000< data_paddr < 32'h2000_0000) begin
            user_we = data_i.write;
            user_data_offset = data_paddr - 32'h1000_0000;
            data_i.dout = user_dout;
        end else 

        if(32'hA000_0000 <= data_paddr & data_paddr < 32'hB000_0000) begin
            kernel_we = data_i.write;
            kernel_data_offset = (data_paddr - 32'hA000_0000);
            data_i.dout = kernel_dout;
        end

        user_ins_offset = 'x;
        ins_i.dout  = 'x;
        if(32'h4000_0000 < ins_paddr & ins_paddr < 32'h8000_0000) begin
            user_ins_offset = ins_paddr - 32'h4000_0000 - 32'h0040_0000;
            ins_i.dout = user_ins_out;
        end

        data_i.busy = 0;
        ins_i.busy = 0;
     end
endmodule

`endif
