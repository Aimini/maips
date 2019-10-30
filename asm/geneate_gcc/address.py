from gen_com import *
from exception_test import exception_gen
import random,math,itertools,sys


def gen_oprand():
    for x in get_bound(32):
        for y in get_bound(32):
            yield x,y

    while(True):
        yield get_u32(),get_u32()

def gen_oprand_immed():
    for x in get_bound(32):
        for y in get_bound(16):
            yield x,y

    while(True):
        yield get_u32(),get_s16()
    

count_limit = 2**22 # 4MB
data_segment_base = 0x90000000
byte_per_unit = 1
def convert_adddress(count):
        return data_segment_base + count

def get_random_offset(conut):
    addr = convert_adddress(conut)
    offset = get_s16()
    return addr - offset, offset

def gen_unalign_addr_load(A):
    base,offset = get_random_offset(get_random_below(count_limit))
    addr = base + offset

    regs = get_random_exclude_reg(k = 4);
    #1. store a value to target word aligned address
    value = get_random_below(2**32)
    A(set_immed(regs[0],value))
    
    align_addr = (addr >> 2) << 2
    A(set_immed(regs[1],align_addr))
    A(f"sw ${regs[0]},0(${regs[1]})")

    #2. load value for (unaligned) address
    base_reg = regs[3]
    A(set_immed(base_reg,base))
    A(f"lh  ${regs[0]},{offset}(${base_reg})")
    A(set_immed(base_reg,base))
    A(f"lhu ${regs[1]},{offset}(${base_reg})")
    A(set_immed(base_reg,base))
    A(f"lw  ${regs[2]},{offset}(${base_reg})")

    c = 0
    if addr & 0x1: # unalign half word
        c += 2
    if (addr & 0x1) or ((addr >> 1)& 0x1)  : # unalign word
        c += 1
    return c

def gen_unalign_addr_store(A):
    base,offset = get_random_offset(get_random_below(count_limit))
    addr = base + offset

    regs = get_random_exclude_reg(k = 4);

    base_reg = regs[3]
    A(set_immed(base_reg,base))

    value = get_random_below(2**32)
    A(set_immed(regs[0],value))
    A(set_immed(regs[1],value))
    A(set_immed(regs[2],value))

    A(f"sh ${regs[0]},{offset}(${base_reg})")
    A(set_immed(base_reg,base))
    A(f"sw ${regs[2]},{offset}(${base_reg})")

    c = 0
    if addr & 0x1: # unalign half word
        c += 1
    if (addr & 0x1) or ((addr >> 1)& 0x1)  : # unalign word
        c += 1
    return c

def gen_unalign_pc(A):
    base,offset = get_random_offset(get_random_below(count_limit))
    addr = base + offset
    if (addr & 1) or ((addr >> 1)&1):
        reg = get_random_exclude_reg(k = 1,exclude =["ra"])[0]
        A(set_immed(reg,addr))
        A(f"jalr  ${reg}")
        return 1
    return 0

unalign_pc_exception_handler = """
    mfc0 $k1,$12,0    # get status
    ins  $k1,$0,1,1  # set exl to zero
    mtc0 $k1,$12,0    # get status
    addiu $ra,$ra,-4  # exception from pc + 8, now set $ra to pc + 4
    jr $ra
"""
configs = {
    "unalign_load"  :[gen_unalign_addr_load, 4],
    "unalign_store" :[gen_unalign_addr_store,5],
    "unalign_pc"    :[gen_unalign_pc,        4, unalign_pc_exception_handler]
}


test_name = sys.argv[1]
current_config = configs[test_name]
exception_gen(test_name,current_config)


