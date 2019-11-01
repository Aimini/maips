`ifndef __INTERRUPT_STORAGE__
`define __INTERRUPT_STORAGE__
/*
    in: sync/aysnc interrupt input port
    sync_mask: 1 meaing sync input, 0 meaing async input that using synchronizer in this module
    clear: clear all interrupt that store in reigister
    out:
    parameter
     N: input 
    SN: syschronizer level
*/

module interrupt_storage #(parameter N = 8,parameter SN = 2)
(input logic clk,reset,clear,
input logic[N - 1:0] in, sync_mask, 
output logic[N - 1:0] out);

    logic[N - 1:0] synchronizer[SN], int_reg;
    always_ff @(posedge clk,posedge reset) begin : catch_interrupt
        if(reset) begin
            for(int i = 0; i < N; ++i) begin
                synchronizer[i] <= '0;
            end
                int_reg <= '0;
        end else begin
            /**/        
            synchronizer[0] <= in;
            for(int i = 1; i < N; ++i) begin
                synchronizer[i] <= synchronizer[i - 1];
            end

            if(clear) begin
                int_reg <= '0;
            end
            int_reg <= sync_mask & synchronizer[SN - 1] | ~sync_mask & in;
        end
    end
    
    always_comb begin
        out = int_reg;
    end

endmodule

`endif