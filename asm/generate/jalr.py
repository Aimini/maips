from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *
import random
import math
import itertools



def my_gen1(A, au):
    N = 2**13
    au.clear_reg()

    A(f"li $sp,0x10110000")
    pc_save_reg = reg_zero
    for x in range(N):
        A(f"mark{x}: ")

        A(f"addi $sp,$sp,-4")
        A(f"sw   {pc_save_reg},0($sp)")
        r16 = numutil.s16()

        reg = regutil.get_random(k=2, exclude=[reg_sp])
        A(f"addi {reg[0]}, {reg[1]}, {r16}")

        temp_pc_save_reg = pc_save_reg
        if x != N - 1:
            pc_save_reg, pc_target_reg = regutil.get_random(k=2, exclude=[reg_sp])
            A(f"la   {pc_target_reg},mark{x + 1}")
            A(f"jalr {pc_save_reg},{pc_target_reg}")
            A("nop")
        reg = regutil.get_random(k=2, exclude=[reg_sp])
        r16 = numutil.u16()
        A(f"ori  {reg[0]}, {reg[1]}, {r16}")
        A(f"lw   {temp_pc_save_reg},0($sp)")
        A(f"addi $sp,$sp,4")
        if x == 0:
            A("j final")
            A("nop")
        else:
            A(f"jr {temp_pc_save_reg}")
            A("nop")
        A(f"j   wrong")
        A(f"j   wrong")
        A("")
        A("")

    A("wrong:")
    au.assert_not_equal(0, 0)
    A("final:")
    au.check_and_exit()
    return ["mars","-s"]

r = gen('jalr')
r.gen(my_gen1)
