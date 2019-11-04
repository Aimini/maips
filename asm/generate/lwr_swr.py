from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random,math,itertools

def gen_word_in_memory(A,total_bytes):
    A(".data")
    A(f"word_arrary: .byte ")
    string = ""
    for x in range(total_bytes):
       A(str(numutil.sign8(x)) + ',')
    

def my_gen1(A,au):
    for i in range(32):
        au.li(reg_list[i],0)

    address_base = 0x10010000
    byte_count = 2**2
    def convert_adddress(count):
        return address_base + count

    def get_random_offset(conut):
        addr = convert_adddress(conut)
        offset = numutil.s16()
        return addr - offset, offset

    for i in range(5000):
        base,off = get_random_offset(numutil.below(byte_count))
        value = numutil.u32()
        regs = regutil.get_random( k = 3)
        au.li(regs[0],value)
        au.li(regs[1],base)
        A(f"swr {regs[1]},{off}({regs[1]})")
        A(f"lwr {regs[2]},{off}({regs[1]})")
    
    def gen_random_lwr():
        base,off = get_random_offset(numutil.below(byte_count))
        regs = regutil.get_random( k = 2)
        au.li(regs[0],base)
        A(f"lwr {regs[1]},{off}({regs[0]})")
        return regs[1]


    for i in range(5000):
        reg0 = gen_random_lwr()
        reg1 = gen_random_lwr()
        regs = regutil.get_random( k = 2)
        A(f"addu {regs[1]},{reg0},{reg1}")
        base,off = get_random_offset(numutil.below(byte_count))
        au.li(regs[0],base)
        A(f"swr {regs[1]},{off}({regs[0]})")
        
    au.check_and_exit()
    gen_word_in_memory(A,byte_count)
    return ["mars","-d"]

r = gen('lwr_swr')
r.gen(my_gen1)