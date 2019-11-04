from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random
g = gen("subu")
def my_gen(A,au):
    b = numutil.bound(32)
    for x in range(128):
        for i in b:
            reg = regutil.get_random(k = 3)
            au.li(reg[2],i)
            A("subu {},{},{}".format(*reg));

    
    for i in range(0,10000):
        va = numutil.u32()
        reg = regutil.get_random(k = 3)
        au.li(reg[2],va)
        A("subu {},{},{}".format(*reg));
    au.check_and_exit()

g.gen(my_gen)
