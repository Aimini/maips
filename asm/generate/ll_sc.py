from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random,math,itertools

r = gen('ll_sc')

word_count_limit = 2**4 # 1k word
data_segment_base = 0x90000000
mem_content = list(range(word_count_limit))

def gen_assert_one(A,au,addr,base,offset,target_value):
        trigger_exception = numutil.below(3) == 0

        mem_content_offset = (addr - 0x90000000) >> 2

        rt,reg_base = regutil.get_random(k = 2)
        au.li(reg_base, base)
        A(f"ll {rt},{offset}({reg_base})")
        if trigger_exception:
            A("syscall")
        else:
            mem_content[mem_content_offset] = mem_content[mem_content_offset] + 1

        au.li(reg_base, base)
        A(f"addiu {rt},{rt},1")                # check rt
        A(f"sc    {rt},{offset}({reg_base})")
        au.assert_equal(rt, 0 if trigger_exception else 1)

        au.li(reg_base, base)
        A(f"lui   {rt},0")                       # check memory content
        A(f"lw    {rt},{offset}({reg_base})")
        au.assert_equal(rt,  mem_content[mem_content_offset])

        A(f"mfc0 {rt},$17")         # check lladdr
        au.assert_equal(rt,  addr)


def my_gen1(A,au):
    A("""
.set noat
.globl __start
.align 4

.section .data
array:""")
    for x in mem_content:
        A(f".word 0x{x:0>8X}") 

    A("""
    .section .text
    __start:
        mtc0 $0, $12 # set StatusBEV to zero
        b   __next

    .org 0x180  #if clock interrupt triggered before 
                # exit kernel mode, it's come to here
        mfc0  $k0,$14    #set eret
        addiu $k0,$k0,4
        mtc0  $k0,$14
        eret
    __next:
    """)
    for i in range(32):
        au.li(reg_list[i],0)



    def test_one_address(word_count, offset):
        word_address = word_count*4 + data_segment_base
        base_address = word_address - offset
        gen_assert_one(A,au,word_address, base_address, offset, word_count);
    
    def test_by_iter(word_cout,offset):
        parameter_iter_pass(word_cout,offset,callback = test_one_address)
        
    bound =numutil.bound(16,True)
    # check from 0x10000000 to last word

    test_by_iter(lambda : numutil.below(word_count_limit), 5*bound)
    test_by_iter(repeat_function(numutil.below ,word_count_limit ,k = 2000), numutil.s16);
    test_by_iter(lambda : numutil.below(word_count_limit), repeat_function(numutil.s16,k =2000));


    au.exit()
    return ["kernel"]
r.gen(my_gen1)