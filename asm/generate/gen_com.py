

class gen:
    def __init__(self,name, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # generate asm file path and regiter check file path
        self.name = name
        self.asm_filename = name + ".asm"


    def gen(self,generate_funct):
        self.__replace = []
        
        with open(self.asm_filename,"w") as f:
            self.__asm_file = f
            A = lambda code :self.ASM(code)
            C = lambda b,arg: self.CHKREG(b,arg)
            E = lambda b: self.EXIT(b)
            self.ASM(".text")
            # callback
            generate_funct(A,C,E);

    def ASM(self,code):
        self.__asm_file.write(code +'\n')

    def CHKREG(self,base_reg,arg_reg):
        code = """
lui ${0}, 0xffff
sw  $0,   4(${0})
lui ${1}, 0x0001
sw  ${1}, 0(${0}) """.format(base_reg,arg_reg)
        self.ASM(code)
    
    def EXIT(self, base_reg) -> map:
        code =  """
lui ${0}, 0xffff
sw  $0, 0(${0})""".format(base_reg)
        self.ASM(code)
        # return code , {base_reg : 0xffff0000}
