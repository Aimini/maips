`include "src/top.sv"

module top_test();
    logic clk,reset;

    always begin
        clk = 1; #5ns;
        clk = 0; #5ns;
    end

    top unit_top(clk,reset);

    logic[31:0] reg_v[1:0],reg_a[3:0],reg_s[7:0],reg_t[9:0];
    logic[31:0]  reg_file[31:0];
    logic write_dbg_memory;
    logic[31:0] dbg_arg[7:0];
    logic[31:0] previous_dbg_arg;

    string dbg_file = "sw_dbg";
    string file_name[] = '{dbg_file,"ori"};
    string test_file = file_name[0];

    always_comb begin
        reg_file = unit_top.unit_core.unit_decode.unit_rf.file;
        reg_v  =  reg_file[3:2];
        reg_a  = reg_file[7:4];
        reg_s = reg_file[23:16];
        reg_t = {reg_file[25:24], reg_file[15:8]};

        write_dbg_memory =  unit_top.unit_memory.debug_we;
        dbg_arg = unit_top.unit_memory.unit_debug_ram.datas;
    end

    /* fill for sw_dbg test */
    task fill_regsiter_sw_dbg();
       unit_top.unit_core
       .unit_decode.unit_rf.file[2] = 32'hffff0000; //v0 = 3
       for(int i = 0; i < 8; ++i)
            unit_top.unit_core
            .unit_decode.unit_rf.file[16 + i] = i; //s0 - s7
    endtask

    initial begin
        reset = 1;



        $readmemh({"asm/temp/",test_file,".asm.hextext"},unit_top.unit_memory.unit_ins_rom.im);
        @(negedge clk) begin
            reset = 1;
        end
        
        @(negedge clk) begin
            if(test_file == dbg_file) begin
                fill_regsiter_sw_dbg();
            end
            reset = 0;
        end
    end


    always @(negedge clk) begin
        if(previous_dbg_arg !== dbg_arg[0])  begin
            case(dbg_arg[0])
                0: begin
                    for(int i = 0; i < 8; ++i) begin
                        $display("dbg(%0d) = %8h",i,dbg_arg[i]);
                    end
                    // check dbg_arg memory 
                    if(test_file == dbg_file) begin
                        for(int i = 0; i < 8; ++i) begin
                            assert (dbg_arg[i] === i) 
                            else  $error("sw_dbg failed: dbg(%0d) != %8h",i,dbg_arg[i]);
                        end
                        $finish;
                    end
                end

                1: $finish;

                2: begin
                    assert(dbg_arg[1] !== dbg_arg[2])
                    else $error("assert equal failed : %8h != %8h",dbg_arg[1],dbg_arg[2]);
                end

                3:  begin
                    assert(dbg_arg[1] !== dbg_arg[2])
                    else $error("assert not equal failed : %8h == %8h",dbg_arg[1],dbg_arg[2]);
                end
                
            endcase
        end
        previous_dbg_arg = dbg_arg[0];
    end
endmodule