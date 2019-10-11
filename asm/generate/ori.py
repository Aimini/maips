import sys
def check_all_by(reg1,reg2) -> map:
    code = """
    lui ${0}, 0xffff
    sw  $0,   4(${0})
    lui ${1}, 0x0001
    sw  ${1}, 0(${0}) """.format(reg1,reg2)
    return code , {reg1: 0xffff0000,reg2: 0x00010000}

def exit_by(reg) -> map:
    code =  """
    lui ${0}, 0xffff
    sw  $0, 0(${0})""".format(reg)
    return code , {reg : 0xffff0000}

def replace_reg(filename,m : map):
    with open(filename,"r+") as f:
        all = f.readlines()
        f.seek(0)
        for idx,one in enumerate(all):
            if idx == 0: #$0
                f.write("00000000\n")
            elif idx in m.keys(): #$gp
                f.write("{0:0>8x}\n".format(m[idx]))
            else:
                f.write(one)

class gen:
    def __init__(self,name, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.name = name
        self.asm_filename = name + ".asm"
        self.regchk_filename = "temp/" + name + ".reg.hextext"

    def gen(self,generate_funct):
        with open(self.asm_filename,"w") as f,open(self.regchk_filename,"w") as reg:
            self.__asm_file = f
            self.__reg_file = reg
            A = lambda code :self.ASM(code)
            R = lambda value: self.REG(value)
            self.ASM(".text")
            generate_funct(A,R);

    def ASM(self,code):
        self.__asm_file.write(code +'\n')

    def REG(self,value):
        self.__reg_file.write("{0:0>8x}\n".format(value))



r = gen('ori')
replace = []
def my_gen(A,R):
    base = 5
    previous = 0
    R(0)
    for i in range(1, 16):
        x = i % 16
        rotate = (base << x) & 0xFFFF | base >> (16 - x)
        previous = previous | rotate
        R(previous)
        A('ori ${0},${1},0x{2:0>4x}'.format(i,i - 1,rotate))
    

    for i in range(16, 32):
        x = i % 16
        rotate = (base << x) & 0xFFFF | base >> (16 - x)
        R(rotate)
        A('ori ${0},${1},0x{2:0>4x}'.format(i,0,rotate))

    code,rep_one = check_all_by(1,6)
    replace.append(rep_one)
    A(code)
    code,rep_one = exit_by(1)
    A(code)
    
r.gen(my_gen)
for one in replace:
    replace_reg(r.regchk_filename, one)

r = gen('ori_2')
replace = []
def my_gen2(A,R):
    R(0)
    for i in range(1, 32):
        x = i % 16
        rotate = (1 << x) & 0xFFFF
        R(rotate)
        A('ori ${0},${1},0x{2:0>4x}'.format(i,0,rotate))

    code,rep_one = check_all_by(5,17)
    replace.append(rep_one)
    A(code)
    code,rep_one = exit_by(17)
    A(code)

r.gen(my_gen2)
for one in replace:
    replace_reg(r.regchk_filename, one)