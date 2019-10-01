`ifndef UART__
`define UART__

`include "src/peripherals/uart/uart_receiver.sv"
`include "src/peripherals/uart/uart_sender.sv"
`include "src/common/util.sv"

typedef struct {
    /*** config ****/
    logic receive_enable;
    logic send_enable;
    logic[2:0] clk_scale;
    logic[15:0] div_counter;
    /**** data and flog****/
    logic txend,rxend;
    logic wait_retrieve;
} uart_config_reg_t;

interface uart_interface(input logic clk,reset);
    /****************** system port *****************/
    uart_config_reg_t config_reg_in,config_reg_out;
    logic[7:0] data_reg_in,data_reg_out;

    /*** control ***/
    logic write_config_reg;
    logic write_data_reg;

    /****** external port from receiver and sender  ******/
    logic tx,rx,receive_busy,send_busy;

    modport uart(input clk,reset,
    input config_reg_in,data_reg_in,
    input write_config_reg,write_data_reg,
    input rx,
    output config_reg_out,data_reg_out,
    output receive_busy,send_busy,
    output tx);
    modport host(input config_reg_out,data_reg_out,
    output config_reg_in,data_reg_in,write_config_reg,write_data_reg);
endinterface


module uart(uart_interface.uart uif);
    logic uart_clk;
    uart_send_interface sif(uart_clk,uif.reset);
    uart_receiver_interface rif(uart_clk,uif.reset);
    uart_receiver receiver(rif);
    uart_sender sender(sif);
    
    /**** as reigster for out port ***/
    uart_config_reg_t config_reg;
    logic[7:0] data_reg;
    // use to compare with div_counter to generate uart's clk
    logic[15:0] sys_counter;

    logic previous_send_busy, previous_receive_busy;

    always_ff @(posedge uif.clk,posedge uif.reset) begin
        if(uif.reset) begin
            config_reg <= '{default: 0};
            {previous_send_busy,previous_receive_busy,sys_counter} <= 0;
        end else if(uif.write_config_reg) begin
            config_reg <= uif.config_reg_in;
            if(uif.write_data_reg) begin
                config_reg.wait_retrieve <= 1;
            end
        end
    end

    assign uif.config_reg_out = config_reg;
    assign uif.data_reg_out = rif.data_received;

    /***  sender logic *****/
    always_ff @(posedge uif.clk) begin
        previous_send_busy <= sif.busy;
        if(uif.write_data_reg) begin
            data_reg <= uif.data_reg_in;
            config_reg.wait_retrieve <= 1;
        end else begin
            if(~previous_send_busy & sif.busy & config_reg.wait_retrieve == 1) begin
                config_reg.wait_retrieve <= 0;
            end
        end
        if(previous_send_busy & ~sif.busy) begin
            config_reg.txend <= 1;
        end
    end
    // because uart clock diveder ,
    // uart clock are slightly slower than main clock
    // it might can cause metastable
    logic sync_send;
    logic sync_send_enable;
    always_ff @(posedge uart_clk) begin
        sync_send <= config_reg.wait_retrieve;
        sync_send_enable <= config_reg.send_enable;
        sif.send  <= sync_send;
        sif.enable <= sync_send_enable;
    end
    assign sif.data_send = data_reg;

    /**** receiver logic ******/
    always_ff @(posedge uif.clk) begin
        previous_receive_busy  <= rif.busy;
        if(previous_receive_busy & ~rif.busy)
            config_reg.rxend <= 1;
    end

    logic sync_receive_enable;
    always_ff @(posedge uart_clk) begin
        sync_receive_enable <= config_reg.receive_enable;
        rif.enable <= sync_receive_enable;
    end

    /**** external port ******/
    always_comb begin
        uif.receive_busy = rif.busy;
        uif.send_busy = sif.busy;
        rif.rx = uif.rx;
        uif.tx = sif.tx;
    end

    

    /***uart  clock  ***/
    //logic scaled_clk;
    // freq_divder fd(uif.clk,clk_scale,scaled_clk);
    // always_ff @(posedge scaled_clk) begin
    //     div_counter <= div_counter + 1;
    // end
    always_ff @(posedge uif.clk) begin
        if(sys_counter == config_reg.div_counter)
            sys_counter = 0;
        else
            sys_counter <= sys_counter + 1;
    end
    assign uart_clk = ((config_reg.div_counter >> 1) < sys_counter)? 1 : 0;

endmodule

`endif