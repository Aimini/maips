from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random
g = gen("addiu")
def my_gen(A,au):

    for i in reg_list:
        au.li(i, numutil.u32());

    for x in numutil.bound(16):
        reg = regutil.get_random(k = 2)
        A("addiu {},{},{}".format(*reg,x));

    for i in range(0,2048):
        va = numutil.s16()
        reg = regutil.get_random(k = 2)
        A("addiu {},{},{}".format(*reg, va));

    au.check_and_exit()

    # negtive
g.gen(my_gen)
