`ifndef __PIPELINE_BASE__
`define __PIPELINE_BASE__
`include "src/pipeline/pipeline_interface.sv"

module pipeline_base (pipeline_interface.port pif, input logic nullify_instruction);
    pipeline_signal_t signal_reg;

    assign pif.signal_out = signal_reg;
    
    always_ff @(posedge pif.clk) begin
        if(pif.reset)
            signal_reg <= '{
                signals::control_t: signals::get_clear_control(),
                signals::flag_t:   '{default: '0},
                default: '0
            };
        /*
        consider instruction
         mul
         add
         xx 
         mul at execute stage and stall pipeline
         add at decode stage and be stalled
         xx is instruction in decode stage that wait memory
         so it's send nullify signal to decode,
         obviously, decode stage must be nullify util add transition
         to execute stage. so nullify signal have lower priority than stall and bubble
        */
        else if(pif.stall | pif.bubble) begin
          
        end else if(pif.nullify) begin
              signal_reg <= pif.signal_in;
            signal_reg.control <=  signals::get_clear_control();
            if(nullify_instruction)
                signal_reg.instruction <= '0;
            signal_reg.fetch <= '0;
            // bacause of write status when exception happen
            // must keep cop0 data and write_cop0 signal
            signal_reg.cop0_excdata <= pif.signal_in.cop0_excdata;
        end else
            signal_reg <= pif.signal_in;
    end
endmodule

`endif


