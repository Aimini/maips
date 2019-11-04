from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *

g = gen("sll_1")


def my_gen(A, au):
    A("ori $1,0x0001")
    for i in range(2, 32):
        A(f"sll ${i},$1,{i}")
    A("sll $1,$1,0")
    A("sll $1,$1,1")
    au.check_and_exit()


g.gen(my_gen)

g = gen("sll_2")


def my_gen2(A, au):
    A("ori $31,0x1001")
    for i in range(1, 32):
        A(f"sll ${i},$31,{i}")
    au.check_and_exit()


g.gen(my_gen2)
