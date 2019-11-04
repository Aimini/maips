from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random

r = gen('bgez')

def my_gen1(A,au):
    N = 2560
    #test postive number and zero
    for i in range(N):
        reg = reg_list[i % 32]
        if reg == reg_zero:
            continue
        au.li(reg, random.choice(range(2**31,2**32)))
        A("bgez {},wrong".format(reg))

    au.li(reg_list[3], 0x80000000)
    A("bgez $3, wrong")
    au.li(reg_list[3], 0x7FFFFFFF)
    A("bgez $3, next")
    A("nop")
    #generate some meaing less code
    for i in range(32):
        au.li(reg_list[i],i)
        #shouldn't execute to there
        A("j wrong")
    
    A("next:")
    #test negative number postive
    for i in range(N):
        reg = reg_list[i % 32]
        A(f"mark{i}:")
        au.li(reg, random.choice(range(0,2**31)))
        A(f"bgez {reg},mark{i + 1}")
        A("nop")
        #shouldn't execute to there
        A(f"bgez {reg},wrong")
        A("j  wrong")

    A(f"mark{N}:")
    au.li(reg_ra,0)
    A("bgez $31,end")
    A("nop")
    A("wrong:")
    # $0 != $s0 always_fail. so...
    au.assert_not_equal(0,0)
    A("end:")
    au.check_and_exit()
r.gen(my_gen1)
