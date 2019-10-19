from gen_com import *

g = gen("sllv")

def my_gen2(A,C,E):
    def gen_sslv(shift_base,base_value):
        for i in range(2,32):
            A(set_immed(1,shift_base))
            A(set_immed(i,base_value + i))
            A(f"sllv ${i},$1,${i}")
            A(assert_equal_immed(i,(shift_base << ((base_value + i)%32))&0xFFFFFFFF))
    gen_sslv(1,0)
    for i in range(512):
        gen_sslv(get_u32(),get_u32())

    for i in range(4096):
        reg = get_random_exclued_reg(k = 3)
        A(f"addu ${reg[0]},${reg[1]},${reg[2]}")
        reg = get_random_exclued_reg(k = 3)
        A(f"addu ${reg[0]},${reg[1]},${reg[2]}")
        reg = get_random_exclued_reg(k = 3)
        A(f"addu ${reg[0]},${reg[1]},${reg[2]}")
        reg = get_random_exclued_reg(k = 3)
        A(f"sllv ${reg[0]},${reg[1]},${reg[2]}")
    A(check_and_exit())

g.gen(my_gen2)