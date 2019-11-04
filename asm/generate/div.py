from __asmutil import *
from __gencom  import *

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

        
        if reg2_val != 0:
            signed_val1 = numutil.sign32(reg1_val)
            signed_val2 = numutil.sign32(reg2_val)
            #using c style div
            abs_val1 = abs(signed_val1)
            abs_val2 = abs(signed_val2)
            quotient = int(abs_val1 / abs_val2);
            remainder = abs_val1 % abs_val2;
            if signed_val1 & 0x80000000:
               remainder = -remainder
            if (signed_val1 & 0x80000000)^(signed_val2 & 0x80000000):
               quotient = -quotient  

            au.li(reg1, reg1_val)
            au.li(reg2, reg2_val)

            A("div {},{}".format(reg1,reg2))


            retrive_reg = regutil.get_random(k = 2)
            A("mfhi {}".format(retrive_reg[0]))
            au.assert_equal(retrive_reg[0],remainder & 0xFFFFFFFF)

            A("mflo {}".format(retrive_reg[1]))  
            au.assert_equal(retrive_reg[1],quotient & 0xFFFFFFFF)
            

    parameter_iter_pass(regutil.get_one, numutil.bound(32),  reg_list,           numutil.u32, callback = gen_assert_one)
    parameter_iter_pass(reg_list,           numutil.bound(32),  regutil.get_one, numutil.u32, callback = gen_assert_one)
    parameter_iter_pass(reg_list,           numutil.u32,        reg_list,           numutil.u32, callback = gen_assert_one)
    au.check_and_exit()

r = gen('div')
r.gen(my_gen1)
