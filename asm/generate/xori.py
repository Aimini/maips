from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *


def my_gen1(A, au):
    base = 0x0003
    for i in range(1, 32):
        x = i % 16
        rotate = (base << x) & 0xFFFF | base >> (16 - x)
        A(f'xori ${i},${i - 1},{numutil.sx4(rotate)}')
    au.check_and_exit()


r = gen('xori_1')
r.gen(my_gen1)


def my_gen2(A, au):
    for i in reg_list:
        au.li(i, numutil.u32())

    for i in range(1024):
        au.li(regutil.get_one(), numutil.u32())
        au.li(regutil.get_one(), numutil.u32())
        regs = regutil.get_random(k=2)
        num = numutil.u16()
        A(f'xori {regs[0]},{regs[1]},{numutil.sx4(num)}')
        regs = regutil.get_random(k=2)
        num = random.choice(numutil.bound(16))
        A(f'xori {regs[0]},{regs[1]},{numutil.sx4(num)}')
    au.check_and_exit()


r = gen('xori_2')
r = gen('xori_1')

r.gen(my_gen2)
