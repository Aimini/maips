from gen_com import *
import random

r = gen('blez')


def my_gen1(A,C,E):
    #test postive number postive
    for i in range(1024):
        reg = i % 32;
        if reg == 0:
            continue
        A("li ${0},{1}".format(reg, random.choice(range(1,2**31))))
        A("blez ${},wrong".format(reg))

    A("blez $0,next")
    #generate some meaing less code
    for i in range(32):
        A("li ${0},{0}".format(i))
        #shouldn't execute to there
        A("blez $0, wrong")
    
    A("next:")
    #test negative number postive
    for i in range(1024):
        reg = i % 32;
        A("mark{}:".format(i))
        A("li ${},{}".format(reg, -random.choice(range(0,2**31 + 1))))
        A("blez ${},mark{}".format(reg,i + 1))
        #shouldn't execute to there
        A("blez ${},wrong".format(reg))
        A("blez ${},wrong".format(reg))
    A("mark1024:")
    A("blez $0,end")
    A("wrong:")
    # $0 != $s0 always_fail. so...
    A(assert_not_equal(0,0))
    A("end:")
    A(check_and_exit())
r.gen(my_gen1)
