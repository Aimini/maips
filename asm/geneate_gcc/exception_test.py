

from gen_com import *
import random,math,itertools,sys



######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

def random_get_alu():
    reg = get_random_exclude_reg(k = 3)
    triple_arg = f"${reg[0]},${reg[1]},${reg[2]}"
    double_arg = f"${reg[0]},${reg[1]}"
    single_arg = f"${reg[0]}"
    statement = [f"addu {triple_arg}",
    f"subu  {triple_arg}",
    f"and   {triple_arg}",
    f"or    {triple_arg}",
    f"xor   {triple_arg}",
    f"nor   {triple_arg}",
    f"slt   {triple_arg}",
    f"sltu  {triple_arg}",
    f"mult  {double_arg}",
    f"multu {double_arg}",
    f"mfhi  {single_arg}",
    f"mthi {single_arg}",
    f"mflo {single_arg}",
    f"mtlo {single_arg}"]
    return random.choice(statement)

def exception_gen(test_name,current_config):
    r = gen(test_name)

    def my_gen1(A,C,E):
        f = current_config[0]
        exccode = current_config[1]
        insert_exception_code = ""
        
        if len(current_config) > 2:
            insert_exception_code = current_config[2]
        A("""
    .set noat
    .globl __start
    .text
    .align 4

    __start:
        lui $gp,_gp_hi
        ori $gp,_gp_lo
        li $sp,0x90040000

        lui $k0,_bss_start_hi
        ori $k0,_bss_start_lo
        lui $k1,_bss_end_hi
        ori $k1,_bss_end_lo
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
            inc = f(A)
            A( "la     $a0, exception_count")
            A( "lw     $a1, 0($a0)")
            A(f"addiu  $a1, $a1,{inc}")
            A( "sw     $a1, 0($a0)")
            return inc

        for x in range(5000):
            total += make_exception_count()
            A(assert_equal_immed("a1",total))


        for x in range(1000):
            for x in range(get_random_below(20)):
                A(random_get_alu())
            total += make_exception_count()
            A(assert_equal_immed("a1",total))

        A(exit_using())
        A(".data")
        A("exception_count: .word 0")

    r.gen(my_gen1)