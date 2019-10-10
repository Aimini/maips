`include "src/top.sv"

module top_test();
    logic clk,reset;

    always begin
        clk = 1; #5ns;
        clk = 0; #5ns;
    end

    top unit_top(clk,reset);

    logic[31:0] reg_v0;
    logic[31:0] reg_a0;
    logic[31:0] reg_a1;
    logic[31:0] reg_file[31:0];
    selector::execption_check_t exc_chk;

    always_comb begin
        reg_file = unit_top.unit_core.unit_decode.unit_rf.file;
        reg_v0  =  reg_file[2];
        reg_a0  = reg_file[4];
        reg_a1  = reg_file[5];
        exc_chk =  unit_top.unit_core.pif_decode.signal_out.control.exc_chk;
    end

    initial begin
        reset = 1;
        $readmemh("asm/temp/beq_bne.asm.hextext",unit_top.unit_memory.unit_ins_rom.im);
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
            case(reg_v0) 
               
                10: $finish;
                100: begin
                    assert(reg_a0 == reg_a1)
                    else $error("assert fail! %8h(a0) != %8h(a1)",reg_a0,reg_a1);
                end 

                101:begin
                    assert(reg_a0 != reg_a1)
                    else $error("assert fail! %8h(a0) == %8h(a1)",reg_a0,reg_a1);
                end
            endcase
        end
    end
endmodule