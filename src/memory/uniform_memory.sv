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
     logic[31:0] debug_dout,kernel_dout,user_dout;
    
    // 8 * 4 32byte debug argument
    localparam DBG_N = 3;
    //  1M* 4byte kernel text 4MB
    localparam KRL_N = 20;
    // 8M *4byte user space 32MB
    localparam USR_N = 23;
    memory_interface #(.AN(DBG_N),.DN(32)) debug_data_mif();
    memory_interface #(.AN(KRL_N),.DN(32)) kernel_data_mif();
    memory_interface #(.AN(USR_N),.DN(32)) user_data_mif();

    ram #(.AN(DBG_N),.DN(32)) unit_debug_ram (clk, debug_data_mif);
    ram #(.AN(KRL_N),.DN(32)) unit_kernel_ram(clk, kernel_data_mif);
    ram #(.AN(USR_N),.DN(32)) unit_user_ram  (clk, user_data_mif);

    localparam IUSR_N = 26;
    localparam IKRL_N = 26;
    memory_interface #(.AN(IKRL_N),.DN(32)) kernel_ins_mif();
    memory_interface #(.AN(IUSR_N),.DN(32)) user_ins_mif();

    instruction_mem #(.AN(IKRL_N),.DN(32)) unit_kernel_ins_rom(kernel_ins_mif);
    instruction_mem #(.AN(IUSR_N),.DN(32)) unit_user_ins_rom(user_ins_mif);
    
    assign debug_data_mif.mask =  data_i.mask;
    assign kernel_data_mif.mask = data_i.mask;
    assign user_data_mif.mask =   data_i.mask;

    assign debug_data_mif.din =  data_i.din;
    assign kernel_data_mif.din = data_i.din;
    assign user_data_mif.din   = data_i.din;

`ifndef  CREATE_INTERFACE_MAP
`define CREATE_INTERFACE_MAP(_MIF,_S,_E)                                                \
    function automatic void map_range_``_MIF();                                         \
        logic ins_in_range = (_S <= ins_paddr  && ins_paddr < _E) ? '1 : '0;            \
        logic ram_in_range = (_S <= data_paddr && data_paddr < _E) ? '1 : '0;           \
                                                                                        \
        logic[31:0] ram_offset = data_paddr - _S;                                       \
        logic[31:0] ins_offset = ins_paddr  - _S;                                       \
                                                                                        \
        ins_in_range = ins_in_range & ins_i.read;                                       \
        ram_in_range = ram_in_range & (data_i.read | data_i.write);                     \
        if(ins_in_range) begin                                                          \
            ins_i.dout  = _MIF.dout;                                                    \
            ins_i.busy =  _MIF.busy;                                                    \
        end                                                                             \
        if(ram_in_range) begin                                                          \
            data_i.dout = _MIF.dout;                                                    \
            data_i.busy = _MIF.busy;                                                    \
        end                                                                             \
                                                                                        \
        if(ins_in_range && ram_in_range) begin                                          \
            ins_i.busy = '1;                                                            \
        end                                                                             \
                                                                                        \
        if(ram_in_range) begin                                                          \
            _MIF.write = data_i.write;                                                  \
            _MIF.addr = ram_offset[31:2];                                               \
        end else begin                                                                  \
            _MIF.write = '0;                                                            \
            _MIF.addr = ins_offset[31:2];                                               \
        end                                                                             \
    endfunction
`endif                                                  

`CREATE_INTERFACE_MAP(debug_data_mif ,32'hFFFF_0000,32'hFFFF_0020)
`CREATE_INTERFACE_MAP(user_data_mif  ,32'h5001_0000,32'h6000_0000)
`CREATE_INTERFACE_MAP(user_ins_mif   ,32'h4040_0000,32'h5000_0000)
`CREATE_INTERFACE_MAP(kernel_data_mif,32'h1000_0000,32'h2000_0000)
`CREATE_INTERFACE_MAP(kernel_ins_mif ,32'h0000_0000,32'h1000_0000)
     always_comb begin
        data_i.dout = 'x;
        data_i.busy = 0;

        ins_i.dout  = 'x;
        ins_i.busy = 0;
        
        map_range_debug_data_mif();
        map_range_user_data_mif();
        map_range_user_ins_mif();
        map_range_kernel_data_mif();
        map_range_kernel_ins_mif();
     end
endmodule

`endif
