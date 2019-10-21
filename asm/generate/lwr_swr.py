from gen_com import *
import random,math,itertools

r = gen('lwr_swr')

######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:
def gen_word_in_memory(A,total_bytes):
    A(".data")
    A(f"word_arrary: .byte ")
    string = ""
    for x in range(total_bytes):
       A(str(cutto_sign8(x)) + ',')
    

def my_gen1(A,C,E):
    for i in range(32):
        A(f"li ${i},0")

    address_base = 0x10010000
    byte_count = 2**2
    def convert_adddress(count):
        return address_base + count

    def get_random_offset(conut):
        addr = convert_adddress(conut)
        offset = get_s16()
        return addr - offset, offset

    for i in range(5000):
        base,off = get_random_offset(get_random_below(byte_count))
        value = get_u32()
        regs = get_random_exclude_reg( k = 3)
        A(set_immed(regs[0],value))
        A(set_immed(regs[1],base))
        A(f"swr ${regs[1]},{off}(${regs[1]})")
        A(f"lwr ${regs[2]},{off}(${regs[1]})")
    
    def gen_random_lwr():
        base,off = get_random_offset(get_random_below(byte_count))
        regs = get_random_exclude_reg( k = 2)
        A(set_immed(regs[0],base))
        A(f"lwr ${regs[1]},{off}(${regs[0]})")
        return regs[1]


    for i in range(5000):
        reg0 = gen_random_lwr()
        reg1 = gen_random_lwr()
        regs = get_random_exclude_reg( k = 2)
        A(f"addu ${regs[1]},${reg0},${reg1}")
        base,off = get_random_offset(get_random_below(byte_count))
        A(set_immed(regs[0],base))
        A(f"swr ${regs[1]},{off}(${regs[0]})")
    A(check_and_exit())
    gen_word_in_memory(A,byte_count)
r.gen(my_gen1)