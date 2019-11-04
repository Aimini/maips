

from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random,math,itertools,sys



######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:



def exception_gen(test_name,current_config):
    r = gen(test_name)

    def my_gen1(A,au):
        f = current_config[0]
        exccode = current_config[1]
        insert_exception_code = ""
        
        if len(current_config) > 2:
            insert_exception_code = current_config[2]
        A("""
    .set noat
    .globl __start
    .text

    __start:
        la   $gp,_gp
        lui  $sp,0x9004

        la $k0,_bss_start
        la  $k1,_bss_end
    initial_bss:
        beq     $k1,  $k0, initial_bss_end
        sw      $0 ,0($k0)
        addiu   $k0,  $k0, 4
        b       initial_bss
    initial_bss_end:
        mtc0 $0,$12 # set StatusBEV to zero(all to zero XD )
        b __next
    ###################   exception handler   ###################
    .org 0x180
        la     $k0, exception_count
        lw     $k1, 0($k0)
        addiu  $k1, $k1,1
        sw     $k1, 0($k0)

        mfc0 $k0,$13,0    # get cause
        ext  $k0,$k0,2,5  # get exc code

        lui $k1, 0xffff
        sw  $k0, 8($k1)
        lui $k0, 0x0000 # check causeExcCode
        ori $k0, 0x{exccode:4>0X}
        sw  $k0, 4($k1)
        lui $k0, 0x0000 # li $k1, 00000001
        ori $k0, 0x0001
        sw  $k0, 0($k1) 

        mfc0 $k0,$12,0    # get status
        ext  $k0,$k0,1,1  # get exl

        lui $k1, 0xffff
        sw  $k0, 4($k1)
        lui $k0, 0x0000 # check statusEXL
        ori $k0, 0x1
        sw  $k0, 8($k1)
        lui $k0, 0x0000 # li $24, 00000001
        ori $k0, 0x0001
        sw  $k0, 0($k1) 
        
        {insert_exception_code}

        mfc0  $k0,$14
        addiu $k0,$k0,4
        mtc0  $k0,$14
        eret
    ##############################################################""".format(exccode = exccode,insert_exception_code = insert_exception_code))

        

        total = 0
        A("__next:")
        A("la $a0, exception_count")
        A("sw $0, 0($a0)")

        def make_exception_count():
            inc = f(A,au)
            return inc

        for x in range(2000):
            total += make_exception_count()
            A("""
            la  $a0, exception_count
            lw  $a0, 0($a0)
            """)
            au.assert_equal(reg_a0,total)


        for x in range(1000):
            for x in range(numutil.below(20)):
                A(get_random_alu())
            total += make_exception_count()
            A("""
            la  $a0, exception_count
            lw  $a0, 0($a0)
            """)
            au.assert_equal(reg_a0,total)


        au.exit()
        A(".data")
        A(".align 4")
        A("exception_count: .word 0")
        return ['kernel']

    r.gen(my_gen1)