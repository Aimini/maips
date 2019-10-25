`include "src/pipeline/pipeline_interface.sv"

module pipeline_base (pipeline_interface.port pif, input logic nullify_instruction = '0);
    pipeline_signal_t signal_reg;

    assign pif.signal_out = signal_reg;
    
    always_ff @(posedge pif.clk) begin
        if(pif.reset)
            signal_reg <= '{
                signals::control_t: signals::nullify_control(pif.signal_in.control),
                signals::flag_t:   '{default: '0},
                default: '0
            };
        else  if(pif.stall | pif.bubble) begin
        
        end else if(pif.nullify) begin
            signal_reg <= '{
                signals::control_t: signals::nullify_control(pif.signal_in.control),
                signals::flag_t:   '{default: 'x},
                default: 'x
            };
            if(nullify_instruction)
                signal_reg.instruction <= '0;
        end else
            signal_reg <= pif.signal_in;
    end
endmodule




