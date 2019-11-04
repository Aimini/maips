from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *
import random


def gen_assert_one(A, au, reg, sel, reg_val):
        # although immed is sign extend ,but we still use unsign compare
        #sval = numutil.sign32(reg_val)
        gpr = regutil.get_one()
        au.li(gpr, reg_val)
        A("mtc0 {},${},{}".format(gpr, reg, sel))
        #don't use $1($at) it's may be overwritted by pseudo instruction
        retrive_reg = regutil.get_one()
        A("mfc0 {},${},{}".format(retrive_reg, reg, sel))
        au.assert_equal(retrive_reg, reg_val)


cp0_regs = [[8, 0],
            [12, 0],
            [13, 0],
            [14, 0],
            [15, 1],
            [30, 0]]


def get_random_cp0():
    return random.choice(cp0_regs)


def my_gen1(A, au):
    au.clear_reg()
    for reg, sel in cp0_regs:
        A(f"mtc0 $0,${reg},{sel}")

    reg_sample = numutil.bound(32)
    for cp0 in cp0_regs:
        for r in reg_sample:
            gen_assert_one(A, au, cp0[0], cp0[1], r)

    for i in range(14096):
        se = random.choice(range(0, 10))
        if se <= 4:
            reg = regutil.get_one()
            au.li(reg, numutil.u32())
        if se > 4:
            rreg = regutil.get_random(k=3)
            A("addu {},{},{}".format(*rreg))
        if se == 8:
            cp0 = get_random_cp0()
            gpr = regutil.get_one()
            A("mtc0 {},${},{}".format(gpr, cp0[0], cp0[1]))
        if se == 9:
            cp0 = get_random_cp0()
            gpr = regutil.get_one()
            A("mfc0 {},${},{}".format(gpr, cp0[0], cp0[1]))
    au.check_and_exit()
    return ["mars","-D"]

r = gen('mfc0_mtc0')
r.gen(my_gen1)
