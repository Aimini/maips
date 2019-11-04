from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random

r = gen('bgtz')

def my_gen1(A,au):
    #test negative number and zero
    for i in range(1024):
        reg = reg_list[i % 32]
        au.li(reg, -random.choice(range(0,2**31 + 1)))
        A(f"bgtz {reg},wrong")
        au.li(reg,0)
        A(f"bgtz {reg},wrong")

    au.li(reg_list[3], 1)
    A("bgtz $3, next")
    A("nop")
    #generate some meaing less code
    for i in range(32):
        au.li(reg_list[i],i)
        #shouldn't execute to there
        A("j wrong")
    
    A("next:")
    #test postive number postive
    for i in range(1024):
        reg = reg_list[i % 32]
        A(f"mark{i}:")
        au.li(reg, random.choice(range(1,2**31 + 1)))
        if reg == reg_zero:
            continue
        A(f"bgtz {reg},mark{i + 1}")
        A("nop")
        #shouldn't execute to there
        A("j  wrong")
        A(f"bgtz {reg},wrong")

    A("mark1024:")
    au.li(reg_list[31], 0x7FFFFFFF)
    A("bgtz $31,end")
    A("nop")
    A("wrong:")
    # $0 != $s0 always_fail. so...
    au.assert_not_equal(0,0)
    A("end:")
    au.check_and_exit()
r.gen(my_gen1)
