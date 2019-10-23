/* 
 N is address line , M is bits width;
*/
`include "src/memory/memory_interface.sv"
module ram #(parameter  N = 10, M = 32)
(input logic clk, memory_interface.memory mif);
    localparam NN = (M + 7)/8;
    logic[M-1:0] datas[2**N-1:0];
    logic[8*NN-1:0] bit_mask;
    logic[M-1:0]  data_writeback,data_updated;
    always_comb begin
        for(int i = 0; i < NN; ++i)
            bit_mask[8*i +:8] = {8{mif.mask[i]}};
        data_writeback = mif.din & bit_mask | ~bit_mask & datas[mif.addr];
        data_updated = mif.din & bit_mask;
    end
    always_ff @(posedge clk)
        if(mif.write)  begin
             datas[mif.addr] <= data_writeback;
        
            foreach(mif.addr[i]) begin
                assert(mif.addr[i] !== 'x)
                else begin
                    $error("ram write address have X value.");
                    $stop;
                end
            end

            foreach(data_updated[i]) begin
                assert(data_updated[i] !== 'x)
                else begin
                    $error("ram write data have X value.");
                    $stop;
                end
            end
        end
           

    assign mif.dout = datas[mif.addr];
    assign mif.busy = 0;
endmodule