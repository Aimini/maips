from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random,math,itertools,sys



######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:




r = gen("wsbh")

def calculate_funct(x):
    return ((x >> 8)  & 0x00FF00FF) | ((x << 8) & 0xFF00FF00)


def my_gen1(A,au):
    def gen_assert_one(reg, value):
        if reg == reg_zero:
            value = 0;
        
        au.li(reg, value)
        rd = regutil.get_one(exclude = [reg])
        A(f"wsbh      {rd},{reg}")
        au.assert_equal(rd,  calculate_funct(value))


    parameter_iter_pass(reg_list, numutil.bound(32),callback = gen_assert_one)
    parameter_iter_pass(lambda : regutil.get_one(), 5*numutil.bound(32),callback = gen_assert_one)
    parameter_iter_pass(lambda : regutil.get_one(), repeat_function(numutil.u32,k = 5000),callback = gen_assert_one);


    au.check_and_exit()
r.gen(my_gen1)