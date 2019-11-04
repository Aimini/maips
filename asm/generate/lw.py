from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random,math,itertools

r = gen('lw')

######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

def gen_assert_one(A,au,reg_base,base,offset,target_value):
        au.li(reg_base, base)
        
        rt = regutil.get_one()
        A("lw {},{}({})".format(rt, offset, reg_base))

        au.assert_equal(rt, target_value & 0xFFFFFFFF)
        
def gen_word_in_memory(A,total_words):
    A(".data")
    A("word_arrary: .word ")
    for x in range(total_words):
        A(numutil.sx8(x))

def my_gen1(A,au):
    for i in range(32):
        au.li(reg_list[i],0)

    word_count_limit = 2**10 # 1k word
    data_segment_base = 0x10010000


    def test_one_address(word_count, offset):
        word_address = word_count*4 + data_segment_base
        base_address = word_address - offset
        gen_assert_one(A, au, regutil.get_one(), base_address, offset, word_count);
    
    def test_by_iter(word_cout,offset):
        parameter_iter_pass(word_cout,offset,callback = test_one_address)
        
    bound = numutil.bound(16,True)
    # check from 0x10000000 to last word

    test_by_iter(range(word_count_limit), 0)

    test_by_iter(lambda : numutil.below(word_count_limit), 5*bound)
    test_by_iter(repeat_function(numutil.below ,word_count_limit ,k = 5000), numutil.s16)
    test_by_iter(lambda : numutil.below(word_count_limit), repeat_function(numutil.s16,k =5000))
    
    def do_some_math(word_count):
        offset = numutil.s16()
        word_address = word_count*4 + data_segment_base
        base_address = word_address - offset
        regs = regutil.get_random(5)
        A(f"li {regs[0]},{base_address}")
        A(f"lw {regs[1]},{offset}({regs[0]})")
        A(f"addu {regs[2]},{regs[1]},{regs[3]}")
        A(f"addu {regs[1]},{regs[1]},{regs[4]}")

    parameter_iter_pass(repeat_function(numutil.below ,word_count_limit ,k = 5000),callback = do_some_math)

    au.check_and_exit()
    gen_word_in_memory(A,word_count_limit)
    return ["mars","-d"]

r.gen(my_gen1)