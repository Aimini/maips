from gen_com import *
import random

r = gen('sltiu')

######################
# A: asm writer function
# reg: which reg you want to compare to immed
# reg_val : value storage in reg
# immed:
def gen_assert_one(A,reg,reg_val,immed):
        # although immed is sign extend ,but we still use unsign compare
        sval = cutto_sign32(reg_val)
        simmed = cutto_sign16(immed)
        extend_immed = immed
        if immed >= 2**15:
            extend_immed = immed + 0xFFFF0000
            
        reg_set = random.choice(range(1,32))
        A("li ${},{}".format(reg, sval))
        A("sltiu ${},${},{}".format(reg_set,reg,simmed))
        if reg_val < extend_immed:
            A(assert_equal_immed(reg_set,1))
        else:
            A(assert_equal_immed(reg_set,0))
            
def gen_partial(A,reg_val_gen,immed_gen):
    #zero 
    for i in range(1024):
        reg = i % 32
        reg_val = reg_val_gen()
        immed = immed_gen()
        # $s0 always being zero
        if reg == 0:
            reg_val = 0
        gen_assert_one(A,reg,reg_val,immed);

def my_gen1(A,C,E):
    reg_sample = [0,0x7FFFFFFF,0x80000000,0x80000001,0xFFFFFFFF]
    immed_sample = [0,0x1234,0x7FFF,0x8000,0x8001,0xFFFF]
    for reg in range(1,31):
        for r in reg_sample:
            for i in immed_sample:
                gen_assert_one(A,reg,r,i)

    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : 0)
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : 1)
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : 0xFFFF)
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : 0x7FFF)
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : 0x8000)
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : random.choice(range(0,2**15)))
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : random.choice(range(2**15,2**16)))
    gen_partial(A , lambda : 0 , lambda : random.choice(range(0,2**16)))
    gen_partial(A , lambda : 0x7FFFFFFF , lambda : random.choice(range(0,2**16)))
    gen_partial(A , lambda : 0x80000000 , lambda : random.choice(range(0,2**16)))
    gen_partial(A , lambda : 0xFFFFFFFF , lambda : random.choice(range(0,2**16)))
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : random.choice(range(0,2**16)))
    A(check_and_exit())
r.gen(my_gen1)
