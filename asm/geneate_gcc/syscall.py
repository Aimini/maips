from gen_com import *
from exception_test import exception_gen
import random,math,itertools,sys



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

def gen_oprand_immed():
    for x in get_bound(32):
        for y in get_bound(16):
            yield x,y

    while(True):
        yield get_u32(),get_s16()
    
def gen_trap_rtype(op,condition):
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

def gen_trap_immedtype(op,condition):
    g = gen_oprand_immed()
    def trap_inner(A):
        a,b = next(g)
        regs = get_random_exclude_reg(k = 1)[0]
        A(set_immed(regs,a))
        A("{} ${},{}".format(op,regs,b))
        if condition(a,b):
            return 1
        return 0
    return trap_inner

def gen_add_sub(sub):
    g = gen_oprand()
    if sub:
        op = "sub"
        f = lambda a,b: a - b
    else:
        op = "add"
        f = lambda a,b: a + b
    def arithmatic_inner(A):
        a,b = next(g)
        regs = get_random_exclude_reg(k = 2)
        A(set_immed(regs[0],a))
        A(set_immed(regs[1],b))
        A("{} ${},${}".format(op,*regs))

        a = a +  ((a & 0x80000000) << 1)
        b = b +  ((b & 0x80000000) << 1)
        res = f(a,b) & 0x1FFFFFFFF

        if ((res >>32) ^(res >> 31)) & 1:
            return 1
        return 0
    return arithmatic_inner

def gen_addi():
    g = gen_oprand_immed()
    f = lambda a,b: a + b

    def arithmatic_inner(A):
        a,b = next(g)
        reg = get_random_exclude_reg(k = 1)[0]
        A(set_immed(reg,a))
        A("addi ${},{}".format(reg,b))

        b = cutto_sign16(b) & 0xFFFFFFFF
        a = a +  ((a & 0x80000000) << 1)
        b = b +  ((b & 0x80000000) << 1)
        res = f(a,b) & 0x1FFFFFFFF

        if ((res >>32) ^ (res >> 31)) & 1:
            return 1
        return 0
    return arithmatic_inner


configs = {
    "syscall":[gen_syscall,0x08],
    "break"  :[gen_break,9],
    "tge"    :[gen_trap_rtype("tge" ,lambda a,b:cutto_sign32(a) >= cutto_sign32(b)) ,13],
    "tgeu"   :[gen_trap_rtype("tgeu",lambda a,b: a >= b),13],
    "tlt"    :[gen_trap_rtype("tlt" ,lambda a,b: cutto_sign32(a) < cutto_sign32(b)) ,13],
    "tltu"   :[gen_trap_rtype("tltu",lambda a,b: a <  b) ,13],
    "teq"    :[gen_trap_rtype("teq" ,lambda a,b: a == b) ,13],
    "tne"    :[gen_trap_rtype("tne" ,lambda a,b: a != b) ,13],
    "tgei"   :[gen_trap_immedtype("tgei", lambda a,b: cutto_sign32(a) >= cutto_sign16(b)) ,13],
    "tgeiu"  :[gen_trap_immedtype("tgeiu",lambda a,b: a >= cutto_sign16(b) & 0xFFFFFFFF) ,13],
    "tlti"   :[gen_trap_immedtype("tlti", lambda a,b: cutto_sign32(a) < cutto_sign16(b)) ,13],
    "tltiu"  :[gen_trap_immedtype("tltiu",lambda a,b: a <  cutto_sign16(b) & 0xFFFFFFFF) ,13],
    "teqi"   :[gen_trap_immedtype("teqi", lambda a,b: cutto_sign32(a) == cutto_sign16(b)) ,13],
    "tnei"   :[gen_trap_immedtype("tnei", lambda a,b: cutto_sign32(a) != cutto_sign16(b)) ,13],
    "ov_add"    :[gen_add_sub(False),12],
    "ov_sub"    :[gen_add_sub(True) ,12],
    "ov_addi"    :[gen_addi() ,12],
}

test_name = sys.argv[1]
current_config = configs[test_name]
exception_gen(test_name,current_config)


