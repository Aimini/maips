`ifndef __REGISTER_FILE__
`define __REGISTER_FILE__

module register_file  #(parameter out = 2,parameter addr = 5,parameter width = 32)
(   input logic clk,reset,
    input logic we,
    input logic [addr - 1:0] waddr,
    input logic[width - 1:0] din,
    input logic [addr - 1:0] raddr[out-1:0],
    output logic[width - 1:0] dout[out-1:0]);

    logic[width - 1:0] file[2**addr - 1:0];
    always_ff @(posedge clk,posedge reset) begin
        if(reset) begin
            for(int i = 0; i < 2**addr; i = i + 1)
            begin
                file[i] <= {width{1'b0}};
            end
        end 
        else if(we) begin
            if(waddr !== 0) begin
                file[waddr] <= din;
            end
            foreach(waddr[i]) begin
                assert(waddr[i] !== 'x)
                else begin
                    $error("register file write address have X value.");
                    $stop;
                end
            end
            foreach(din[i]) begin
                assert(din[i] !== 'x)
                else begin
                    $error("register file write data have X value.");
                    $stop;
                end
            end
        end
    end

    always_comb begin
        for(int i = 0; i < out; i = i + 1)
        begin
            dout[i] = (raddr[i] == {addr{1'b0}})?  {width{1'b0}} : file[raddr[i]];
        end
    end
endmodule

`endif