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


##
# in exception handler, we will check was exception code correct and
#  increase value in address 0x90000000.
# in text segment, we generate code do something as:
#    execute instruction than may cause exception
#    using assert function to check the value in address 0x90000000
# in python, you must provide then generate fucntion, it's genrate
# the (exception) instruction and return how many exception happend
# when these instruction executed for example:
##  def gen_syscall(A):
##     A("syscall")
##     return 1 #becuase syscall always raise exception, so it's return 1.
#   
## def gen_syscall(A):
##     A("syscall")
##     A("syscall")
##     return 2  #two times


def gen_syscall(A):
    A("syscall")
    return 1

def gen_break(A):
    A("break")
    return 1




def gen_oprand():
    for x in get_bound(32):
        for y in get_bound(32):
            yield x,y

    while(True):
        yield get_u32(),get_u32()


def gen_trap(op,condition):
    g = gen_oprand()
    def trap_inner(A):
        a,b = next(g)
        regs = get_random_exclude_reg(k = 2)
        A(set_immed(regs[0],a))
        A(set_immed(regs[1],b))
        A("{} ${},${}".format(op,*regs))
        if condition(a,b):
            return 1
        return 0
    return trap_inner


configs = {
    "syscall":[gen_syscall,0x08],
    "break"  :[gen_break,9],
    "tge"    :[gen_trap("tge" ,lambda a,b:cutto_sign32(a) >= cutto_sign32(b)) ,13],
    "tgeu"   :[gen_trap("tgeu",lambda a,b: a >= b),13],
    "tlt"    :[gen_trap("tlt" ,lambda a,b: cutto_sign32(a) < cutto_sign32(b)) ,13],
    "tltu"   :[gen_trap("tltu",lambda a,b: a <  b) ,13],
    "teq"    :[gen_trap("teq" ,lambda a,b: a == b) ,13],
    "tne"    :[gen_trap("tne" ,lambda a,b: a != b) ,13]
}

test_name = sys.argv[1]
current_config = configs[test_name]
r = gen(test_name)

def my_gen1(A,C,E):
    f = current_config[0]
    exccode = current_config[1]
    
    A("""
.set noat
.globl __start
.text
.align 4

__start:
    li $gp,_gp
    li $sp,0x90040000

    li $k0,_bss_start
    li $k1,_bss_end
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

    mfc0  $k0,$14
    addiu $k0,$k0,4
    mtc0  $k0,$14
    eret
##############################################################""".format(exccode = exccode))

    

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