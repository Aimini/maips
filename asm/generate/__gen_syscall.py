from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *
from __exception_test import exception_gen
import random
import math
import itertools
import sys


def gen_oprand():
    for x in numutil.bound(32):
        for y in numutil.bound(32):
            yield x, y

    while(True):
        yield numutil.u32(), numutil.u32()


def gen_oprand_immed():
    for x in numutil.bound(32):
        for y in numutil.bound(16):
            yield x, y

    while(True):
        yield numutil.u32(), numutil.s16()


def gen_syscall(A, au):
    A("syscall")
    return 1


def gen_break(A, au):
    A("break")
    return 1


def gen_trap_rtype(op, condition):
    g = gen_oprand()

    def trap_inner(A, au):
        a, b = next(g)
        regs = regutil.get_random(k=2)
        au.li(regs[0], a)
        au.li(regs[1], b)
        A("{} {},{}".format(op, *regs))
        if condition(a, b):
            return 1
        return 0
    return trap_inner


def gen_trap_immedtype(op, condition):
    g = gen_oprand_immed()

    def trap_inner(A, au):
        a, b = next(g)
        regs = regutil.get_one()
        au.li(regs, a)
        A("{} {},{}".format(op, regs, b))
        if condition(a, b):
            return 1
        return 0
    return trap_inner


def gen_add_sub(sub):
    g = gen_oprand()
    if sub:
        op = "sub"
        def f(a, b): return a - b
    else:
        op = "add"
        def f(a, b): return a + b

    def arithmatic_inner(A, au):
        a, b = next(g)
        regs = regutil.get_random(k=2)
        au.li(regs[0], a)
        au.li(regs[1], b)
        A("{} {},{}".format(op, *regs))

        a = a + ((a & 0x80000000) << 1)
        b = b + ((b & 0x80000000) << 1)
        res = f(a, b) & 0x1FFFFFFFF

        if ((res >> 32) ^ (res >> 31)) & 1:
            return 1
        return 0
    return arithmatic_inner


def gen_addi():
    g = gen_oprand_immed()
    def f(a, b): return a + b

    def arithmatic_inner(A, au):
        a, b = next(g)
        reg = regutil.get_one()
        au.li(reg, a)
        A("addi {},{}".format(reg, b))

        b = numutil.sign16(b) & 0xFFFFFFFF
        a = a + ((a & 0x80000000) << 1)
        b = b + ((b & 0x80000000) << 1)
        res = f(a, b) & 0x1FFFFFFFF

        if ((res >> 32) ^ (res >> 31)) & 1:
            return 1
        return 0
    return arithmatic_inner


def gen_reserved(A, au):
    reserved_instructions = [
        "TLBR",
        "SDC2 $4,0($2)",
        "DERET"
    ]
    if numutil.below(10) > 6:
        A(random.choice(reserved_instructions))
        return 1
    else:
        for x in range(20):
            au.li(regutil.get_one(), numutil.below(2**32))
        A(get_random_alu())
        return 0


configs = {
    "syscall": [gen_syscall, 0x08],
    "break":   [gen_break, 9],
    "tge":  [gen_trap_rtype("tge", lambda a, b:numutil.sign32(a) >= numutil.sign32(b)), 13],
    "tgeu": [gen_trap_rtype("tgeu", lambda a, b: a >= b), 13],
    "tlt":  [gen_trap_rtype("tlt", lambda a, b: numutil.sign32(a) < numutil.sign32(b)), 13],
    "tltu": [gen_trap_rtype("tltu", lambda a, b: a < b), 13],
    "teq":  [gen_trap_rtype("teq", lambda a, b: a == b), 13],
    "tne":  [gen_trap_rtype("tne", lambda a, b: a != b), 13],
    "tgei": [gen_trap_immedtype("tgei", lambda a, b: numutil.sign32(a) >= numutil.sign16(b)), 13],
    "tgeiu": [gen_trap_immedtype("tgeiu", lambda a, b: a >= numutil.sign16(b) & 0xFFFFFFFF), 13],
    "tlti":  [gen_trap_immedtype("tlti", lambda a, b: numutil.sign32(a) < numutil.sign16(b)), 13],
    "tltiu": [gen_trap_immedtype("tltiu", lambda a, b: a < numutil.sign16(b) & 0xFFFFFFFF), 13],
    "teqi":  [gen_trap_immedtype("teqi", lambda a, b: numutil.sign32(a) == numutil.sign16(b)), 13],
    "tnei":  [gen_trap_immedtype("tnei", lambda a, b: numutil.sign32(a) != numutil.sign16(b)), 13],
    "ov_add":   [gen_add_sub(False), 12],
    "ov_sub":   [gen_add_sub(True), 12],
    "ov_addi":  [gen_addi(), 12],
    "reserved": [gen_reserved, 10]
}
if len(sys.argv) == 1:
    p = pathlib.Path(sys.argv[0]).relative_to(pathlib.Path.cwd())
    for x in configs.keys():
        with open(p.parent / (x + ".bat"), "w") as f:
            f.write(str(p) + " " + x)
else:
    test_name = sys.argv[1]
    current_config = configs[test_name]
    exception_gen(test_name, current_config)
