from gen_com import *
import random,math,itertools,sys



######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:



def gen_when(cmd):
    r = gen(cmd)
    
    def calculate_funct(x):
        if cmd == "seb":
            bit_num = 8
        elif cmd == "seh":
            bit_num = 16

        sign_mask = 1 << (bit_num - 1)
        sign = x & sign_mask
        mask = 2**32 - 1 << bit_num
        if sign > 0:
            return x | mask;
        else:
            return x & ~mask;

    
    def my_gen1(A,C,E):
        def gen_assert_one(reg, value):
            if reg == 0:
                value = 0;
            
            A(set_immed(reg, value))
            rd = get_random_exclude_reg(k = 1,exclude = [reg])[0]
            A(f"{cmd}      ${rd},${reg}")
            A(assert_equal_immed(rd,  calculate_funct(value)))


        parameter_iter_pass(range(32), get_bound(8),callback = gen_assert_one)
        parameter_iter_pass(lambda : get_random_below(32), 5*get_bound(8),callback = gen_assert_one)
        parameter_iter_pass(lambda : get_random_below(32), repeat_function(get_u32,time = 5000),callback = gen_assert_one);


        A(check_and_exit())
    r.gen(my_gen1)
gen_when(sys.argv[1])