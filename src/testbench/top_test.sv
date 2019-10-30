`include "src/top.sv"

module top_test();
    logic clk,reset;

    always begin
        clk = 1; #5ns;
        clk = 0; #5ns;
    end

    top unit_top(clk,reset);


    typedef struct {
        string name;
        logic assert_equal, assert_not_equal, check_register_file;
        logic sw_dbg_target;
        logic bin, kernel;
    } check_target_t;

    // string j_too_large = "j";
    // string jal_too_large = "jal"; // don't test j and jal if unnecessary, it'test file too large
    `include "src/testbench/top_test/test_target.sv"


`define reg_file unit_top.unit_core.unit_decode.unit_rf.file
`define reg_v(x) `reg_file[2 + x]
`define reg_a(x) `reg_file[4 + x]
`define reg_s(x) `reg_file[16 + x]
`define reg_t(x) `reg_file[x < 8 ? x + 8 : x + 24]

`define dbg_ram   unit_top.unit_memory.unit_debug_ram
`define dbg_data  `dbg_ram.datas
`define kernel_text unit_top.unit_memory.unit_kernel_ins_rom.im
`define kernel_data unit_top.unit_memory.unit_kernel_ram.datas
`define user_text   unit_top.unit_memory.unit_ins_rom.im
`define user_data   unit_top.unit_memory.unit_user_ram.datas

