from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *


def pre_gen(A, au, cmp, op):
    def gen_assert_one(reg_val, immed):
        reg, reg_set = regutil.get_random(k=2)
        au.li(reg, reg_val)
        A(f"{op} {reg_set},{reg},{immed}")

        if cmp(reg_val, immed):
            au.assert_equal(reg_set, 1)
        else:
            au.assert_equal(reg_set, 0)

    parameter_iter_pass(numutil.bound(32),                   numutil.bound(16,True), callback = gen_assert_one)
    parameter_iter_pass(numutil.u32,                         numutil.bound(16,True), callback = gen_assert_one)
    parameter_iter_pass(numutil.bound(32),                   numutil.s16,           callback = gen_assert_one)
    parameter_iter_pass(repeat_function(numutil.u32,k=5000), numutil.s16,       callback = gen_assert_one)
    au.check_and_exit()
    # return ["mars","-D"]
