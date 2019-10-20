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
     logic[31:0] debug_data_offset,kernel_data_offset, user_data_offset;
     logic debug_we,kernel_we,user_we;
     logic[31:0] debug_dout,kernel_dout,user_dout;
    
    // 8 * 4 32byte debug argument
    localparam DBG_N = 3;
    // 8M * 4byte user text 32MB
    localparam KRL_N = 23;
    // 1M *4byte kernel space 4MB
    localparam USR_N = 20;
    memory_interface #(32) debug_data_mif();
    memory_interface #(32) kernel_data_mif();
    memory_interface #(32) user_data_mif();

    ram #(DBG_N,32) unit_debug_ram (clk, debug_data_mif);
    ram #(KRL_N,32) unit_kernel_ram(clk, kernel_data_mif);
    ram #(USR_N,32) unit_user_ram  (clk, user_data_mif);

    logic[31:0] user_ins_offset;
     logic[31:0] user_ins_out;
    instruction_mem #(26,32) unit_ins_rom(
        .addr(user_ins_offset[27:2]),
        .dout(user_ins_out));

    assign debug_data_mif.mask =  data_i.mask;
    assign kernel_data_mif.mask = data_i.mask;
    assign user_data_mif.mask =   data_i.mask;

    assign debug_data_mif.din =  data_i.din;
    assign kernel_data_mif.din = data_i.din;
    assign user_data_mif.din   = data_i.din;

     always_comb begin
        user_data_offset  = 'x;
        kernel_data_offset = 'x;
        debug_data_offset = 'x;
        data_i.dout = 'x;
        
        debug_data_mif.write = 0;
        kernel_data_mif.write = 0;
        user_data_mif.write = 0;


        if(32'h5000_0000<= data_paddr &  data_paddr < 32'h6000_0000) begin
            user_data_mif.write = data_i.write;
            user_data_offset = data_paddr - 32'h5001_0000;
            user_data_mif.addr = user_data_offset[USR_N + 1:2];
            data_i.dout = user_data_mif.dout;
        end else 

        if(32'hA000_0000 <= data_paddr & data_paddr < 32'hB000_0000) begin
            kernel_data_mif.write = data_i.write;
            kernel_data_offset = (data_paddr - 32'hA000_0000);
            kernel_data_mif.addr = kernel_data_offset[KRL_N + 1:2];
            data_i.dout = kernel_data_mif.dout;
        end

        if(32'hFFFF_0000 <= data_paddr & data_paddr < 32'hFFFF_0020) begin
            debug_data_mif.write = data_i.write;
            debug_data_offset = (data_paddr - 32'hFFFF_0000);
            debug_data_mif.addr = debug_data_offset[DBG_N + 1:2];
            data_i.dout = debug_data_mif.dout;
        end

        user_ins_offset = 'x;
        ins_i.dout  = 'x;
        if(32'h4000_0000 <= ins_paddr & ins_paddr < 32'h8000_0000) begin
            user_ins_offset = ins_paddr - 32'h4000_0000 - 32'h0040_0000;
            ins_i.dout = user_ins_out;
        end

        data_i.busy = 0;
        ins_i.busy = 0;
     end
endmodule

`endif
