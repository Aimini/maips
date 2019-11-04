from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *
import random

r = gen('bne')


def my_gen1(A, au):
    mark = 4000

    #inital to all zero
    au.clear_reg()

    branch_seq = numutil.jl(mark)
    start = branch_seq[0]
    #which branch block will jump to end
    for x in range(mark):
        A("")
        A("mark{}:".format(x))
        regutil.get_random(k=3)
        #A("addu {0},{1},{2}".format(*reg))

        #compare random regstier ,and branch to random mark
        if branch_seq[x] == start:
            A("j end")
            A("nop")
        else:
            # make sure there nobody compare to itself
            reg = regutil.get_random(k=2)
            tm = branch_seq[x]
            A("bne {0},{1},mark{2}".format(*reg, tm))
            A("nop")
            # make sure next time {0} != {1}
            au.li(reg[0], 1 << reg[0].order)
            au.li(reg[1], 1 << reg[1].order)
    A("end:")
    au.check_and_exit()


r.gen(my_gen1)
