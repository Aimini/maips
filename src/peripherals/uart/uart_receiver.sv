`ifndef UART_RECEIVER__
`define UART_RECEIVER__
interface uart_receiver_interface(input logic clk,reset);

    logic[7:0] data_received;
    logic enable;
    logic rx;
    //flags.
    logic busy,frame_error;

    modport host(output rx,enable,
    input data_received,busy,frame_error);
    modport receiver(output data_received,busy,frame_error,
    input clk,reset,rx,enable);
endinterface


module uart_receiver(uart_receiver_interface.receiver urif);

    logic sync_data , sync_data0;
    logic[7:0] counter; //byte count [7:4] , sample count[3:0]
    logic sample6,sample7,sample_m;
    logic sample_period;
    logic[7:0] data_reg;

    // if data[8:6]'s have at least 2 ones,  we treat it as one.(Reduce noise)
    assign sample_m = sample6&sample7 | sample6&sync_data | sample7&sync_data;
    assign sample_period = (counter[3:0] == 8);
    always_ff @(posedge urif.clk,posedge urif.reset) begin
        if(urif.reset | !urif.enable) begin
            {sync_data, sync_data0, counter,    
            sample6, sample7,data_reg,
            urif.frame_error, urif.busy} <= 0;
        end else begin
            //synchronizer
            sync_data0 <= urif.rx;
            sync_data <= sync_data0;
            //storage previous sample 
            sample6 <= sample7;
            sample7 <= sync_data;

            if(!urif.busy) begin
                if(sync_data == 1)
                    counter <= 0;
                else begin
                    if(counter[3:0] == 7) begin
                        urif.busy <= 1;
                    end
                    counter <= counter + 1;
                end
            end else begin
                if(counter[7:4] == 9 & sample_period) begin
                    counter <= 0;
                    urif.busy <= 0;
                    urif.data_received <= data_reg;
                    urif.frame_error <= (sample_m == 0) ? 1 : 0;
                end else begin
                    if(counter[7:4] != 0 & sample_period) begin
                        data_reg <= {sample_m,data_reg[7:1]};
                    end
                    counter <= counter + 1;
                end
            end
        end
    end
endmodule

`endif