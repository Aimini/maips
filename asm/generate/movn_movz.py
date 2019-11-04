from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random,math,itertools
def gen_when(cmd):

    r = gen(cmd)

    def gen_assert_one(A,au,reg, value, reg2, condition_value):
            # although immed is sign extend ,but we still use unsign compare
            #sval = numutil.sign32(reg_val)
            if reg == reg_zero:
                value = 0
            if reg2 == reg_zero:
                condition_value = 0

            au.li(reg, value)
            au.li(reg2, condition_value)
            
            rd = regutil.get_one([reg2])
            rd_value = numutil.u32()
            au.li(rd, rd_value)
            if reg == rd:
                value = rd_value
            A(f"{cmd} {rd},{reg},{reg2}")
            if cmd == "movz" and condition_value == 0 or cmd == "movn" and condition_value != 0 :
                au.assert_equal(rd, value & 0xFFFFFFFF)
            
            else:
                au.assert_equal(rd, rd_value & 0xFFFFFFFF)


    def my_gen1(A,au):
        for i in range(32):
            au.li(reg_list[i],0)


        
        def test_one(value, condition_value):
            reg = regutil.get_random(k = 2)
            gen_assert_one(A,au, reg[0], value, reg[1], condition_value)
        
        def test_by_iter(word_cout,offset):
            parameter_iter_pass(word_cout,offset,callback = test_one)

        offset_bound =numutil.bound(16,True)

        test_by_iter(numutil.u32, 5*numutil.bound(32,False))
        test_by_iter(repeat_function(numutil.u32,k = 5000), numutil.u32())
        test_by_iter(5*numutil.bound(32,False), numutil.u32())
        

        au.check_and_exit()

    r.gen(my_gen1)


gen_when("movz")
gen_when("movn")