from gen_com import *

def gen_by(cmd):
    g = gen(cmd)
    def my_gen2(A,C,E):
        def logic_calculate(val1,val2):
            if cmd == "srl":
                return (val1 >> val2) & 0xFFFFFFFF
            else:
                return ((val1 >> val2) | (val1 << (32 - val2))) & 0xFFFFFFFF

        def assert_one(reg,reg_val,c):
            next_reg = reg + 1
            if next_reg >= 32:
                next_reg = 1
            next_val = logic_calculate(reg_val,c)
            A(f"{cmd} ${next_reg},${reg},{c}")
            A(assert_equal_immed(next_reg,next_val))
            return next_reg,next_val

        reg = 1
        val = 0x80000000
        A("li ${reg},{val}".format(reg = reg, val = val))
        for x in range(10240):
            reg,val = assert_one(reg,val,random.choice(range(32)))
            if val == 0:
                val = random.choice(range(1,2**32))
                A("li ${reg},{val}".format(reg= reg, val = val))
        A(check_and_exit())
    g.gen(my_gen2)

gen_by("srl")
gen_by("rotr")