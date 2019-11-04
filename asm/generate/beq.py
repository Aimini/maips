from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random

r = gen('beq')


def my_gen1(A,au):
    mark = 5000
   

    for i in range(32):
        au.li(reg_list[i],i)

    #which branch block will jump to end
    branch_seq = numutil.jl(mark)
    start = branch_seq[0]
    A(f"beq $0,$0,mark{start}")
    A("nop")
    for x in range(mark):
        A(f"mark{x}:")
        reg = regutil.get_random(k = 3)
        #compare random regstier ,and branch to random mark
        if branch_seq[x] == start:
            A("j end")
            A("nop")
        else:
            reg = regutil.get_random(k = 2)
            tm = branch_seq[x]
            A("beq {0},{1},mark{2}".format(*reg,tm))
            A("nop")
            # make sure next time {0} == {1} == 0
            au.li(reg[0],1)
            au.li(reg[1],1)
    A("end:")
    au.check_and_exit()
r.gen(my_gen1)
