from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *
import random
import math
import itertools
import sys


######################
# A: asm writer function
# reg:
# reg_val : which value store in reg
# immed:


def my_gen1(A, au, cmd):
    for i in reg_list:
        au.li(i, numutil.u32())

    # for x in range(1000):
    bound = numutil.bound(5)
    for msb in itertools.chain(bound, repeat_function(numutil.below, 32, k=10000)):
        # for msb in range(1):
        lsb = numutil.below(msb + 1)
        size = msb - lsb + 1
        reg_store, reg_ext = regutil.get_random(k=2)
        A(f"{cmd} {reg_store},{reg_ext},{lsb},{size}")
        reg_add_store, reg_add = regutil.get_random(k=2)
        A(f"addu {reg_add_store},{reg_store},{reg_add}")
    au.check_and_exit()


def gen_when(cmd):
    r = gen(cmd)
    def l(A, au): return my_gen1(A, au, cmd)
    r.gen(l)


gen_when(sys.argv[1])
