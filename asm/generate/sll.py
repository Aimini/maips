from gen_com import *

g = gen("sll_1")
def my_gen(A,C,E):
    A("ori $1,0x0001")
    for i in range(2,32):
        A("sll ${0},$1,{1}".format(i,i));
    A("sll $1,$1,0");
    A("sll $1,$1,1");
    C(20,21)
    E(20)

g.gen(my_gen)

g = gen("sll_2")
def my_gen2(A,C,E):
    A("ori $31,0x1001")
    for i in range(1,32):
        A("sll ${0},$31,{1}".format(i,i));
    C(21,22)
    E(21)

g.gen(my_gen2)