from __gen_slti_sltiu import *

def cmp(reg_val,immed):
    return numutil.sign32(reg_val) < numutil.sign16(immed)

r = gen('slti')
r.gen(lambda A,au: pre_gen(A,au,cmp,'slti'))