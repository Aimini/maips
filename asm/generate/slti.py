from gen_com import *
import random

r = gen('slti')


def gen_partial(A,reg_val_gen,immed_gen):
    #zero 
    for i in range(1024):
        reg = i % 32
        reg_val = cutto_sign32(reg_val_gen())
        immed = cutto_sign16(immed_gen())
        if reg == 0:
            reg_val = 0
        A("")
        A("")
        reg_set = random.choice(range(1,32))
        A("li ${},{}".format(reg, reg_val))
        A("slti ${},${},{}".format(reg_set,reg,immed))
        if reg_val < immed:
            A(assert_equal_immed(reg_set,1))
        else:
            A(assert_equal_immed(reg_set,0))

def my_gen1(A,C,E):
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : 0)
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : 1)
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : 0xFFFF)
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : 0x7FFF)
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : 0x8000)
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : random.choice(range(2**15)))
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : random.choice(range(2**15,2**16)))
    gen_partial(A , lambda : 0, lambda : random.choice(range(2**16)))
    gen_partial(A , lambda : 0x7FFFFFFF , lambda : random.choice(range(2**16)))
    gen_partial(A , lambda : 0x80000000 , lambda : random.choice(range(2**16)))
    gen_partial(A , lambda : 0xFFFFFFFF , lambda : random.choice(range(2**16)))
    gen_partial(A , lambda : random.choice(range(2**32)) , lambda : random.choice(range(2**16)))
    A(check_and_exit())
r.gen(my_gen1)
