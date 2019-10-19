from gen_com import *
import random,math,itertools

r = gen('jr')

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
    for x in range(N):
        A(f"mark{x}: ")
        r16 = get_s16()
        reg = get_random_exclude_reg(k = 2,exclude = [29,31])
        A(f"addi ${reg[0]}, ${reg[1]}, {r16}")
        
        A(f"addi $sp,$sp,-4")
        A(f"sw   $ra,0($sp)")
        if x != N - 1:
            A(f"jal mark{x + 1}")
        reg = get_random_exclude_reg(k = 2,exclude = [29,31])
        r16 = random.choice(range(2**16))
        A(f"ori ${reg[0]}, ${reg[1]}, {r16}")
        A(f"jal group_2_{x}")
        A(f"lw   $ra,0($sp)")
        A(f"addi $sp,$sp,4")
        if x == 0:
            A("j final")
        else:
            A(f"jr $31")
        A(f"j   wrong")
        A(f"j   wrong")
        A("")
        A("")

    for x in range(N):
        A(f"group_2_{x}: ")
        A(f"jr $31")
        A(f"j   wrong")
        A(f"j   wrong")
        A("")
        A("")


    A("wrong:")
    A(assert_not_equal(0,0))
    A("final:")
    A(check_and_exit())
r.gen(my_gen1)