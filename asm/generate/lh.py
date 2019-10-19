from gen_com import *
import random,math,itertools

r = gen('lh')

######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

def gen_assert_one(A,reg_base,base,offset,target_value):
        # although immed is sign extend ,but we still use unsign compare
        #sval = cutto_sign32(reg_val)
        if reg_base == 0:
            base = 0

        A(set_immed(reg_base, base))
        
        rt = random.choice(range(1,32))
        A("lh ${},{}(${})".format(rt, offset, reg_base))

        A(assert_equal_immed(rt, cutto_sign32(target_value) & 0xFFFFFFFF))
        


def my_gen1(A,C,E):
    mode = "half"
    for i in range(32):
        A(f"li ${i},0")

    half_count_limit = 2**11 # 2k half word
    data_segment_base = 0x10010000
    memory_datas = [get_s16() for x in range(half_count_limit)];

    def gen_word_in_memory(A,total_halfs):
        A(".data")
        A(f"word_arrary: .{mode} ")
        for x in memory_datas:
            A("{},".format(cutto_sign16(x % 2**16)))

    def convert_adddress(count):
        if mode is "half":
            count *= 2
        elif mode is "word":
            count *= 4
        return data_segment_base + count
            
    def test_one_address(count, offset):
        address = convert_adddress(count)
        base_address = address - offset
        gen_assert_one(A, get_one_writable_reg(), base_address, offset, memory_datas[count])
    
    def test_by_iter(word_cout,offset):
        parameter_iter_pass(word_cout,offset,callback = test_one_address)

    offset_bound = get_bound_s16()

    test_by_iter(range(half_count_limit), 0)
    test_by_iter(lambda : get_random_below(half_count_limit), 5*offset_bound)
    test_by_iter(repeat_function(get_random_below ,half_count_limit ,time = 5000), get_s16);
    test_by_iter(lambda : get_random_below(half_count_limit), repeat_function(get_s16,time = 5000));
    
    def do_some_math(count):
        offset = get_s16()
        address = convert_adddress(count)
        base_address = address - offset
        regs = get_random_exclude_reg(5)
        A(f"li ${regs[0]},{base_address}")
        A(f"lh ${regs[1]},{offset}(${regs[0]})")
        A(f"addu ${regs[2]},${regs[1]},${regs[3]}")
        A(f"addu ${regs[1]},${regs[1]},${regs[4]}")

    parameter_iter_pass(repeat_function(get_random_below ,half_count_limit ,time = 5000),callback = do_some_math)

    A(check_and_exit())
    gen_word_in_memory(A,half_count_limit)
r.gen(my_gen1)