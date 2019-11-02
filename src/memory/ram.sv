/* 
 N is address line , M is bits width;
*/
`include "src/memory/memory_interface.sv"
module ram #(parameter  DN = 32, AN = 10)
(input logic clk, memory_interface.memory mif);
    localparam BYTEN = (DN + 7)/8;
    logic[DN-1:0] datas[2**AN - 1:0];
    
    logic[8*BYTEN-1:0] bit_mask;
    logic[DN-1:0]  data_writeback,data_updated;
    logic[AN - 1:0] fitted_addr;

    assign fitted_addr = mif.addr[AN - 1:0];

    always_comb begin : get_bit_mask
        for(int i = 0; i < BYTEN; ++i)
            bit_mask[8*i +:8] = {8{mif.mask[i]}};
        data_writeback = mif.din & bit_mask | ~bit_mask & datas[fitted_addr];
        data_updated = mif.din & bit_mask;
    end

    always_ff @(posedge clk) begin
        if(mif.write)  begin
             datas[fitted_addr] <= data_writeback;
        
            foreach(fitted_addr[i]) begin
                assert(fitted_addr[i] !== 'x)
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
    end 

    assign mif.dout = datas[mif.addr];
    assign mif.busy = 0;
endmodule