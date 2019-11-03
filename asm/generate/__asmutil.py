from __regutil import *
from __numutil import *
class asmutil:
    def __init__(self, f, using_provide_sys_reg = False, base_reg = reg_a0, arg_reg = reg_a1, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.f = f
        self.using_provide_sys_reg = using_provide_sys_reg
        self.base_reg = base_reg
        self.arg_reg = arg_reg
        self.regutil = regutil()


    def ASM(self, text):
        if self.f is not None:
            self.f.write(text)
            self.f.write('\n')

    def clear_reg(self):
        for x in range(32):
            self.li(reg_list[x], 0)

    def li(self,reg,x):
        hi = (x >>16) & 0xFFFF;
        lo = x & 0xFFFF
        self.ASM(
        f"""
        lui {reg}, {numutil.sx4(hi)} ###### li {reg}, {numutil.sx8(x)}
        ori {reg}, {numutil.sx4(lo)}                    """)


    def sw(self, reg, offset, base_reg):
        self.ASM(f"""
        sw {reg}, {offset}({base_reg})""")

    def get_sys_reg(self,base_reg, arg_reg, exclude = []):
        if base_reg is None:
            base_reg = self.regutil.get_one(exclude = exclude)
        if arg_reg is None:
            exclude = list(exclude)
            exclude.append(base_reg)
            arg_reg = self.regutil.get_one(exclude = exclude)
        if base_reg == arg_reg:
            print("wtf")
        return base_reg, arg_reg


    def sys(self, base_reg = None, arg_reg  = None, *args):
        reg_args = []
        for x in args:
            if isinstance(x, register):
                reg_args.append(x)
        if self.using_provide_sys_reg:
            base_reg = self.base_reg
            arg_reg = self.arg_reg
        else:
            base_reg, arg_reg = self.get_sys_reg(base_reg, arg_reg, exclude = reg_args)

        self.ASM("##################### sys dbg")
        self.ASM(f"""
        lui {base_reg}, 0xffff""")
        arg_count = len(args)
        for x in reversed(args):
            arg_count -= 1
            if not isinstance(x, register): #not reg, treat as constants
                self.li(arg_reg, x)
                self.sw(arg_reg,4*arg_count, base_reg)
            else:
                self.sw(x,4*arg_count, base_reg)
        pass

    ####################################################
    # call exit function in modelsim
    # using base_reg as momory address base
    # * you must implement lui,sw-dbg before using this!
    #####################################################
    def exit(self,base_reg = None):
        args = [reg_zero]
        self.sys(base_reg, 0, *args)

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
    def check_reg(self,ignore_gp_sp = False,base_reg = None,arg_reg = None):
        args = [0x00010000]
        if ignore_gp_sp:
            args.append(1)
        else:
            args.append(reg_zero)

        self.sys(base_reg, arg_reg, *args)


    def check_and_exit(self,ignore_gp_sp = False, base_reg  = None,arg_reg  = None):
        base_reg, arg_reg = self.get_sys_reg(base_reg, arg_reg)
        self.check_reg(ignore_gp_sp,base_reg,arg_reg)
        self.exit(base_reg)

    def assert_equal(self,arg0,arg1,base_reg = None,arg_reg = None):
        self.ASM("##################### assert equal")
        self.sys(base_reg,arg_reg, 1,arg0,arg1)

    def assert_not_equal(self,arg0,arg1,base_reg = None,arg_reg = None):
        self.ASM("##################### assert not equal")
        self.sys(base_reg,arg_reg, 2,arg0,arg1)
