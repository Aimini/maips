from gen_com import *
import random

r = gen('j')
###############
# add $2 n times, decided by jump time.
# at end of jump ,check $s == 2
###################
def my_gen1(A,C,E):
    A("j start")
    A(".text 0x004FFFF8")
    A("start:")
    A("ori $1,1")
    A("j mark0")
    addr = 0x00500000
    x = 0
    while addr < 0x0FFFFF00 and x < 4096:
        A("")
        A(".text 0x{:0>8X}".format(addr))
        A("mark{}:".format(x))
        A("addu $2,$2,$1")
        A("j mark{}".format(x + 1))
        addr =  (random.choice(range(addr + 4*4,0x0FFFFFFF)) >> 2) << 2
        x += 1

    A("mark{}:".format(x))
    A(assert_equal_immed(2,x))
    A(check_and_exit(ignore_gp_sp = True))
r.gen(my_gen1)


r = gen('jal')
def my_gen2(A,C,E):
    A("j start")
    A(".text 0x004FFFF8")
    A("start:")
    A("ori $1,1")
    A("j mark0")
    addr = 0x00500000
    x = 0
    while addr < 0x0FFFFF00 and x < 4096:
        A("")
        A(".text 0x{:0>8X}".format(addr))
        A("mark{}:".format(x))
        A("addu $2,$2,$1")
        A("jal mark{}".format(x + 1))
        addr = (random.choice(range(addr + 16*4,0x0FFFFFFF)) >> 2) << 2
        x += 1

    A("mark{}:".format(x))
    A(check_and_exit(ignore_gp_sp = True))
r.gen(my_gen2)

