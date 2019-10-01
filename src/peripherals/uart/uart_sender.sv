`ifndef UART_SENDER__
`define UART_SENDER__
interface uart_send_interface(input clk,reset);
    logic send,enable;
    logic[7:0] data_send;
    logic tx;
    logic busy;

    modport host(output send, data_send,enable,
    input tx,busy);
    modport sender(output tx, busy,
    input clk,reset,send,data_send,enable);
    
endinterface //uart_send_interface
/*
    send data din when send is 1,when tb(transmission busy) is asserted,
    it will wait util current data was sent.
    send: send enable, sample at posedge at rise edge of clock.
    din: data be sent;
    tx: transmission port
    tb: busy indentify. it's indicate wheather send module can
    send next byte. example---
    data:01011001
    -----     |sbit|bit0|bit1|bit2|bit3|bit4|bit5|bit6|bit7|ebit|
          ____      ____           ____ ____      ____      ____ 
    tx:       |____|    |____ ____|         |____|    |____|    
               ____ ____ ____ ____ ____ ____ ____ ____ ____                                              
    tb:   ____|                                            |____
               ____ ____ ____ ____                          ____
    send: ____|                   |____ ____ ____ ____ ____|    
                                                            ^ 
                                                            load new value
                                                            at next clock
*/
module uart_sender(uart_send_interface.sender usif);
    logic[9:0] serial_send_data;
    logic[7:0] counter; 
    logic[3:0] dbg_clk;
    assign dbg_clk = counter[7:4];

    always_ff @(posedge usif.clk,posedge usif.reset) begin
        if(usif.reset | !usif.enable) begin
            usif.busy <= 1'b0;
            serial_send_data <= 1;
            counter = 0;
        end else begin
            if(usif.busy) begin
                if(counter[3:0] == 15) begin
                    serial_send_data <= (serial_send_data >> 1);
                    if(counter[7:4] == 8) begin
                        usif.busy <= 0;
                    end
                end
                counter <= counter + 1;
            end else begin
                if(counter[7:4] == 9 & counter[3:0] != 15) begin
                    ++counter;
                end else begin
                    if(usif.send) begin
                        usif.busy <= 1'b1;
                        serial_send_data <= {1'b1,usif.data_send,1'b0};
                        counter <= 0;
                    end
                end
            end
        end
    end
    assign usif.tx = serial_send_data[0];
endmodule

`endif