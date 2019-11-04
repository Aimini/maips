from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *
import sys


def gen_by(cmd):
    def my_gen2(A, au):
        def logic_calculate(val1, val2):
            if cmd == "srl":
                return (val1 >> val2) & 0xFFFFFFFF
            elif cmd == "rotr":
                return ((val1 >> val2) | (val1 << (32 - val2))) & 0xFFFFFFFF
            else:
                return (numutil.sign32(val1) >> val2) & 0xFFFFFFFF

        def assert_one(reg_idx, reg_val, c):
            next_reg_idx = reg_idx + 1
            if next_reg_idx >= 32:
                next_reg_idx = 1
            next_val = logic_calculate(reg_val, c)
            A(f"{cmd} ${next_reg_idx},${reg_idx},{c}")
            au.assert_equal(reg_list[next_reg_idx], next_val)
            return next_reg_idx, next_val

        reg_idx = 1
        val = 0x80000000
        au.li(reg_list[reg_idx], val)
        for x in range(1024):
            reg_idx, val = assert_one(reg_idx, val, numutil.below(2**5))
            if val == 0:
                val = random.choice(range(1, 2**32))
                au.li(reg_list[reg_idx], val)
        au.check_and_exit()

    g = gen(cmd)
    g.gen(my_gen2)


gen_by(sys.argv[1])
