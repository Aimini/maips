`include "src/peripherals/uart/uart.sv"

module uart_test();
    logic clk,clka,clkb;
    logic reset;
    logic [15:0] counter;
    uart_interface uifa(clka,reset),uifb(clkb,reset);


    uart tua(uifa);
    uart tub(uifb);

    assign uifb.rx = uifa.tx;

//100MHZ main clock.
    always begin
        clk = 0; #1ns;
        clk = 1; #1ns;
    end
//1000/14MHZ = 74.428571428571MHZ
    always begin
        clka = 0; #7ns;
        clka = 1; #7ns;
    end
//1000/22MHZ = 45.454545MHZ
    always begin
        clkb = 0; #11ns;
        clkb = 1; #11ns;
    end
// test 
    
    string str = "abcd! sdfs fdasfoji dsfsdjiofjs sdfsd245634!)(@*#*!)*$)_#(!%%{PJDS\"\\JF??~~{IJ?";
    int index = 0;
    int received_count = 0;
    logic begin_transmission = 0;

    always @(posedge clk)
        counter <= counter +1;

    task automatic inital_uarta();
    // a baud rate = 10e9 /( 14* 39 * 16) = 114468.86 , 0.6% to 115200
        @(negedge clka) begin
            uifa.config_reg_in = '{default:0};
            uifa.config_reg_in.div_counter = 39; 
	        uifa.config_reg_in.txend = 1;
        end
        @(negedge clka) begin
            uifa.config_reg_in.send_enable = 1;
            uifa.config_reg_in.receive_enable = 0;
            uifa.write_config_reg = 1;
        end
        repeat(2) @(negedge clka) begin
            uifa.write_config_reg = 0;
        end
    endtask //automatic

    task automatic inital_uartb();
        // b baud rate = 10e9 /(22*25*16) = 113636,  1.3% to 115200, 0.73% to a
        @(negedge clkb) begin
            uifb.config_reg_in = '{default:0}; 
            uifb.config_reg_in.div_counter = 25; 
            uifb.write_config_reg = 1;
        end
        @(negedge clkb) begin
            uifb.config_reg_in.send_enable = 0;
            uifb.config_reg_in.receive_enable = 1;
            uifb.write_config_reg = 1;
        end
        repeat(2) @(negedge clkb) begin
            uifb.write_config_reg = 0;
        end
    endtask //automatic


    initial begin
        counter = 0; reset = 1; #154ns;
        reset = 0;
        
        fork
            inital_uarta();
            inital_uartb();
        join

        begin_transmission = 1;
        index = 0;
    end
	
    always @(negedge clkb) begin
        if(begin_transmission > 0) begin
            uifb.write_data_reg = 0;
            uifb.write_config_reg = 0;  
            if(uifb.config_reg_out.rxend) begin
                uifb.config_reg_in.rxend = 0;
                uifb.write_config_reg = 1;  

                $display("uart b recive char:  %c",uifb.data_reg_out);
                assert (uifb.data_reg_out == str[received_count])
                else $warning("recived %c wrong at index %d.",uifb.data_reg_out,received_count);
                
                ++received_count;
                if (received_count == str.len())
                    $finish;      
            end
        end
    end

    always @(negedge clka) begin
        if(begin_transmission > 0) begin
            uifa.write_data_reg = 0;
            uifa.write_config_reg = 0;
            if(uifa.config_reg_out.txend & index != str.len()) begin
                uifa.config_reg_in.txend = 0;
                uifa.data_reg_in = str[index];
                uifa.write_data_reg = 1;
                uifa.write_config_reg = 1;
                ++index;
            end
        end
    end
endmodule