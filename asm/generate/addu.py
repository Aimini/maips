from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random
g = gen("addu")
def my_gen(A,au):
    for i in range(0,4096):
        va = numutil.u32()
        reg = regutil.get_random(k=3)
        au.li(reg[2],va);
        A("addu {0},{1},{2}".format(*reg));

    au.check_and_exit()

g.gen(my_gen)
