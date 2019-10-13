from gen_com import *
import random

r = gen('bne')


def my_gen1(A,C,E):
    A("li $sp,0")
    A("li $gp,0")
    
    mark = 4000
    branch_seq_order =  list(range(mark))
    random.shuffle(branch_seq_order)
    branch_seq = [0 for x in range(mark)]

    start = 0
    for i in range(mark):
        next_seq = branch_seq_order[i]
        branch_seq[start] = next_seq
        start = next_seq

    #inital to all zero
    for i in range(32):
        A("li ${0},0".format(0))

    #which branch block will jump to end
    for x in range(mark):
        A("")
        A("mark{}:".format(x))
        reg = [random.choice(range(1,32)) for x in range(3)]
        #A("addu ${0},${1},${2}".format(*reg))

        #compare random regstier ,and branch to random mark
        
        if branch_seq[x] == 0:
            A("j end")
        else:
            # make sure there nobody compare to itself
            reg = random.sample(range(1,32),k = 2) 
            tm = branch_seq[x]
            A("bne ${0},${1},mark{2}".format(*reg,tm))
            # make sure next time ${0} != ${1}
            A("li ${0},0x{1:0>8X}".format(reg[0],1 << reg[0]))
            A("li ${0},0x{1:0>8X}".format(reg[1],1 << reg[1]))
    A("end:")
    A(check_and_exit())
r.gen(my_gen1)
