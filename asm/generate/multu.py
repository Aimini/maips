from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random

r = gen('multu')


def my_gen1(A,au):
    def gen_assert_one(reg1,reg1_val,reg2,reg2_val):
        # although immed is sign extend ,but we still use unsign compare
        #sval = numutil.sign32(reg_val)
        if reg1 == reg_zero:
            reg1_val = 0
        if reg2 == reg_zero:
            reg2_val = 0
        if reg1 == reg2:
            reg1_val = reg2_val

        au.li(reg1, reg1_val)
        au.li(reg2, reg2_val)
        A(f"multu {reg1},{reg2}")
        result = reg1_val * reg2_val

        retrive_reg = regutil.get_random(k = 2)
        A("mfhi {}".format(retrive_reg[0]))
        au.assert_equal(retrive_reg[0],(result >> 32) & 0xFFFFFFFF)

        A("mflo {}".format(retrive_reg[1]))  
        au.assert_equal(retrive_reg[1],result & 0xFFFFFFFF)
            

    parameter_iter_pass(regutil.get_one, numutil.bound(32),  reg_list,           numutil.u32, callback = gen_assert_one)
    parameter_iter_pass(reg_list,           numutil.bound(32),  regutil.get_one, numutil.u32, callback = gen_assert_one)
    parameter_iter_pass(reg_list,           numutil.u32,        reg_list,           numutil.u32, callback = gen_assert_one)
    au.check_and_exit()
r.gen(my_gen1)
