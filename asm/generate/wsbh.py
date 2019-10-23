from gen_com import *
import random,math,itertools,sys



######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:




r = gen("wsbh")

def calculate_funct(x):
    return ((x >> 8)  & 0x00FF00FF) | ((x << 8) & 0xFF00FF00)


def my_gen1(A,C,E):
    def gen_assert_one(reg, value):
        if reg == 0:
            value = 0;
        
        A(set_immed(reg, value))
        rd = get_random_exclude_reg(k = 1,exclude = [reg])[0]
        A(f"wsbh      ${rd},${reg}")
        A(assert_equal_immed(rd,  calculate_funct(value)))


    parameter_iter_pass(range(32), get_bound(32),callback = gen_assert_one)
    parameter_iter_pass(lambda : get_random_below(32), 5*get_bound(32),callback = gen_assert_one)
    parameter_iter_pass(lambda : get_random_below(32), repeat_function(get_u32,time = 5000),callback = gen_assert_one);


    A(check_and_exit())
r.gen(my_gen1)