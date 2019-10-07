module pipeline_base (pipeline_interface.port pif);
    pipeline_signal_t signal_reg;

    always_comb begin
        pif.signal_out = signal_reg;
        pif.signal_out.control = pif.nullify ? signals::nullify_control(signal_reg.control) : signal_reg.control;    
    end

    always_ff @(posedge pif.clk) begin
        if(pif.reset)
            signal_reg <= '{
                signals::control_t: signals::nullify_control(signal_reg.control),
                signals::flag_t:   {default: 0},
                default: 0
            };
        else if(!pif.stall)
            signal_reg <= pif.signal_in;
    end
endmodule

