from gen_com import *
import random

r = gen('beq')


def my_gen1(A,C,E):
    A("li $sp,0")
    A("li $gp,0")
    
    mark = 8000
    branch_seq_order =  list(range(mark))
    random.shuffle(branch_seq_order)
    branch_seq = [0 for x in range(mark)]

    start = 0
    for i in range(mark):
        next_seq = branch_seq_order[i]
        branch_seq[start] = next_seq
        start = next_seq

    # visit_mark = [0 for x in range(mark)]
    # start = 0
    # while True:
    #     if visit_mark[start] == 1:
    #         print("revisit at {}".format(start))
    #         print(branch_seq_order)
    #         print(branch_seq)
    #         break
    #     visit_mark[start] = 1
    #     start = branch_seq[start]


    for i in range(32):
        A("li ${0},{0}".format(i))

    #which branch block will jump to end
    A("beq $0,$0,mark0")
    for x in range(mark):
        A("")
        A("mark{}:".format(x))
        reg = [random.choice(range(1,32)) for x in range(3)]
        #A("addu ${0},${1},${2}".format(*reg))

        #compare random regstier ,and branch to random mark
        
        if branch_seq[x] == 0:
            A("j end")
        else:
            reg = [random.choice(range(1,32)) for x in range(2)]
            tm = branch_seq[x]
            A("beq ${0},${1},mark{2}".format(*reg,tm))
            # make sure next time ${0} == ${1} == 0
            A("li ${},1".format(reg[0]))
            A("li ${},1".format(reg[1]))
    A("end:")
    A(check_and_exit())
r.gen(my_gen1)
