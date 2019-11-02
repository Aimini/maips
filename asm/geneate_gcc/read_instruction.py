from gen_com import *
from exception_test import exception_gen
import random,math,itertools,sys


word_count_limit = 2**10 # 1k word
mem_content = list(repeat_function(get_u32,time = word_count_limit))
r = gen("read_instruction")
def my_gen1(A,C,E):
    A(get_as_head())
    A("""
    __start:
    b __next
    """)
    A("read_start:")
    for x in mem_content:
        A(".word 0x{:0>8x}".format(x))
    A("read_end:")
    A("__next:")

    
    
    for i,x in enumerate(mem_content):
        A("la $t0, read_start")
        A("addiu $t1,$t0,{}".format(4*i))
        A("lw $a0, 0($t1)")
        A(assert_equal_immed("a0",x))
    A(exit_using())

r.gen(my_gen1)



