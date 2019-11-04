from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random

r = gen('bltzal')

def my_gen1(A,au):
    N = 1300
    #test postive number and zero

    au.li(reg_sp,0x10110000)
    A("sw $0, 0x10010000")
    for i in range(N):
        reg =   regutil.get_one(exclude = [reg_sp])
        au.li(reg, random.choice(range(1,2**31)))
        A("bltzal {},wrong".format(reg))
        A("lw $2,0x10010000")
        A("addiu $2,$2,1")
        A("sw $2,0x10010000")
        
    au.li(reg,0)
    A("bltzal {},wrong".format(reg))
    au.li(reg_list[3], 0x7FFFFFFF)
    A("bltzal $3, wrong")
    au.li(reg_list[3], 0x80000000)
    A("bltzal $3, next")
    A("nop")
    #generate some meaing less code
    for i in range(32):
        au.li(reg_list[i],i)
        #shouldn't execute to there
        A("j wrong")
    
    A("next:")
    #test negative number postive
    for i in range(N):
        reg =   regutil.get_one(exclude = [reg_sp])
        A(f"mark{i}:")
        A("addiu $sp,$sp, -4")
        A("sw $ra, 0($sp)")
        au.li(reg, random.choice(range(2**31,2**32)))
        if i != N - 1:
            A(f"bltzal {reg},mark{i + 1}")
            A("nop")
        A("lw $ra, 0($sp)")
        A("addiu $sp,$sp, 4")

        A("lw $2,0x10010000")
        A("addiu $2,$2,1")
        A("sw $2,0x10010000")
        if i == 0:
            A(f"j mark{N}")
            A("nop")
        else:
            A("jr $ra")
            A("nop")
        A(f"bltzal {reg},wrong")
        A("j  wrong")

    A(f"mark{N}:")
    au.li(reg_list[31], 0xFFFFFFFF)
    A("bltzal $31,end")
    A("nop")
    
    A("wrong:")
    A("sw $0,0x10010000")
    au.assert_not_equal(0,0)  # $0 != $s0 always_fail. so...

    A("end:")
    A("lw $2,0x10010000")
    au.assert_equal(reg_list[2],2*N)
    au.check_and_exit()
    return ["mars","-s"]
r.gen(my_gen1)
