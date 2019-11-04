from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *

r = gen('ori_1')
def my_gen1(A,au):
    base = 5
    previous = 0
    for i in range(1, 16):
        x = i % 16
        rotate = (base << x) & 0xFFFF | base >> (16 - x)
        previous = previous | rotate
        A(f'ori ${i},${i - 1},{numutil.sx4(rotate)}')
    

    for i in range(16, 32):
        x = i % 16
        rotate = (base << x) & 0xFFFF | base >> (16 - x)
        A(f'ori ${i}, $0, {numutil.sx4(rotate)}')
    au.check_and_exit()

r.gen(my_gen1)

r = gen('ori_2')
def my_gen2(A,au):
    for i in reg_list[1:]:
        x = i.order % 16
        rotate = (1 << x) & 0xFFFF
        A(f'ori {i},$0, {numutil.sx4(rotate)}')
    au.check_and_exit()

r.gen(my_gen2)