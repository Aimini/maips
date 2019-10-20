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
    logic write_dbg_memory,write_dbg_function_reg;
    logic[31:0] pc_mem_stage;
    // indicate cpu is writing dbg memory.
    logic dbg_loaded;
    logic[31:0] dbg_arg[7:0];

    typedef struct {
        string name;
        logic assert_equal, assert_not_equal, check_register_file;
        logic sw_dbg_target;
    } check_target_t;

    string j_too_large = "j";
    string jal_too_large = "jal"; // don't test j and jal if unnecessary, it'test file too large

    check_target_t all_targets[] = 
    '{ 
        '{"sw_dbg",     1'b0,  1'b0,  1'b0,  1'b1},
        '{"lui_1",      1'b0,  1'b0,  1'b1,  1'b0},
        '{"lui_2",      1'b0,  1'b0,  1'b1,  1'b0},
        '{"ori_1",      1'b0,  1'b0,  1'b1,  1'b0},
        '{"ori_2",      1'b0,  1'b0,  1'b1,  1'b0},
        '{"sll_1",      1'b0,  1'b0,  1'b1,  1'b0},
        '{"sll_2",      1'b0,  1'b0,  1'b1,  1'b0},
        '{"addu",       1'b0,  1'b0,  1'b1,  1'b0},
        '{"addiu",      1'b0,  1'b0,  1'b1,  1'b0},
        '{"beq",        1'b0,  1'b0,  1'b1,  1'b0},
        '{"bne",        1'b0,  1'b0,  1'b1,  1'b0},
        '{"blez",       1'b0,  1'b0,  1'b1,  1'b0},
        '{"bgtz",       1'b0,  1'b0,  1'b1,  1'b0},
        '{"slti",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"sltiu",      1'b1,  1'b0,  1'b1,  1'b0},
        '{"andi_1",     1'b0,  1'b0,  1'b1,  1'b0},
        '{"andi_2",     1'b0,  1'b0,  1'b1,  1'b0},
        '{"xori_1",     1'b0,  1'b0,  1'b1,  1'b0},
        '{"xori_2",     1'b0,  1'b0,  1'b1,  1'b0},
        '{"mthi_mfhi",  1'b1,  1'b0,  1'b1,  1'b0},
        '{"mtlo_mflo",  1'b1,  1'b0,  1'b1,  1'b0},
        '{"multu",      1'b1,  1'b0,  1'b1,  1'b0},
        '{"divu",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"mult",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"div",        1'b1,  1'b0,  1'b1,  1'b0},
        '{"maddu",      1'b1,  1'b0,  1'b1,  1'b0},
        '{"madd",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"msubu",      1'b1,  1'b0,  1'b1,  1'b0},
        '{"msub",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"mul",        1'b1,  1'b0,  1'b1,  1'b0},
        '{"clz",        1'b1,  1'b0,  1'b1,  1'b0},
        '{"clo",        1'b1,  1'b0,  1'b1,  1'b0},
        '{"lw",         1'b1,  1'b0,  1'b1,  1'b0},
        '{"lh",         1'b1,  1'b0,  1'b1,  1'b0},
        '{"lb",         1'b1,  1'b0,  1'b1,  1'b0},
        '{"jr",         1'b0,  1'b0,  1'b1,  1'b0},
        '{"jalr",       1'b0,  1'b0,  1'b1,  1'b0},
        '{"movz",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"movn",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"srl",        1'b1,  1'b0,  1'b1,  1'b0},
        '{"rotr",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"sra",        1'b1,  1'b0,  1'b1,  1'b0},
        '{"sllv",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"srlv",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"rotrv",      1'b1,  1'b0,  1'b1,  1'b0},
        '{"srav",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"subu",       1'b0,  1'b0,  1'b1,  1'b0},
        '{"and",        1'b1,  1'b0,  1'b1,  1'b0},
        '{"or",         1'b1,  1'b0,  1'b1,  1'b0},
        '{"xor",        1'b1,  1'b0,  1'b1,  1'b0},
        '{"nor",        1'b1,  1'b0,  1'b1,  1'b0},
        '{"slt",        1'b1,  1'b0,  1'b1,  1'b0},
        '{"sltu",       1'b1,  1'b0,  1'b1,  1'b0},
        '{"bltz",       1'b0,  1'b0,  1'b1,  1'b0},
        '{"bltzal",     1'b1,  1'b0,  1'b1,  1'b0},
        '{"bgez",       1'b0,  1'b0,  1'b1,  1'b0},
        '{"bgezal",     1'b1,  1'b0,  1'b1,  1'b0},
        '{"sb",         1'b1,  1'b0,  1'b1,  1'b0},
        '{"sh",         1'b1,  1'b0,  1'b1,  1'b0}
      };

    string manual_target_name[] = {
        "sys_serial_test",
        "print_string"
    };

    assign reg_file = unit_top.unit_core.unit_decode.unit_rf.file;
    assign reg_v  =  reg_file[3:2];
    assign reg_a  = reg_file[7:4];
    assign reg_s = reg_file[23:16];
    assign reg_t = {reg_file[25:24], reg_file[15:8]};
    always_comb begin
        write_dbg_memory =  unit_top.unit_memory.unit_debug_ram.mif.write;
        write_dbg_function_reg =  unit_top.unit_memory.unit_debug_ram.mif.addr == 0;
        dbg_arg = unit_top.unit_memory.unit_debug_ram.datas;
    end
    assign pc_mem_stage = unit_top.unit_core.unit_memory.pif.signal_out.pc;

    always_ff @(posedge clk)
        dbg_loaded <= write_dbg_memory & write_dbg_function_reg;

    function automatic string get_test_filename(string target);
        return {"asm/temp/", target, ".asm.hextext"};
    endfunction

    function automatic string get_data_filename(string target);
        return {"asm/temp/", target, ".asm.data.hextext"};
    endfunction

    function automatic string get_regchk_filename(string target);
        return  {"asm/temp/", target, ".asm.reg.hextext"};
    endfunction

    /* stop and dump pc */
    function automatic void stop_print_pc();
        $display("pc:[%8x]",pc_mem_stage);
        $stop;
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
        if(dbg_arg[1] == 32'h0000_0002) begin
            assert (dbg_arg[0] === 32'hffff_0000)
            else  $error("dbg(0) != 32'hffff_0000!");
            for(int i = 1; i < 8; ++i) begin
                assert (dbg_arg[i] === (1 << i))
                else begin
                   $error("sw_dbg failed: dbg(%0d) != %8h",i,dbg_arg[i]);
                   $stop;
                end
            end
        end
    endfunction
    
    /** check reg file **/
    function automatic void check_regfile(string filename,logic[31:0]  rf[31:0],logic ignore_gp_sp);
        logic[31:0]  temp[31:0];
        $readmemh(filename, temp);
        for(int i = 0; i < 32; ++i) begin
            if(ignore_gp_sp & (i == 28 | i == 29))
                continue;
            assert (temp[i] === rf[i]) 
            else  begin
                $error("register file check failed at %0d: %8h != %8h ",i,temp[i],rf[i]);
                stop_print_pc();
            end
        end
    endfunction

    task automatic do_one_cycle(
        input string target_name,
        ref logic assert_equal_hit,
        ref logic assert_not_equal_hit,
        ref logic check_register_file_hit,
        ref logic exit);
        
        string regchk_filename = get_regchk_filename(target_name);
        exit = '0;
        
        @(negedge clk) begin
            if(dbg_loaded !== '1)
                return;
            case(dbg_arg[0])
                0:begin
                    exit = 1;
                    $display("exit.");
                end
                /*  assert equal  */
                1: begin
                    if(!assert_equal_hit) assert_equal_hit = '1;
                    assert(dbg_arg[1] === dbg_arg[2])
                    else begin
                        $error("assert equal failed : %8h != %8h",dbg_arg[1],dbg_arg[2]);
                        stop_print_pc();
                    end
                end

                /*  assert not equal  */
                2:  begin
                    if(!assert_not_equal_hit) assert_not_equal_hit = '1;
                    assert(dbg_arg[1] !== dbg_arg[2])
                    else begin
                         $error("assert not equal failed : %8h == %8h",dbg_arg[1],dbg_arg[2]);
                         stop_print_pc();
                    end
                end

                /*  print four chars in dbg_arg[1]  */
                3:  begin
                    logic[31:0]  four_char = dbg_arg[1];
                    logic[7:0] one_char;
                    string message;
                    for(int i = 0; i < 4; ++i) begin
                        one_char = four_char[i*8 +:8];
                        if(one_char === '0 |  one_char  === 'x) begin
                            break;
                        end
                        message = {message,one_char};
                    end
                    $write(message);
                end

                /*  check register file  */
                32'h0001_0000: begin
                    if(!check_register_file_hit) check_register_file_hit = '1;
                    if(dbg_arg[1] === 32'h0001_0000) begin
                            //ignore $gp, $sp
                        $display("checking register file ignore $sp and $gp...");
                        check_regfile(regchk_filename, reg_file, 1);
                    end else begin   //check all
                        $display("checking register file...");
                        check_regfile(regchk_filename, reg_file, 0);
                    end
                end
                /*  check sw dbg  */
                32'hffff_0000: begin
                    for(int i = 0; i < 8; ++i) begin
                        $display("dbg(%0d) = %8h",i,dbg_arg[i]);
                    end   // check dbg_arg memory 
                    if(dbg_arg[1] === 32'h0000_0000)
                        return;

                    if(dbg_arg[1] === 32'h0000_0002) begin
                        check_sw_dbg_arg();
                    end else begin
                        $error("unsupport check:%8x, sub function:%8x",dbg_arg[0],dbg_arg[1]);    
                        stop_print_pc();
                    end
                end

                default: begin
                    $error("unsupport check:%8x",dbg_arg[0]);
                    stop_print_pc();
                end
            endcase
        end
    endtask

    task automatic new_test(input check_target_t target);
        string target_name = target.name;
        string test_filename =  get_test_filename(target_name);
        string data_filename =  get_data_filename(target_name);
        logic exit = 0;
        logic assert_equal_hit = '0;
        logic assert_not_equal_hit = '0;
        logic check_register_file_hit = '0;
        $display("");
        $display("");
        $display("-------------------------------------------------------------------------------------");
        $display("-------- testing %s...",test_filename);
        $readmemh(test_filename, unit_top.unit_memory.unit_ins_rom.im);
        $readmemh(data_filename, unit_top.unit_memory.unit_user_ram.datas);

        reset = 1;
        @(negedge clk) begin
            reset = 1;
        end
        
        @(negedge clk) begin
            reset = 0;
            if(target.sw_dbg_target) begin
                fill_regsiter_sw_dbg();
            end
        end

        while (~exit) begin
           do_one_cycle(
               target_name,
               assert_equal_hit,
            assert_not_equal_hit,
            check_register_file_hit,
            exit);
        end

        if(target.assert_equal & ~assert_equal_hit) begin
            $error("asm file require assert equal but program not hit once!");
            $stop;
        end
        if(target.assert_not_equal & ~assert_equal_hit) begin
            $error("asm file require assert not equal but program not hit once!");
            $stop;
        end
        if(target.check_register_file & ~check_register_file_hit) begin
            $error("asm file require check register file but program not require!");
            $stop;
        end
        $display("-------- %s finish.",test_filename);
        
    endtask

    check_target_t manual_check_target;
    initial begin
        // for(int i = 0; i < all_targets.size(); ++i)
        //     new_test(.target(all_targets[i]));
        // $finish;
        for(int i = all_targets.size() - 1; i < all_targets.size(); ++i)
            new_test(.target(all_targets[i]));
        $finish;
        //new_test(.target(all_targets[all_targets.size() - 3]));
        //new_test(.target(all_targets[all_targets.size() - 2]));
        //new_test(.target(all_targets[all_targets.size() - 1]));
        manual_check_target = '{"", 1'b0,  1'b0,  1'b0,  1'b0};
        // for(int i = manual_target_name.size() - 1; i < manual_target_name.size(); ++i) begin
        //     manual_check_target.name = manual_target_name[i];
        //     new_test(.target(manual_check_target));
        // end
        $finish;
        $finish;
    end


    
endmodule