import random,pathlib,os
import itertools
class register:
    def __init__(self,name,order):
        self.name = name
        self.order = order
        self.value = 0

    def set(self,value):
        if self.order is not 0:
            self.value = value
        else:
            self.value = 0
    
    def get(self):
        if self.order is not 0:
            return self.value
        else:
            return 0
    
    def __str__(self):
        return "$" + str(self.order)

    def __repr__(self):
        return "{}:{}".format(self.name,self.value)

reg_zero = register("$zero",  0)
reg_at   = register("$at"  ,  1)
reg_v0   = register("$v0"  ,  2)
reg_v1   = register("$v1"  ,  3)
reg_a0   = register("$a0"  ,  4)
reg_a1   = register("$a1"  ,  5)
reg_a2   = register("$a2"  ,  6)
reg_a3   = register("$a3"  ,  7)
reg_t0   = register("$t0"  ,  8)
reg_t1   = register("$t1"  ,  9)
reg_t2   = register("$t2"  , 10)
reg_t3   = register("$t3"  , 11)
reg_t4   = register("$t4"  , 12)
reg_t5   = register("$t5"  , 13)
reg_t6   = register("$t6"  , 14)
reg_t7   = register("$t7"  , 15)
reg_s0   = register("$s0"  , 16)
reg_s1   = register("$s1"  , 17)
reg_s2   = register("$s2"  , 18)
reg_s3   = register("$s3"  , 19)
reg_s4   = register("$s4"  , 20)
reg_s5   = register("$s5"  , 21)
reg_s6   = register("$s6"  , 22)
reg_s7   = register("$s7"  , 23)
reg_t8   = register("$t8"  , 24)
reg_t9   = register("$t9"  , 25)
reg_k0   = register("$k0"  , 26)
reg_k1   = register("$k1"  , 27)
reg_gp   = register("$gp"  , 28)
reg_sp   = register("$sp"  , 29)
reg_fp   = register("$fp"  , 30)
reg_ra   = register("$ra"  , 31)
reg_list = [
    reg_zero,
    reg_at,
    reg_v0,
    reg_v1,
    reg_a0,
    reg_a1,
    reg_a2,
    reg_a3,
    reg_t0,
    reg_t1,
    reg_t2,
    reg_t3,
    reg_t4,
    reg_t5,
    reg_t6,
    reg_t7,
    reg_s0,
    reg_s1,
    reg_s2,
    reg_s3,
    reg_s4,
    reg_s5,
    reg_s6,
    reg_s7,
    reg_t8,
    reg_t9,
    reg_k0,
    reg_k1,
    reg_gp,
    reg_sp,
    reg_fp,
    reg_ra
    ]
class regutil:
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        

    def find(self,x):
        a = list(reg_list)
        if isinstance(x,int) or isinstance(x,str) and x.isnumeric():
            order = int(x)
            a = filter(lambda i: i.order == order, a)
        elif isinstance(x ,register): # treat as register instance
            a = filter(lambda i: i.order == x.order, a)
        else:
            name = x
            if not name.startswith("$"):
                name = "$" + name
            a = filter(lambda i: i.name == name, a)
        a = list(a)
        if len(a) == 0:
            return None
        return a[0]

    def get(self, exclude = []):
        al = list(reg_list)[1:]

        def filter_function(x):
            for one in exclude:
                if one is x:
                    return False
            return True

        a = list(filter(filter_function, al))
        return a

    def get_random(self, k = 1, exclude = []):
        a = self.get(exclude)
        if k > len(a) or k < 0:
            print("wtf")
        return random.sample(a, k = k)

    def get_one(self, exclude = []):
        return self.get_random(k = 1, exclude = exclude)[0]