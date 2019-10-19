from gen_com import *
import random
g = gen("subu")
def my_gen(A,C,E):
    b = get_bound(32)
    for x in range(128):
        for i in b:
            reg = get_random_exclued_reg(k = 3)
            A("li   ${0},0x{1:0>8X}".format(reg[2],i));
            A("subu ${0},${1},${2}".format(*reg));

    
    for i in range(0,10000):
        va = get_u32()
        reg = get_random_exclued_reg(k = 3)
        A("li   ${0},0x{1:0>8X}".format(reg[2],va));
        A("subu ${0},${1},${2}".format(*reg));
    A(check_and_exit())

g.gen(my_gen)
