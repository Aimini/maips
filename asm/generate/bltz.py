from gen_com import *
import random

r = gen('bltz')

def my_gen1(A,C,E):
    N = 2560
    #test postive number and zero
    for i in range(N):
        reg = i % 32;
        A("li ${},{}".format(reg, random.choice(range(0,2**31))))
        A("bltz ${},wrong".format(reg))

    A("li ${},0".format(reg))
    A("bltz ${},wrong".format(reg))
    A("li $3, 0x7FFFFFFF")
    A("bltz $3, wrong")
    A("li $3, 0x80000000")
    A("bltz $3, next")
    #generate some meaing less code
    for i in range(32):
        A("li ${0},{0}".format(i))
        #shouldn't execute to there
        A("j wrong")
    
    A("next:")
    #test negative number postive
    for i in range(N):
        reg = i % 32;
        A("mark{}:".format(i))
        A("li ${},{}".format(reg, random.choice(range(2**31,2**32))))
        if reg == 0:
            continue
        A("bltz ${},mark{}".format(reg,i + 1))
        #shouldn't execute to there
        A("bltz ${},wrong".format(reg))
        A("j  wrong")

    A(f"mark{N}:")
    A("li $31, 0xFFFFFFFF")
    A("bltz $31,end")
    A("wrong:")
    # $0 != $s0 always_fail. so...
    A(assert_not_equal(0,0))
    A("end:")
    A(check_and_exit())
r.gen(my_gen1)
