from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *

def pre_gen(A,au,ito,ifrom):
    def gen_assert_one(reg,reg_val):
        au.li(reg, reg_val)
        if reg == reg_zero:
            reg_val = 0

        A(f"{ito}  {reg}")
        retrive_reg = regutil.get_one()
        A(f"{ifrom} {retrive_reg}")
        au.assert_equal(retrive_reg,reg_val)

    parameter_iter_pass(reg_list,                         numutil.bound(32),                    callback = gen_assert_one)
    parameter_iter_pass(lambda : random.choice(reg_list), repeat_function(numutil.u32,k = 1000),callback = gen_assert_one)

    for i in range(4096):
        se = numutil.below(10)
        rreg = regutil.get_one()
        if se <= 4:
            au.li(rreg, numutil.u32())
        if se > 4 and se < 8:
            rreg = regutil.get_random(k = 3)
            A("addu {},{},{}".format(*rreg))
        if se  == 8:
            A(f"{ito} {rreg}")
        if se  == 9:
            A(f"{ifrom} {rreg}")
    au.check_and_exit()
    # return ["mars","-D"]