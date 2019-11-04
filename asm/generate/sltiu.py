from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
from __gen_slti_sltiu import *
import random


######################
# A: asm writer function
# reg: which reg you want to compare to immed
# reg_val : value storage in reg
# immed:

def cmp(reg_val,immed):
    return (numutil.sign32(reg_val) & 0xFFFFFFFF) < (numutil.sign16(immed) & 0xFFFFFFFF)

r = gen('sltiu')
r.gen(lambda A,au: pre_gen(A,au,cmp,'sltiu'))
