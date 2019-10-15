from gen_com import *
import random

r = gen('mthi_mfhi')

######################
# A: asm writer function
# reg:          which reg you want to move to HI
# reg_val : which value store in reg
# immed:
def gen_assert_one(A,reg,reg_val):
        # although immed is sign extend ,but we still use unsign compare
        #sval = cutto_sign32(reg_val)
        
        
        A("li ${},0x{:0>8x}".format(reg, reg_val))
        A("mthi ${}".format(reg))
        #don't use $1($at) it's may be overwritted by pseudo instruction
        retrive_reg = random.choice(range(2,32))
        A("mfhi ${}".format(retrive_reg))
        A(assert_equal_immed(retrive_reg,reg_val))
        
            
def gen_partial(A,reg_val_gen,time = 1024):
    #zero 
    for i in range(32):
        reg = i % 32
        reg_val = reg_val_gen()
        # $s0 always being zero
        if reg == 0:
            reg_val = 0
        gen_assert_one(A,reg,reg_val);

def my_gen1(A,C,E):
    reg_sample = [0,0x43218765,0x7FFFFFFF,0x80000000,0x80000001,0xAB12CD45,0xFFFFFFFF]
    for reg in range(1,32):
        for r in reg_sample:
            gen_assert_one(A,reg,r)

    gen_partial(A , lambda : random.choice(range(2**32)))

    for i in range(4096):
        se = random.choice(range(0,10))
        if se <= 4:
            rreg = random.choice(range(0,32))
            A("li ${},0x{:0>8x}".format(reg, random.choice(range(2**32))))
        if se > 4:
            rreg = random.sample(range(0,32),k= 3)
            A("addu ${},${},${}".format(*rreg))
        if se  == 8:
            rreg = random.choice(range(0,32))
            A("mthi ${}".format(rreg))
        if se  == 9:
            rreg = random.choice(range(0,32))
            A("mfhi ${}".format(rreg))

    A(check_and_exit())
r.gen(my_gen1)