`define dbg_funct `dbg_data[0]
`define dbg_arg0  `dbg_data[1]
`define dbg_arg1  `dbg_data[2]


    logic[31:0] pc_mem_stage,insruction_fetch_stage;
    logic[31:0] invalid_instruction_count; 
    // indicate cpu is writing dbg memory.
    logic dbg_loaded;
    
    assign pc_mem_stage = unit_top.unit_core.unit_memory.pif.signal_out.pc;
    assign insruction_fetch_stage =  unit_top.unit_core.unit_fetch.instruction;
    always_ff @(posedge clk) begin
        dbg_loaded <= `dbg_ram.mif.write & `dbg_ram.mif.addr === 0;

        if(insruction_fetch_stage === 'x) begin
            invalid_instruction_count <= invalid_instruction_count + 1;
            if(invalid_instruction_count === 5)
                stop_print_pc();
        end else begin
            invalid_instruction_count <= 0;
        end
    end



    function automatic string get_test_filename(string target,logic bin);
        if(bin)
            return {"asm/temp/", target, ".text.bin"};
        else
            return {"asm/temp/", target, ".asm.hextext"};
    endfunction

    function automatic string get_data_filename(string target,logic bin);
        if(bin)
           return {"asm/temp/", target, ".data.bin"};
        else
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
       `reg_v(0) = 32'hffff0000; //v0 = 0xFFFF0000
       for(int i = 0; i < 8; ++i)
            `reg_s(i) =  1 << i; //s0 - s7
        `reg_s(0) = 32'hffff0000; //s0 = 0xFFFF0000
    endfunction


    function automatic void check_sw_dbg_data();
        if(`dbg_arg0  === 32'h0000_0002) begin
            assert (`dbg_funct === 32'hffff_0000)
            else  $error("dbg(0) != 32'hffff_0000!");
            for(int i = 1; i < 8; ++i) begin
                assert (`dbg_data[i] === (1 << i))
                else begin
                   $error("sw_dbg failed: dbg(%0d) != %8h",i,`dbg_data[i]);
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

            case(`dbg_funct)
                0:begin
                    exit = 1;
                end

                1: begin// -------------------- assert equal ---------------------- 
                    if(!assert_equal_hit) assert_equal_hit = '1;
                    assert(`dbg_arg0 === `dbg_arg1)
                    else begin
                        $error("assert equal failed : %8h != %8h",`dbg_data[1],`dbg_data[2]);
                        stop_print_pc();
                    end
                end

                /*  assert not equal  */
                2:  begin// ----------------- assert not equal ---------------------- 
                    if(!assert_not_equal_hit) assert_not_equal_hit = '1;
                    assert(`dbg_arg0 !== `dbg_arg1)
                    else begin
                         $error("assert not equal failed : %8h == %8h",`dbg_data[1],`dbg_data[2]);
                         stop_print_pc();
                    end
                end

                
                3:  begin// ----------- print four chars in `dbg_arg0 ----------- 
                    logic[31:0]  four_char = `dbg_arg0;
                    logic[7:0]   one_char;
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

                4:  begin //------------------------ print int ---------------------
                    $write("%d", `dbg_arg0);
                end

                32'h0001_0000: begin// ----- - check register file ------------------ 
                    check_register_file_hit = check_register_file_hit | '1;
                    if(`dbg_arg0 === 32'h0001_0000) begin
                        //ignore $gp, $sp
                        $display("checking register file ignore $sp and $gp...");
                        check_regfile(regchk_filename, `reg_file, 1);
                    end else begin   //check all
                        $display("checking register file...");
                        check_regfile(regchk_filename, `reg_file, 0);
                    end
                end

                32'hffff_0000: begin// ----- - check sw dbg  ------------------ 
                    for(int i = 0; i < 8; ++i) begin
                        $display("dbg(%0d) = %8h",i,`dbg_data[i]);
                    end   // check `dbg_data memory 
                    if(`dbg_arg0 === 32'h0000_0000)
                        return;

                    if(`dbg_arg0 === 32'h0000_0002) begin
                        check_sw_dbg_data();
                    end else begin
                        $error("unsupport check:%8x, sub function:%8x",`dbg_funct,`dbg_arg0);    
                        stop_print_pc();
                    end
                end

                default: begin
                    $error("unsupport check:%8x",`dbg_data[0]);
                    stop_print_pc();
                end
            endcase
        end
    endtask

`define LOAD_MEM_FILE(_MEM,_FILENAME)              \
    begin                                          \
        int __HANDLE = $fopen(_FILENAME,"rb");     \
        int __I = 0;                               \
        int __RES;                                 \
        logic[31:0] __BUF;                         \
        while(!$feof(__HANDLE)) begin              \
            __RES = $fread(__BUF,__HANDLE);        \
            __BUF = {<<8{__BUF}};                  \
            _MEM[__I >> 2] = __BUF;                \
            __I += __RES;                          \
        end                                        \
        $fclose(__HANDLE);                         \
    end

    task automatic load_text_data(input check_target_t target);
        string test_filename =   get_test_filename(target.name,target.bin);
        string data_filename  =  get_data_filename(target.name,target.bin);
        if(~target.bin) begin
            if(target.kernel) begin
                $readmemh(test_filename, `kernel_text);
                $readmemh(data_filename, `kernel_data);
            end else begin
                $readmemh(test_filename, `user_text);
                $readmemh(data_filename, `user_data);
            end
        end else begin
            if(target.kernel) begin
                 `LOAD_MEM_FILE(`kernel_text, test_filename);
                 `LOAD_MEM_FILE(`kernel_data, data_filename);
             end else begin
                 `LOAD_MEM_FILE(`user_text, test_filename);
                 `LOAD_MEM_FILE(`user_data, data_filename);
             end
        end
    endtask


    task automatic new_test(input check_target_t target);
        string target_name = target.name;
        logic exit = 0;
        logic assert_equal_hit = '0;
        logic assert_not_equal_hit = '0;
        logic check_register_file_hit = '0;

        load_text_data(target);

        $display("");
        $display("");
        $display("-------------------------------------------------------------------------------------");
        $display("-------- testing %s...",target_name);


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
        $display("-------- %s finish.",target_name);
    endtask

    task automatic new_test_by_name(string name,uisng);
        logic found = '0;
       for(int i = 0; i < all_targets.size(); ++i) begin
            if(name == all_targets[i].name) begin
                new_test(all_targets[i]);
                found = '1;
                break;
            end
        end
        assert(found) 
        else $error("test target name %s not found.",name);
    endtask

    task automatic new_execution(input string program_name);
        logic exit             = '0;
        logic assert_equal_hit = '0;
        logic assert_not_equal_hit = '0;
        logic check_register_file_hit = '0;
    
        $display("");
        $display("");
        $display("-------------------------------------------------------------------------------------");
        $display("-------- loading text and data %s...",program_name);

        `LOAD_MEM_FILE(unit_top.unit_memory.unit_ins_rom.im,     {"c/temp/",program_name,".text.bin"});
        `LOAD_MEM_FILE(unit_top.unit_memory.unit_user_ram.datas, {"c/temp/",program_name,".data.bin"});
        /************************** load kernel **********************/
        `LOAD_MEM_FILE(unit_top.unit_memory.unit_kernel_ins_rom.im, "c/temp/kernel.text.bin");
        `LOAD_MEM_FILE(unit_top.unit_memory.unit_kernel_ram.datas,  "c/temp/kernel.data.bin");

        $display("#################################################################");
        $display("#################################################################");
        reset = 1;
        @(negedge clk) begin
            reset = 1;
        end
        @(negedge clk) begin
            reset = 0;
        end
        while (~exit) begin
           do_one_cycle(
               "",
            assert_equal_hit,
            assert_not_equal_hit,
            check_register_file_hit,
            exit);
        end
        $display("#################################################################");
        $display("#################################################################");
        $display("-------- %s finish.",program_name);

    endtask

    check_target_t manual_check_target;
    int test = 0;
    int test_number = 1; // if test_number > 0 ,test last <test_number> case, else test all.
    initial begin
        // new_test_by_name("addu");
        if(test === 0) begin    
            for(int i = test_number > 0 ? all_targets.size() - test_number : 0; i < all_targets.size(); ++i)
                new_test(.target(all_targets[i]));
            $finish;
        end else if (test === 1) begin
            new_execution("main");    
        end

        manual_check_target = '{"", 1'b0,  1'b0,  1'b0,  1'b0,  1'b0,  1'b0};
        // for(int i = manual_target_name.size() - 1; i < manual_target_name.size(); ++i) begin
        //     manual_check_target.name = manual_target_name[i];
        //     new_test(.target(manual_check_target));
        // end
        $finish;
    end


    
endmodule