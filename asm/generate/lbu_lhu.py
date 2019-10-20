from gen_com import *
import random,math,itertools,sys



######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

def random_get_alu():
    reg = get_random_exclude_reg(k = 3)
    triple_arg = f"${reg[0]},${reg[1]},${reg[2]}"
    double_arg = f"${reg[0]},${reg[1]}"
    single_arg = f"${reg[0]}"
    statement = [f"addu {triple_arg}",
    f"subu  {triple_arg}",
    f"and   {triple_arg}",
    f"or    {triple_arg}",
    f"xor   {triple_arg}",
    f"nor   {triple_arg}",
    f"slt   {triple_arg}",
    f"sltu  {triple_arg}",
    f"mult  {double_arg}",
    f"multu {double_arg}",
    f"mfhi  {single_arg}",
    f"mthi {single_arg}",
    f"mflo {single_arg}",
    f"mtlo {single_arg}"]
    return random.choice(statement)

def gen_when(load_cmd):
    r = gen(load_cmd)
    
    byte_per_unit = 1
    if load_cmd == "lbu":
        cmd = "sb"
        byte_per_unit = 1
    else:
        cmd = "sh"
        byte_per_unit = 2

    total_bit = byte_per_unit*8
    max_limit = 2**total_bit
    
    def my_gen1(A,C,E):
        def gen_assert_one(A,reg_base,base,offset,target_value):
            A(set_immed(reg_base, base))
            value_mask = max_limit  - 1
            rt = get_random_exclude_reg(k = 1,exclude = [reg_base])[0]
            A(set_immed(rt,target_value))
            A(f"{cmd}      ${rt},{offset}(${reg_base})")
            rt = random.choice(range(1,32))
            A(f"{load_cmd} ${rt},{offset}(${reg_base})")
            A(assert_equal_immed(rt,  target_value))

        data_segment_base = 0x10010000
        def convert_adddress(count):
                return data_segment_base + count*byte_per_unit

        def get_random_offset(conut):
            addr = convert_adddress(conut)
            offset = get_s16()
            return addr - offset, offset

        def test_one_address(count, offset):
            address = convert_adddress(count)
            base_address = address - offset
            gen_assert_one(A, get_one_writable_reg(), base_address, offset, memory_datas[count])
        
        def test_by_iter(word_cout,offset):
            parameter_iter_pass(word_cout,offset,callback = test_one_address)



        count_limit = int(2**12 /byte_per_unit)  # 2k half word
        data_segment_base = 0x10010000
        data_gen_funct = lambda : get_random_below(max_limit)
        memory_datas = [data_gen_funct() for x in range(count_limit)];

     
        offset_bound = get_bound_s16()
        for i in range(32):
            A(f"li ${i},0")

        test_by_iter(range(count_limit), 0)
        test_by_iter(lambda : get_random_below(count_limit), 5*offset_bound)
        test_by_iter(repeat_function(get_random_below ,count_limit ,time = 5000), get_s16);
        test_by_iter(lambda : get_random_below(count_limit), repeat_function(get_s16,time = 5000));
        
        # move content form one cell to another cell
        for i in range(5000):
            read_base, read_offset = get_random_offset(get_random_below(count_limit))
            write_base,write_offset =  get_random_offset(get_random_below(count_limit))
            base1,base2 = get_random_exclude_reg(k =2)
            A(set_immed(base1,read_base))
            A(set_immed(base2,write_base))
            A(f"{load_cmd} ${base1} {read_offset} (${base1})")
            A(f"{cmd}      ${base1} {write_offset}(${base2})")

        #  read memory
        # do some math
        # write back
        def do_some_math(count):
            offset = get_s16()
            base_address,offset = get_random_offset(get_random_below(count_limit))
            reg = get_random_exclude_reg(k = 1)[0]
            A(set_immed(reg,base_address))
            A(f"{load_cmd} ${reg},{offset}(${reg})")
            for i in range(random.choice(range(20))):
                A(random_get_alu())
            reg = get_random_exclude_reg(k = 1)[0]
            A(set_immed(reg,base_address))
            A(f"{cmd} ${reg},{offset}(${reg})")
            

        parameter_iter_pass(repeat_function(get_random_below ,count_limit ,time = 5000),callback = do_some_math)

        A(check_and_exit())
    r.gen(my_gen1)
gen_when(sys.argv[1])