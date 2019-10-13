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

    string dbg_target = "sw_dbg";
    string j_too_large = "j";
    string jal_too_large = "jal"; // don't test j and jal if unnecessary, it'test file too large
    string target_name[] = 
    '{dbg_target, "lui_1",     "lui_2", "ori_1",
      "ori_2",    "sll_1",     "sll_2", "addu",
      /*j_too_large,jal_too_large*/
      "addiu"};
    // string test_target = target_name[1];

    always_comb begin
        reg_file = unit_top.unit_core.unit_decode.unit_rf.file;
        reg_v  =  reg_file[3:2];
        reg_a  = reg_file[7:4];
        reg_s = reg_file[23:16];
        reg_t = {reg_file[25:24], reg_file[15:8]};

        write_dbg_memory =  unit_top.unit_memory.debug_we;
        dbg_arg = unit_top.unit_memory.unit_debug_ram.datas;
    end

    function automatic string get_test_filename(string target);
        if(target == jal_too_large)
            return "D:/pipeline_temp/asm/temp/jal.asm.hextext";
        else  if(target == j_too_large)
            return "D:/pipeline_temp/asm/temp/j.asm.hextext";
        return {"asm/temp/", target, ".asm.hextext"};
    endfunction

    function automatic string get_regchk_filename(string target);
    if (target == jal_too_large)
            return "D:/pipeline_temp/asm/temp/jal.asm.reg.hextext";
        else  if(target == j_too_large)
            return "D:/pipeline_temp/asm/temp/j.asm.reg.hextext";
        return  {"asm/temp/", target, ".asm.reg.hextext"};
    endfunction

    /* fill for sw_dbg test */
    function automatic void fill_regsiter_sw_dbg();
       unit_top.unit_core
       .unit_decode.unit_rf.file[2] = 32'hffff0000; //v0 = 0xFFFF0000
       for(int i = 0; i < 8; ++i)
            unit_top.unit_core
            .unit_decode.unit_rf.file[16 + i] =  1 << i; //s0 - s7
        unit_top.unit_core
       .unit_decode.unit_rf.file[16] = 32'hffff0000; //s0 = 0xFFFF0000
    endfunction

    function automatic void check_sw_dbg_arg();
        logic ret = 1;
         for(int i = 0; i < 8; ++i) begin
            $display("dbg(%0d) = %8h",i,dbg_arg[i]);
        end
        // check dbg_arg memory 
        if(dbg_arg[1] == 32'h0000_0020) begin
            assert (dbg_arg[0] === 32'hffff_0000)
            else  $error("dbg(0) != 32'hffff_0000!");
            for(int i = 1; i < 8; ++i) begin
                assert (dbg_arg[i] === (1 << i))
                else  begin
                   $error("sw_dbg failed: dbg(%0d) != %8h",i,dbg_arg[i]);
                   ret = 0; 
                end
            end
        end
        // return ret;
    endfunction
    
    /** check reg file **/
    function automatic void check_regfile(string filename,logic[31:0]  rf[31:0],logic ignore_gp_sp);
        logic[31:0]  temp[31:0];
        $readmemh(filename, temp);
        for(int i = 0; i < 32; ++i) begin
            if(ignore_gp_sp & (i == 28 | i == 29))
                continue;
            assert (temp[i] === rf[i]) 
            else  $error("register file check failed at %0d: %8h != %8h ",i,temp[i],rf[i]);
        end
    endfunction


    task automatic new_test(string target,logic fill_reg);
        
        string test_filename =  get_test_filename(target);
        string regchk_filename = get_regchk_filename(target);
        logic exit = 0;
        $display("testing %s...",test_filename);
        $readmemh(test_filename, unit_top.unit_memory.unit_ins_rom.im);

        reset = 1;
        @(negedge clk) begin
            reset = 1;
        end
        
        @(negedge clk) begin
            reset = 0;
            if(fill_reg) begin
                fill_regsiter_sw_dbg();
            end
        end

        while (~exit) begin
            @(negedge clk) begin
                if(previous_dbg_arg === dbg_arg[0])
                    continue;

                case(dbg_arg[0])
                    0: exit = 1;

                    1: begin
                        assert(dbg_arg[1] === dbg_arg[2])
                        else $error("assert equal failed : %8h != %8h",dbg_arg[1],dbg_arg[2]);
                    end

                    2:  begin
                        assert(dbg_arg[1] !== dbg_arg[2])
                        else $error("assert not equal failed : %8h == %8h",dbg_arg[1],dbg_arg[2]);
                    end

                    
                    32'h0001_0000: begin
                        if(dbg_arg[1] === 32'h0001_0000) begin
                             //ignore $gp, $sp
                            check_regfile(regchk_filename, reg_file, 1);
                        end  else begin   //check all
                            check_regfile(regchk_filename, reg_file, 0);
                        end
                    end

                    32'hffff_0000: begin
                        for(int i = 0; i < 8; ++i) begin
                            $display("dbg(%0d) = %8h",i,dbg_arg[i]);
                        end   // check dbg_arg memory 
                        if(dbg_arg[1] == 32'h0000_0020) begin
                            check_sw_dbg_arg();
                        end
                    end

                    default:
                        $error("unsupport check!");
                endcase
            end
            previous_dbg_arg = dbg_arg[0];
        end
    endtask

    initial begin
         // new_test(.target(target_name[0]),.fill_reg('1));
         // new_test(.target(target_name[1]),.fill_reg(0));
        //  for(int i = target_name.size() - 2; i < target_name.size(); ++i)
        //  new_test(.target(target_name[i]),.fill_reg(i == 0));
        //  $finish;

         new_test(.target(target_name[target_name.size() - 1]),.fill_reg(0));
         $finish;
    end


    
endmodule