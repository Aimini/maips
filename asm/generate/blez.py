from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *
import random

r = gen('blez')


def my_gen1(A, au):
    #test postive number postive
    for i in range(1024):
        reg = reg_list[i % 32]
        if reg == reg_zero:
            continue
        au.li(reg, random.choice(range(1, 2**31)))
        A(f"blez {reg},wrong")

    A("blez $0,next")
    A("nop")
    #generate some meaing less code
    for i in range(32):
        au.li(reg_list[i], i)
        #shouldn't execute to there
        A("blez $0, wrong")

    A("next:")
    #test negative number postive
    for i in range(1024):
        reg = reg_list[i % 32]
        A(f"mark{i}:")
        au.li(reg, -random.choice(range(0, 2**31 + 1)))
        A(f"blez {reg},mark{i + 1}")
        A("nop")
        #shouldn't execute to there
        A(f"blez {reg},wrong")
        A(f"blez {reg},wrong")

    A("mark1024:")
    A("blez $0,end")
    A("nop")

    A("wrong:")
    au.assert_not_equal(0, 0)  # $0 != $s0 always_fail. so...

    A("end:")
    au.check_and_exit()


r.gen(my_gen1)
