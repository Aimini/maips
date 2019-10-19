from gen_com import *
import random,math,itertools

r = gen('lw')

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
        A("lw ${},{}(${})".format(rt, offset, reg_base))

        A(assert_equal_immed(rt, target_value & 0xFFFFFFFF))
        
def gen_word_in_memory(A,total_words):
    A(".data")
    A("word_arrary: .word ")
    for x in range(total_words - 1):
        A(f"0x{x:0>8X},")
    A(f"0x{total_words - 1:0>8X}")

def my_gen1(A,C,E):
    for i in range(32):
        A(f"li ${i},0")

    word_count_limit = 2**10 # 1k word
    data_segment_base = 0x10010000


    def test_one_address(word_count, offset):
        word_address = word_count*4 + data_segment_base
        base_address = word_address - offset
        gen_assert_one(A, get_one_writable_reg(), base_address, offset, word_count);
    
    def test_by_iter(word_cout,offset):
        parameter_iter_pass(word_cout,offset,callback = test_one_address)
        
    bound = get_bound_s16()
    # check from 0x10000000 to last word

    test_by_iter(range(word_count_limit), 0)

    test_by_iter(lambda : get_random_below(word_count_limit), 5*bound)
    test_by_iter(repeat_function(get_random_below ,word_count_limit ,time = 5000), get_s16);
    test_by_iter(lambda : get_random_below(word_count_limit), repeat_function(get_s16,time =5000));
    
    def do_some_math(word_count):
        offset = get_s16();
        word_address = word_count*4 + data_segment_base
        base_address = word_address - offset
        regs = get_random_exclude_reg(5)
        A(f"li ${regs[0]},{base_address}")
        A(f"lw ${regs[1]},{offset}(${regs[0]})")
        A(f"addu ${regs[2]},${regs[1]},${regs[3]}")
        A(f"addu ${regs[1]},${regs[1]},${regs[4]}")

    parameter_iter_pass(repeat_function(get_random_below ,word_count_limit ,time = 5000),callback = do_some_math)

    A(check_and_exit())
    gen_word_in_memory(A,word_count_limit)
r.gen(my_gen1)