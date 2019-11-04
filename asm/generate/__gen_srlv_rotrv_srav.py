from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import sys

def gen_by(cmd):
    g = gen(cmd)
    def my_gen2(A,au):
        def logic_calculate(val1,val2):
            val2 = val2 % 32
            if cmd == "srlv":
                return (val1 >> val2) & 0xFFFFFFFF
            elif cmd == "rotrv":
                return ((val1 >> val2) | (val1 << (32 - val2))) & 0xFFFFFFFF
            else:
                return (numutil.sign32(val1) >> val2)& 0xFFFFFFFF
                
        def gen_sr(shift_base,base_value):
            for i in range(2,32):
                au.li(reg_list[1],shift_base)
                au.li(reg_list[i],base_value + i)
                A(f"{cmd} ${i},$1,${i}")
                au.assert_equal(reg_list[i],logic_calculate(shift_base,base_value + i))
        
        gen_sr(1,0)
        for i in range(512):
            gen_sr(numutil.u32(),numutil.u32())

        
        for i in range(1024):
            reg = regutil.get_random(k = 3)
            A(f"addu {reg[0]},{reg[1]},{reg[2]}")
            reg = regutil.get_random(k = 3)
            A(f"addu {reg[0]},{reg[1]},{reg[2]}")
            reg = regutil.get_random(k = 3)
            A(f"addu {reg[0]},{reg[1]},{reg[2]}")
            reg = regutil.get_random(k = 3)
            A(f"{cmd} {reg[0]},{reg[1]},{reg[2]}")
        au.check_and_exit()
    g.gen(my_gen2)

gen_by(sys.argv[1])