`include "src/top.sv"

module top_test();
    logic clk,reset;

    always begin
        clk = 1; #5ns;
        clk = 0; #5ns;
    end

    top unit_top(clk,reset);

    logic reg_v0;
    selector::execption_check_t exc_chk;

    always_comb begin
        reg_v0  =  unit_top.unit_core.unit_decode.unit_rf.file[2];
        exc_chk =  unit_top.unit_core.pif_decode.signal_out.control.exc_chk;
    end

    initial begin
        reset = 1;
        @(negedge clk) begin
            reset = 1;
        end
        
        @(negedge clk) begin
            reset = 0;
        end
    end

    always @(posedge clk) begin
        if(exc_chk == selector::EXC_CHK_SYSCALL) begin
                $info("syscall with $v0 = %0d",reg_v0);
                if(reg_v0 == 10)
                    $finish;
            end
    end
endmodule