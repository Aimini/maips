from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random

r = gen('lui_1')
def my_gen1(A,au):
    for x in reg_list[1:]:
        i = x.order %16
        base = 5
        rotate = (base << i)&0xFFFF | base >> (16 - i)
        A(f'lui {x},{numutil.sx4(rotate)}')

    au.check_and_exit()
r.gen(my_gen1)

r = gen('lui_2')
def my_gen2(A,au):
    for i in reg_list[1:]:
        x = numutil.u16()
        A(f'lui {i},{numutil.sx4(x)}')
    au.check_and_exit()

r.gen(my_gen2)