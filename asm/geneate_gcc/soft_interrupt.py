from gen_com import *
from exception_test import exception_gen
import random,math,itertools,sys


unalign_pc_exception_handler = """
    mfc0 $k1,$13   
    ext  $k0, $k1, 8 ,2
    ins  $k1,$0,8,2   # 
    mtc0 $k1,$13,0    # clear cause IP1 IP0

    srl  $k0, $k0 ,8
    andi $k0, $k0 ,3  #keep IP1 IP0
    blez $k0, __have_problem # IP is gone ???
    andi $k1  $k0 , 1
    blez $k1, __check_ip1 # ip0 not assert, check ip1
    mfc0 $k1, $12         #load status 
    andi $k1, $k1, 0x101  # check im0 and ie
    lui $k0,0xffff
    sw  $k1 ,8($k0)
    li  $k1 ,0x101
    sw  $k1, 4($k0)
    li  $k1, 1
    sw  $k1, 0($k0)
    b    ___problem_check_end

__check_ip1:
    srl  $k1  $k0 , 1
    blez $k1, __have_problem
    mfc0 $k1, $12          #load status 
    andi $k1, $k1, 0x201   # check im1 and ie
    lui $k0 ,0xffff
    sw  $k1 ,8($k0)
    li  $k1 ,0x201
    sw  $k1, 4($k0)
    li  $k1, 1
    sw  $k1, 0($k0)
    b    ___problem_check_end

__have_problem:
    lui $k0,0xffff
    sw  $0 ,4($k0)
    sw  $0 ,8($k0)
    li  $k1, 2
    sw  $0, 0($k0) #tell system meet problem
___problem_check_end:
"""
def soft_interrupt_gen(A):
    reg = get_random_exclude_reg(k = 1)[0]
    ie =  1 if get_random_below(10) else 0
    im0 = 1 if  get_random_below(4) else 0
    im1 = 1 if  get_random_below(4) else 0
    im = im1*2 + im0;

    A(
        f"""
        mfc0 $k1,$12,0    
        li   $k0,{im}
        ins  $k1,$k0,8,2   # 
        li   $k0,{ie}
        ins  $k1,$k0,0,1   # 
        mtc0 $k1,$12,0    # clear cause IP1 IP0
    """)
    set_int0 = get_random_below(2) > 0
    if set_int0:
        #IP0
        A(f"li ${reg},0x100")
    else:
        #IP1
        A(f"li ${reg},0x200")
    A("mtc0 $k1,$13")
    if ie:
        if set_int0 and im0 or (not set_int0 and im1):
            return 1
    return 0

test_name = "soft_interrupt"
current_config = [soft_interrupt_gen, 0]
exception_gen(test_name,current_config)


