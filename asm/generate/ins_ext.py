from gen_com import *
import random,math,itertools,sys



######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:


def my_gen1(A,C,E,cmd):
    for i in range(32):
        A(f"li ${i},{get_u32()}")



    # for x in range(1000):
    bound = get_bound(5)
    for msb in itertools.chain(bound,repeat_function(get_random_below,32,time = 10000)):
    # for msb in range(1):
        lsb = get_random_below(msb + 1)
        size = msb - lsb + 1
        reg_store,reg_ext = get_random_exclude_reg(k = 2)
        A(f"{cmd} ${reg_store},${reg_ext},{lsb},{size}")
        reg_add_store,reg_add = get_random_exclude_reg(k = 2)
        A(f"addu ${reg_add_store},${reg_store},${reg_add}")
    A(check_and_exit())
    
def gen_when(cmd):
    r = gen(cmd)
    l = lambda A,C,E : my_gen1(A,C,E,cmd)
    r.gen(l)

gen_when(sys.argv[1])