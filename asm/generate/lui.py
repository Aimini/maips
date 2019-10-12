from gen_com import *
import random

r = gen('lui_1')
def my_gen1(A,C,E):
    for x in range(32):
        i = x%16
        base = 5
        rotate = (base << i)&0xFFFF | base >> (16 - i)
        A("lui ${},0x{:0>4X}".format(x,rotate))
    C(1,6)
    E(1)
r.gen(my_gen1)

r = gen('lui_2')
def my_gen2(A,C,E):
    for i in range(1, 32):
        x = random.choice(range(2**16))
        A('lui ${0},0x{1:0>4X}'.format(i,x))
    reg = [random.choice(range(1,32)) for x in range(2)]
    C(reg[0],reg[1])
    E(reg[0])
r.gen(my_gen2)