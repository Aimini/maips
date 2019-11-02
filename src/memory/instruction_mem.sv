`include "src/memory/memory_interface.sv"
module instruction_mem # (parameter  AN = 10,DN = 32)
(memory_interface.rom mif);
    logic[DN - 1:0] datas[2**AN - 1:0];

    assign mif.dout = datas[mif.addr[AN - 1:0]];
    assign mif.busy = 0;
endmodule