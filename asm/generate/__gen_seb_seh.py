from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *
import random
import math
import itertools
import sys


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
            return x | mask
        else:
            return x & ~mask

    def my_gen1(A, au):
        def gen_assert_one(reg, value):
            if reg == reg_zero:
                value = 0

            au.li(reg, value)
            rd = regutil.get_one(exclude=[reg])
            A(f"{cmd}      {rd},{reg}")
            au.assert_equal(rd,  calculate_funct(value))

        parameter_iter_pass(reg_list, numutil.bound(8), callback=gen_assert_one)
        parameter_iter_pass(lambda: regutil.get_one(), 5*numutil.bound(8), callback=gen_assert_one)
        parameter_iter_pass(lambda: regutil.get_one(), repeat_function(numutil.u32, k=5000), callback=gen_assert_one)

        au.check_and_exit()
    r.gen(my_gen1)


gen_when(sys.argv[1])
