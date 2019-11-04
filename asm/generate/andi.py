from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *

r = gen('andi_1')
def my_gen1(A,au):
    base = 5
    for i in reg_list:
        au.li(i,0xFFFFFFFF)
        
    base =  0xFFFA
    for i in range(1,32):
        x = i % 16
        rotate = (base << x) & 0xFFFF | base >> (16 - x)
        A('andi {0},{0},{1}'.format(reg_list[i],rotate))
    au.check_and_exit()

r.gen(my_gen1)
r = gen('andi_2')
def my_gen2(A,au):
    for i in reg_list:
        au.li(i,numutil.u32())

    for i in range(4096):
        au.li(regutil.get_one(),numutil.u32())
        au.li(regutil.get_one(),numutil.u32())
        A('andi {0},{1},{2}'.format(regutil.get_one(),regutil.get_one(),numutil.u16()))
        A('andi {0},{1},{2}'.format(regutil.get_one(),regutil.get_one(),random.choice(range(2**16 - 10,2**16))))
        A('andi {0},{1},{2}'.format(regutil.get_one(),regutil.get_one(),random.choice(range(0,10))))
    au.check_and_exit()

r.gen(my_gen2)