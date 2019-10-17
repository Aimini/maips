import random,pathlib,os

class gen:
    def __init__(self,name, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # generate asm file path and regiter check file path
        self.name = name
        self.asm_filename = pathlib.Path('.') /'temp'/ (name + '.asm')
        self.cmd_filename = pathlib.Path('.') / ('compile_command.cmd')

    def gen(self,generate_funct):
        self.__replace = []
        
        with open(self.asm_filename,"w") as f:
            self.__asm_file = f
            A = lambda code :self.ASM(code)
            C = lambda b,arg: self.CHKREG(b,arg)
            E = lambda b: self.EXIT(b)
            self.ASM(".text")
            # callback
            r = generate_funct(A,C,E);
            compile_cmd = "tool\\mips_compile.py " + str(self.asm_filename);
        with open(self.cmd_filename,"w") as f:
            f.write(compile_cmd + "\n");
        if r is not 0: # default to compile
            os.system(compile_cmd)

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

reg_name_map = {
    "$zero": 0,
    "$at": 1,
    "$v0": 2,
    "$v1": 3,
    "$a0": 4,
    "$a1": 5,
    "$a2": 6,
    "$a3": 7,
    "$t0": 8,
    "$t1": 9,
    "$t2": 10,
    "$t3": 11,
    "$t4": 12,
    "$t5": 13,
    "$t6": 14,
    "$t7": 15,
    "$s0": 16,
    "$s1": 17,
    "$s2": 18,
    "$s3": 19,
    "$s4": 20,
    "$s5": 21,
    "$s6": 22,
    "$s7": 23,
    "$t8": 24,
    "$t9": 25,
    "$k0": 26,
    "$k1": 27,
    "$gp": 28,
    "$sp": 29,
    "$fp": 30,
    "$ra": 31
}
######################################
# get register file list than exclude register in args

def get_exclued_reg_list(*args):
    #exclude $zero
    a = list(range(1,32))
    for one in args:
        #get by int
        if(isinstance(one,int) or one.isnumeric()):
            num = int(one)
            if num < 0 or num >= 32:
                raise IndexError("invalid register number: {0} , number must in range(0,32)".format(num))
            try:
                a.remove(num)
            except ValueError as e:
                print("remove twice ${}".format(num))
            continue

        # get by string name
        num1 = reg_name_map.get(one.strip())
        if num1 is None:
           num1 = reg_name_map.get("$" + one)
        if num1 is None:
            raise IndexError("invalid reigster name:{0}".format(one))
        try:
            a.remove(num1)
        except ValueError as e:
            print("remove twice ${}".format(num1))
    return a


def get_random_exclued_reg( k = 1, exclude = []):
    a = get_exclued_reg_list(*exclude)
    return random.sample(a,k = k)


def set_immed(reg,immed):
    return """lui  ${0},   0x{1:0>4X}
ori ${0},   0x{2:0>4X}""".format(reg,(immed >>16) & 0xFFFF, immed & 0xFFFF)
####################################################
# call exit function in modelsim
# using base_reg as momory address base
# * you must implement lui,sw-dbg before using this!
#####################################################
def exit_using(base_reg = None) -> map:
    if base_reg is None:
        base_reg = get_random_exclued_reg(k = 1)
    code =  """
lui ${0}, 0xffff
sw  $0, 0(${0})""".format(base_reg)
    return code


##################################################
# call check register file function in modelsim
# using base_reg as address base 
# using arg_reg to store argument
#  for example : 
# lui $base_reg, 0xffff
# sw  $0,   4($base_reg)
# lui $arg_reg , 0x0001
# sw  $arg_reg , 0($base_reg)
# * you must implement lui,sw-dbg before using this!
#################################################

def check_reg_using(base_reg = None,arg_reg = None,ignore_gp_sp = False):
    if base_reg is None or arg_reg is None:
        base_reg,arg_reg = get_random_exclued_reg(k = 2)

    code1 = """
lui ${0}, 0xffff
sw  $0,   4(${0})
lui ${1}, 0x0001
sw  ${1}, 0(${0}) """.format(base_reg,arg_reg)
    code2 = """
lui ${0}, 0xffff
lui ${1}, 0x0001
sw  ${1}, 4(${0})
lui ${1}, 0x0001
sw  ${1}, 0(${0}) """.format(base_reg,arg_reg)
    if ignore_gp_sp:
        return code2
    else:
        return code1




def check_and_exit(base_reg  = None,arg_reg  = None,ignore_gp_sp = False):
    if base_reg is None or arg_reg is None:
        base_reg,arg_reg = get_random_exclued_reg(k = 2)
    return check_reg_using(base_reg,arg_reg,ignore_gp_sp) +'\n' + exit_using(base_reg)


######################################################################
# call  assert function
# * you must implement lui \ xori \ sw-dbg before using this!
#######################################################################
def assert_function(f,reg1,reg2,base_reg = None,arg_reg = None):
    if base_reg is None or arg_reg is None:
        base_reg,arg_reg = get_random_exclued_reg(k = 2,exclude=[reg1,reg2])

    code = """
lui ${0}, 0xffff
sw  ${2},   4(${0})
sw  ${3},   8(${0})
    {4}
sw  ${1}, 0(${0}) """.format(base_reg,arg_reg,reg1,reg2,set_immed(arg_reg, f))
    return code


def assert_equal(reg1,reg2,base_reg = None,arg_reg = None):
    return assert_function(1,reg1,reg2,base_reg,arg_reg)

def assert_not_equal(reg1,reg2,base_reg = None,arg_reg = None):
    return assert_function(2,reg1,reg2,base_reg,arg_reg)

######################################################################
# call  assert immed function
# * you must implement lui \ xori \ sw-dbg before using this!
#######################################################################
def assert_function_immed(f,reg,immed,base_reg = None,arg_reg = None):
    if base_reg is None or arg_reg is None:
        base_reg,arg_reg = get_random_exclued_reg(k = 2,exclude=[reg])

    code = """
{immed}
lui ${base}, 0xffff
sw  ${arg}, 4(${base})
sw  ${reg}, 8(${base})
{funct}
sw  ${arg}, 0(${base}) """.format(base = base_reg,arg = arg_reg,reg = reg,\
    immed = set_immed(arg_reg, immed),\
    funct = set_immed(arg_reg, f))
    return code

def assert_equal_immed(reg,immed,base_reg = None,arg_reg = None):
    return assert_function_immed(1,reg,immed,base_reg,arg_reg);


def cutto_sign32(val):
    ret = val & 0xFFFFFFFF
    if ret >= 0x80000000:
        ret = -(2**32 - ret) 
    return ret

def cutto_sign16(val):
    ret = val & 0xFFFF
    if ret >= 0x8000:
        ret = -(2**16 - ret)
    return ret