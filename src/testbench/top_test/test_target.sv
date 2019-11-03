    typedef struct {
        string name;
        logic assert_equal, assert_not_equal, check_register_file;
        logic sw_dbg_target;
        logic addrbin, kernel;
    } check_target_t;
    check_target_t all_targets[] = 
    '{ 
        '{"sw_dbg",     1'b0,  1'b0,  1'b0,  1'b1, 1'b0, 1'b0},
        '{"lui_1",      1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"lui_2",      1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"ori_1",      1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"ori_2",      1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"sll_1",      1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"sll_2",      1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"addu",       1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"j",          1'b0,  1'b0,  1'b1,  1'b0, 1'b1, 1'b0},
        '{"jal",        1'b0,  1'b0,  1'b1,  1'b0, 1'b1, 1'b0},
        '{"addiu",      1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"beq",        1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"bne",        1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"blez",       1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"bgtz",       1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"slti",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"sltiu",      1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"andi_1",     1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"andi_2",     1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"xori_1",     1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"xori_2",     1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"mthi_mfhi",  1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"mtlo_mflo",  1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"multu",      1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"divu",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"mult",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"div",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"maddu",      1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"madd",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"msubu",      1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"msub",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"mul",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"clz",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"clo",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"lw",         1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"lh",         1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"lb",         1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"jr",         1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"jalr",       1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"movz",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"movn",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"srl",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"rotr",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"sra",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"sllv",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"srlv",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"rotrv",      1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"srav",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"subu",       1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"and",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"or",         1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"xor",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"nor",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"slt",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"sltu",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"bltz",       1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"bltzal",     1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"bgez",       1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"bgezal",     1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"sb",         1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"sh",         1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"sw",         1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"lbu",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"lhu",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"lwr_swr",    1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"lwl_swl",    1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"ext",        1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"ins",        1'b0,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"seb",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"seh",        1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"wsbh",       1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        '{"mfc0_mtc0",  1'b1,  1'b0,  1'b1,  1'b0, 1'b0, 1'b0},
        // --------------------- exception ---------------------
        '{"syscall",    1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"tge",        1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"tgeu",       1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"tlt",        1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"tltu",       1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"teq",        1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"tne",        1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        
        '{"tgei",            1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"tgeiu",           1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"tlti",            1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"tltiu",           1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"teqi",            1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"tnei",            1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"ov_add",          1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"ov_sub",          1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"ov_addi",         1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"unalign_load",    1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"unalign_store",   1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"unalign_pc",      1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"reserved",        1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"cop0_unusable",   1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"soft_interrupt",  1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"di_ei",           1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"ll_sc",           1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1},
        '{"read_instruction",1'b1,  1'b0,  1'b0,  1'b0, 1'b0, 1'b1}
      };

    string manual_target_name[] = {
        "sys_serial_test",
        "print_string"
    };