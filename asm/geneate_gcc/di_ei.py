from gen_com import *
import random,math,itertools,sys


r = gen("di_ei")

def my_gen1(A,C,E):
    A("""

.set noat
.globl __start
.align 4

.section .data
    clock_count: .word 0    

.section .text
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

    li $k0, 0x00000403
    mtc0 $k0,$12 # keep exl,enable clock iinterrupt

    mtc0 $0,$11 # set compare to zero
    mtc0 $0,$9  # set count to zero
    nop         #shouldn't trigger interrupt
    nop
    nop
    nop
    nop
    nop
    nop

    li $k0, 1999
    mtc0 $k0,$11 # compare overflow each 2000 tick

    li $k0, 0x800000
    mtc0 $k0, $13 # claer cause set iv

    la   $k0, __next
    mtc0 $k0,$14 
    eret          #exit kernel mode
    
.org 0x180  #if clock interrupt triggered before 
            # exit kernel mode, it's come to here
    lui $k0, 0xFFFF
    sw  $0 , 8($k0)
    sw  $0 , 4($k0)
    li  $k1, 2
    sw  $k1 , 0($k0)

.org 0x200
    la    $k0, clock_count
    lw    $k1,0($k0)
    addi  $k1,$k1,1
    sw    $k1,0($k0)

    eret
__next:
##############################################################""")


    

    
    for x in range(1000):
        retrive_reg,rt = get_random_exclude_reg(k = 2)
        A(f"mfc0 ${retrive_reg},$12")
        using_di = get_random_below(2) > 0
        if using_di:
            A(f"di ${rt}")
        else:
            A(f"ei  ${rt}")
        A(assert_equal(retrive_reg,rt))
        A(f"mfc0 ${retrive_reg},$12")
        A("andi ${0},${0},1".format(retrive_reg))
        if using_di:
            A(assert_equal_immed(retrive_reg,0))
        else:
            A(assert_equal_immed(retrive_reg,1))


    A("la    $k0,clock_count") 
    A("lw    $k1,0($k0)")
    A(print_int("k1"))
    A(exit_using())

r.gen(my_gen1)