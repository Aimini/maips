from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
from __exception_test import exception_gen
import random,math,itertools,sys


word_count_limit = 2**10 # 1k word
mem_content = list(repeat_function(numutil.u32,k = word_count_limit))
r = gen("read_instruction")
def my_gen1(A,au):
    au.gnu_as_head()
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
        au.assert_equal(reg_a0,x)
    au.exit()
    return ["kernel"]
    
r.gen(my_gen1)



