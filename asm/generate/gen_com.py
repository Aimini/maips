

class gen:
    def __init__(self,name, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # generate asm file path and regiter check file path
        self.name = name
        self.asm_filename = name + ".asm"
        self.regchk_filename = "temp/" + name + ".reg.hextext"

    def gen(self,generate_funct):
        self.__replace = []
        
        with open(self.asm_filename,"w") as f,open(self.regchk_filename,"w") as reg:
            self.__asm_file = f
            self.__reg_file = reg
            A = lambda code :self.ASM(code)
            R = lambda value: self.REG(value)
            C = lambda b,arg: self.CHKREG(b,arg)
            E = lambda b: self.EXIT(b)
            self.ASM(".text")
            # callback
            generate_funct(A,R,C,E);
        self.replace_reg()
    
    # replace result becuase of 
    def replace_reg(self):
        for r in self.__replace:
            with open(self.regchk_filename,"r+") as f:
                all = f.readlines()
                f.seek(0)
                for idx,one in enumerate(all):
                    if idx == 0: #$0
                        f.write("00000000\n")
                    elif idx in r.keys(): #$gp
                        f.write("{0:0>8x}\n".format(r[idx]))
                    else:
                        f.write(one)

    def ASM(self,code):
        self.__asm_file.write(code +'\n')

    def REG(self,value):
        self.__reg_file.write("{0:0>8x}\n".format(value))

    def CHKREG(self,base_reg,arg_reg):
        code = """
lui ${0}, 0xffff
sw  $0,   4(${0})
lui ${1}, 0x0001
sw  ${1}, 0(${0}) """.format(base_reg,arg_reg)
        self.ASM(code)
        self.__replace.append({base_reg: 0xffff0000,arg_reg: 0x00010000})
        self.__base_reg = base_reg
    
    def EXIT(self, base_reg) -> map:
        code =  """
    lui ${0}, 0xffff
    sw  $0, 0(${0})""".format(base_reg)
        self.ASM(code)
        # return code , {base_reg : 0xffff0000}
