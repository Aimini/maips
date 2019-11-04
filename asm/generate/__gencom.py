import random,pathlib,os
import itertools
import sys
from __asmutil import asmutil
from __regutil import regutil
class gen:
    def __init__(self, name, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # generate asm file path and regiter check file path
        self.name = name
        self.asm_filename = pathlib.Path('.') /'temp'/ (name + '.s')
        

    def gen(self,generate_funct):
        if True:
            with open(self.asm_filename,"w") as f:
                self.au = asmutil(f)
                A = lambda code :self.ASM(code)
                self.ASM(".text")

                # callback
                r = generate_funct(A, self.au)
        else:
            self.au = asmutil(sys.stdout)
            A = lambda code :self.ASM(code)
            self.ASM(".text")
            # callback
            r = generate_funct(A, self.au)
            
        compiler= "mars"
        addition_option = ""
        try:
            compiler = r[0]
            addition_option = r[1]
        except:
            pass
            
        if compiler is "" or compiler is None:
            complier = "mars"

        if addition_option is "" or addition_option is None:
            addition_option = ""

        cmd = ["tool\\mips_compile.py","-c",compiler, "-i",str(self.asm_filename), addition_option]
        cmd = ' '.join(cmd)
        print(cmd)
        if os.system(cmd) != 0:
            exit(-1)
        
    
    def ASM(self,code):
        self.au.ASM(code +'\n')

def parameter_iter_pass(*args,callback):
    # record the iter arguments
    iter_args = []
    # record iter arguments coressponding index
    iter_args_index = []
    # record the argument list with out iterable arguments.
    exclude_iter_args = [None for x in args]
    for idx,ele in enumerate(args):
        if hasattr(ele,'__iter__'):
            iter_args.append(ele)
            iter_args_index.append(idx);
        else:
            exclude_iter_args[idx] = ele;


    # print(itertools.product(*iter_args))
    for one_group in itertools.product(*iter_args):
        pass_args =  [None for x in args];
        for idx,ele in enumerate(one_group):
            pass_args[iter_args_index[idx]] = ele

        for idx,ele in enumerate(exclude_iter_args):
            if ele is None:
                continue;
            if callable(ele):
                pass_args[idx] = ele()
            else:
                pass_args[idx] = ele
        # print(pass_args)
        callback(*pass_args)

##
## return a generator than get funct(*args) <time> times
def repeat_function(funct,*args,k = 1):
    for x in range(k):
        yield funct(*args)

def get_random_alu():
    reg = regutil.get_random(k = 3)
    triple_arg = f"{reg[0]},{reg[1]},{reg[2]}"
    double_arg = f"{reg[0]},{reg[1]}"
    single_arg = f"{reg[0]}"
    statement = [f"addu {triple_arg}",
    f"subu  {triple_arg}",
    f"and   {triple_arg}",
    f"or    {triple_arg}",
    f"xor   {triple_arg}",
    f"nor   {triple_arg}",
    f"slt   {triple_arg}",
    f"sltu  {triple_arg}",
    f"mult  {double_arg}",
    f"multu {double_arg}",
    f"mfhi  {single_arg}",
    f"mthi {single_arg}",
    f"mflo {single_arg}",
    f"mtlo {single_arg}"]
    return random.choice(statement)


