from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random,math,itertools



def gen_assert_one(A,au,reg_base,base,offset,target_value):
        au.li(reg_base, base)
        
        rt = regutil.get_one()
        A("lb {},{}({})".format(rt, offset, reg_base))

        au.assert_equal(rt, numutil.sign8(target_value) & 0xFFFFFFFF)
        


def my_gen1(A,au):
    mode = "byte"
    for i in range(32):
        au.li(reg_list[i],0)

    half_count_limit = 2**12 # 2k half word
    data_segment_base = 0x10010000
    memory_datas = [numutil.s8() for x in range(half_count_limit)];

    def gen_word_in_memory(A,total_halfs):
        A(".data")
        A(f"word_arrary: .{mode} ")
        for x in memory_datas:
            A("{},".format(numutil.sign8(x)))

    def convert_adddress(count):
        if mode is "half":
            count *= 2
        elif mode is "word":
            count *= 4
        return data_segment_base + count
            
    def test_one_address(count, offset):
        address = convert_adddress(count)
        base_address = address - offset
        gen_assert_one(A,au, regutil.get_one(), base_address, offset, memory_datas[count])
    
    def test_by_iter(word_cout,offset):
        parameter_iter_pass(word_cout,offset,callback = test_one_address)

    offset_bound =numutil.bound(16,True)

    test_by_iter(range(half_count_limit), 0)
    test_by_iter(lambda : numutil.below(half_count_limit), 5*offset_bound)
    test_by_iter(repeat_function(numutil.below ,half_count_limit ,k = 5000), numutil.s16);
    test_by_iter(lambda : numutil.below(half_count_limit), repeat_function(numutil.s16,k = 5000));
    
    def do_some_math(count):
        offset = numutil.s16()
        address = convert_adddress(count)
        base_address = address - offset
        regs = regutil.get_random(k = 5)
        A(f"li {regs[0]},{base_address}")
        A(f"lb {regs[1]},{offset}({regs[0]})")
        A(f"addu {regs[2]},{regs[1]},{regs[3]}")
        A(f"addu {regs[1]},{regs[1]},{regs[4]}")

    parameter_iter_pass(repeat_function(numutil.below ,half_count_limit ,k = 5000),callback = do_some_math)

    au.check_and_exit()
    gen_word_in_memory(A,half_count_limit)
    return ["mars","-d"]

r = gen('lb')
r.gen(my_gen1)