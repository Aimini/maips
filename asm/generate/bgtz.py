from gen_com import *
import random

r = gen('bgtz')

def my_gen1(A,C,E):
    #test negative number and zero
    for i in range(1024):
        reg = i % 32;
        A("li ${0},{1}".format(reg, -random.choice(range(0,2**31 + 1))))
        A("bgtz ${},wrong".format(reg))
        A("li ${0},0".format(reg))
        A("bgtz ${},wrong".format(reg))

    A("li $3, 1")
    A("bgtz $3, next")
    #generate some meaing less code
    for i in range(32):
        A("li ${0},{0}".format(i))
        #shouldn't execute to there
        A("j wrong")
    
    A("next:")
    #test postive number postive
    for i in range(1024):
        reg = i % 32;
        A("mark{}:".format(i))
        A("li ${},{}".format(reg, random.choice(range(1,2**31 + 1))))
        if reg == 0:
            continue
        A("bgtz ${},mark{}".format(reg,i + 1))
        #shouldn't execute to there
        A("j  wrong")
        A("bgtz ${},wrong".format(reg))

    A("mark1024:")
    A("li $31, 0x7FFFFFFF")
    A("bgtz $31,end")
    A("wrong:")
    # $0 != $s0 always_fail. so...
    A(assert_not_equal(0,0))
    A("end:")
    A(check_and_exit())
r.gen(my_gen1)
