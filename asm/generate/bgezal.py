from gen_com import *
import random

r = gen('bgezal')

def my_gen1(A,C,E):
    N = 1400
    #test postive number and zero
    A("j start")
    A("wrong:")
    A("sw $0,0x10010000")
    # $0 != $s0 always_fail. so...
    A(assert_not_equal(0,0))
    A("j end")
    A("start:")
    A("li $sp,0x10110000")
    A("sw $0, 0x10010000")
    for i in range(N):
        reg =   get_random_exclude_reg(k = 1,exclude = [29])[0];
        A("li ${},{}".format(reg, random.choice(range(2**31,2**32))))
        A("bgezal ${},wrong".format(reg))
        A("lw $2,0x10010000")
        A("addiu $2,$2,1")
        A("sw $2,0x10010000")
        
    A("li ${},0x80000001".format(reg))
    A("bgezal ${},wrong".format(reg))
    A("li $3, 0x80000000")
    A("bgezal $3, wrong")
    A("li $3, 0x7FFFFFFF")
    A("bgezal $3, next")
    #generate some meaing less code
    for i in range(32):
        A("li ${0},{0}".format(i))
        #shouldn't execute to there
        A("j wrong")
    
    A("next:")
    #test negative number postive
    for i in range(N):
        reg =   get_random_exclude_reg(k = 1,exclude = [29])[0];
        A("mark{}:".format(i))
        A("addiu $sp,$sp, -4")
        A("sw $ra, 0($sp)")
        A("li ${},{}".format(reg,random.choice(range(0,2**31)) ))
        if i != N - 1:
            A("bgezal ${},mark{}".format(reg,i + 1))
        A("lw $ra, 0($sp)")
        A("addiu $sp,$sp, 4")

        A("lw $2,0x10010000")
        A("addiu $2,$2,1")
        A("sw $2,0x10010000")
        if i == 0:
            A(f"j mark{N}")
        else:
            A("jr $ra")
        A("bgezal ${},wrong".format(reg))
        A("j  wrong")

    A(f"mark{N}:")
    A("li $31, 0")
    A("bgezal $31,end")
    A("j wrong")
    A("end:")
    A("lw $2,0x10010000")
    A(assert_equal_immed(2,2*N))
    A(check_and_exit())
r.gen(my_gen1)
