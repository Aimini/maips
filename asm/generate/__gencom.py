import random,pathlib,os
import itertools
import sys
from __asmutil import asmutil
class gen:
    def __init__(self, name, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # generate asm file path and regiter check file path
        self.name = name
        self.asm_filename = pathlib.Path('.') /'temp'/ (name + '.s')
        

    def gen(self,generate_funct):
        self.__replace = []
        compiler= "mars"
        if True:
            with open(self.asm_filename,"w") as f:
                self.au = asmutil(f)
                A = lambda code :self.ASM(code)
                self.ASM(".text")

                # callback
                compiler,addition_option = generate_funct(A, self.au)
        else:
            self.au = asmutil(sys.stdout)
            A = lambda code :self.ASM(code)
            self.ASM(".text")
            # callback
            compiler,addition_option = generate_funct(A, self.au)

        if compiler is "" or compiler is None:
            complier = "mars"

        if addition_option is "" or addition_option is None:
            addition_option = ""

        cmd = ["tool\\mips_compile.py","-c",compiler, "-i",str(self.asm_filename), addition_option]
        cmd = ' '.join(cmd)
        print(cmd)
        os.system(cmd)
        
    
    def ASM(self,code):
        self.au.ASM(code +'\n')