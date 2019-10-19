from gen_com import *
import sys

def gen_by(cmd):
    g = gen(cmd)
    def my_gen2(A,C,E):
        def logic_calculate(val1,val2):
            val2 = val2 % 32
            if cmd == "srlv":
                return (val1 >> val2) & 0xFFFFFFFF
            elif cmd == "rotrv":
                return ((val1 >> val2) | (val1 << (32 - val2))) & 0xFFFFFFFF
            else:
                return (cutto_sign32(val1) >> val2)& 0xFFFFFFFF
                
        def gen_sr(shift_base,base_value):
            for i in range(2,32):
                A(set_immed(1,shift_base))
                A(set_immed(i,base_value + i))
                A(f"{cmd} ${i},$1,${i}")
                A(assert_equal_immed(i,logic_calculate(shift_base,base_value + i)))
        
        gen_sr(1,0)
        for i in range(512):
            gen_sr(get_u32(),get_u32())

        
        for i in range(1024):
            reg = get_random_exclude_reg(k = 3)
            A(f"addu ${reg[0]},${reg[1]},${reg[2]}")
            reg = get_random_exclude_reg(k = 3)
            A(f"addu ${reg[0]},${reg[1]},${reg[2]}")
            reg = get_random_exclude_reg(k = 3)
            A(f"addu ${reg[0]},${reg[1]},${reg[2]}")
            reg = get_random_exclude_reg(k = 3)
            A(f"{cmd} ${reg[0]},${reg[1]},${reg[2]}")
        A(check_and_exit())
    g.gen(my_gen2)

gen_by(sys.argv[1])