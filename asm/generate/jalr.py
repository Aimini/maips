from gen_com import *
import random,math,itertools

r = gen('jalr')

######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

        


def my_gen1(A,C,E):
    N = 2**14
    for x in range(32):
        A(f"li ${x},0")
    
    A(f"li $sp,0x10110000")
    pc_save_reg = 0
    for x in range(N):
        A(f"mark{x}: ")
        
        A(f"addi $sp,$sp,-4")
        A(f"sw   ${pc_save_reg},0($sp)")
        r16 = get_s16()

        reg = get_random_exclude_reg(k = 2,exclude = [29])
        A(f"addi ${reg[0]}, ${reg[1]}, {r16}")
        
        temp_pc_save_reg = pc_save_reg
        if x != N - 1:
            pc_save_reg, pc_target_reg = get_random_exclude_reg(k = 2,exclude = [0,29])
            A(f"la   ${pc_target_reg},mark{x + 1}")
            A(f"jalr ${pc_save_reg},${pc_target_reg}")
        reg = get_random_exclude_reg(k = 2,exclude = [29])
        r16 = random.choice(range(2**16))
        A(f"ori ${reg[0]}, ${reg[1]}, {r16}")
        A(f"lw   ${temp_pc_save_reg},0($sp)")
        A(f"addi $sp,$sp,4")
        if x == 0:
            A("j final")
        else:
            A(f"jr ${temp_pc_save_reg}")
        A(f"j   wrong")
        A(f"j   wrong")
        A("")
        A("")


    A("wrong:")
    A(assert_not_equal(0,0))
    A("final:")
    A(check_and_exit())
r.gen(my_gen1)