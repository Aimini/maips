from gen_com import *
import random

r = gen('mfc0_mtc0')

######################
# A: asm writer function
# reg:          which reg you want to move to HI
# reg_val : which value store in reg
# immed:
def gen_assert_one(A,reg,sel,reg_val):
        # although immed is sign extend ,but we still use unsign compare
        #sval = cutto_sign32(reg_val)
        gpr = get_random_exclude_reg(k = 1)[0]
        A("li ${},0x{:0>8x}".format(gpr, reg_val))
        A("mtc0 ${},${},{}".format(gpr,reg,sel))
        #don't use $1($at) it's may be overwritted by pseudo instruction
        retrive_reg = get_random_exclude_reg(k = 1)[0]
        A("mfc0 ${},${},{}".format(retrive_reg,reg,sel))
        A(assert_equal_immed(retrive_reg,reg_val))

cp0_regs = [[8,0],
    [12, 0],
    [13, 0],
    [14, 0],
    [15, 1],
    [30, 0]]

def get_random_cp0():
    return random.choice(cp0_regs)
            


def my_gen1(A,C,E):
    for i in range(32):
        A(f"li ${i},0")
    for reg,sel in cp0_regs:
        A(f"mtc0 $0,${reg},{sel}")
    reg_sample = get_bound(32)
    for cp0 in cp0_regs:
        for r in reg_sample:
            gen_assert_one(A,cp0[0],cp0[1],r)
    
    for i in range(14096):
        se = random.choice(range(0,10))
        if se <= 4:
            reg = get_random_exclude_reg(k = 1)[0]
            A(f"li ${reg},0x{get_u32():0>8x}")
        if se > 4:
            rreg = random.sample(range(0,32),k= 3)
            A("addu ${},${},${}".format(*rreg))
        if se  == 8:
            cp0 = get_random_cp0()
            gpr = get_random_exclude_reg(k = 1)[0]
            A("mtc0 ${},${},{}".format(gpr,cp0[0],cp0[1]))
        if se  == 9:
            cp0 = get_random_cp0()
            gpr = get_random_exclude_reg(k = 1)[0]
            A("mfc0 ${},${},{}".format(gpr,cp0[0],cp0[1]))

    A(check_and_exit())
r.gen(my_gen1)
