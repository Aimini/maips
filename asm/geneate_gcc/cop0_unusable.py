from gen_com import *
import random,math,itertools,sys


def gen_reserved(A):
    cop0 = [
        "ERET",
        "MTC0 $0,$12,0",
        "MFC0 $0,$12,0"
    ]
    
    A("li   $k0,0x10")   
    A("mtc0 $k0,$12,0")  # enter user mode
    if get_random_below(1):
        A(random.choice(cop0))
        return 1
    else:
        A(random_get_alu())
        return 0
    



test_name = "cop0_unusable"
exccode = 11
r = gen(test_name)

def my_gen1(A,C,E):
    f = gen_reserved
    
    A("""

.set noat
.globl __start
.align 4

.section .kdata ,"aw", @progbits
    

.section .ktext ,"ax", @progbits
__start:
    la $gp,_gp
    li $sp,0x90040000

    la  $k0,_bss_start
    la  $k1,_bss_end
initial_bss:
    beq     $k1,  $k0, initial_bss_end
    sw      $0 ,0($k0)
    addiu   $k0,  $k0, 4
    b       initial_bss
initial_bss_end:
    mtc0 $0, $12 # set StatusBEV to zero(all to zero XD )

    la $k0,__user_start # set eret
    jr $k0


###################   exception handler   ###################
.org 0x180
    la     $k0, exception_counters
    lw     $k1, 0($k0)
    addiu  $k1, $k1, 1
    sw     $k1, 0($k0)
        
    mfc0 $k0,$13,0    # get cause
    ext  $k0,$k0,2,5  # get exc code

    mfc0 $k1,$12,0    # get status
    ext  $k1,$k1,1,1  # get exl
    lui $24,   0x0000 # check causeExcCode
    ori $24,   0x{exccode:4>0X}
    lui $2,    0xffff
    sw  $24,   4($2)
    sw  $k0,   8($2)
    lui $24,   0x0000 # li $24, 00000001
    ori $24,   0x0001
    sw  $24, 0($2) 

    lui $24,   0x0000 # check statusEXL
    ori $24,   0x1
    lui $2,    0xffff
    sw  $24,   4($2)
    sw  $k1,   8($2)
    lui $24,   0x0000 # li $24, 00000001
    ori $24,   0x0001
    sw  $24, 0($2) 

    mfc0  $k0,$14    #set eret
    addiu $k0,$k0,4
    mtc0  $k0,$14
    li   $k1, 0x02
    mtc0 $k1,$12,0   #clear user mode and set exl
    eret
##############################################################""".format(exccode = exccode))

    

    total = 0
    A(
"""
.data
  exception_count: .word 0
.text
     __user_start:
    la $a0, exception_count
    sw $0, 0($a0)
    """)

    def make_exception_count():
        inc = f(A)
        return inc

    for x in range(1000):
        total += make_exception_count()
        A( "la     $a1, exception_count")
        A( "lw     $a1, 0($a1)")
        A(assert_equal_immed("a1",total))


    for x in range(1000):
        for x in range(get_random_below(20)):
            A(random_get_alu())
        total += make_exception_count()

        A( "la     $a1, exception_count")
        A( "lw     $a1, 0($a1)")
        A(assert_equal_immed("a1",total))

    A(exit_using())
    return 'tool\\mix_compile.py'

r.gen(my_gen1)