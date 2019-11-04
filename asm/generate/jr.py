from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random,math,itertools

r = gen('jr')

######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

        


def my_gen1(A,au):
    N = 2**13
    au.clear_reg()
    A(f"li $sp,0x10110000")
    for x in range(N):
        A(f"mark{x}: ")
        r16 = numutil.s16()
        reg = regutil.get_random(k = 2,exclude = [reg_sp,reg_ra])
        A(f"addi {reg[0]}, {reg[1]}, {r16}")
        A(f"addi $sp,$sp,-4")
        A(f"sw   $ra,0($sp)")
        if x != N - 1:
            A(f"jal mark{x + 1}")
            A(f"nop")
        reg = regutil.get_random(k = 2,exclude = [reg_sp,reg_ra])
        r16 = numutil.u16()
        A(f"ori {reg[0]}, {reg[1]}, {r16}") # delay slot
        A(f"jal group_2_{x}")
        A(f"nop")

        A(f"lw   $ra,0($sp)")
        A(f"addi $sp,$sp,4")
        if x == 0:
            A("j final")
            A(f"nop")
        else:
            A(f"jr $31")
            A(f"nop")

        A(f"j   wrong")
        A(f"j   wrong")
        A("")
        A("")

    for x in range(N):
        A(f"group_2_{x}: ")
        A(f"jr $31")
        A(f"nop")
        A(f"j   wrong")
        A(f"j   wrong")
        A("")
        A("")


    A("wrong:")
    au.assert_not_equal(0,0)
    A("final:")
    au.check_and_exit()
r.gen(my_gen1)