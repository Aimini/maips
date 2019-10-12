from gen_com import *
import random
g = gen("addu")
def my_gen(A,C,E):
    for i in range(0,4096):
        va = random.choice(range(0,2**32))
        reg = [random.choice(range(0,32)) for x in range(3)]
        A("li   ${0},0x{1:0>8X}".format(reg[2],va));
        A("addu ${0},${1},${2}".format(*reg));
    reg = [random.choice(range(1,32)) for x in range(2)]
    C(reg[0],reg[1])
    E(reg[0])

g.gen(my_gen)
