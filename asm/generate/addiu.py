from gen_com import *
import random
g = gen("addiu")
def my_gen(A,C,E):
    # postive
    A("lui $gp,0")
    A("lui $sp,0")
    for i in range(32):
        A("li ${0},0x{1:0>8X}".format(i,random.choice(range(2**32))));
    A("addi $1,$0,{}".format(-2**15))
    for i in range(0,2048):
        #add immed in postive
        va = random.choice(range(0,2**15))
        reg = [random.choice(range(0,32)) for x in range(2)]
        A("addiu ${0},${1},0x{2:0>4X}".format(*reg,va));

        #add immed in negative
        va = random.choice(range(0,2**15 + 1))
        reg = [random.choice(range(0,32)) for x in range(2)]
        A("addiu ${0},${1},-0x{2:0>4X}".format(*reg,va));

    A(check_and_exit(ignore_gp_sp = False))

    # negtive
g.gen(my_gen)
