#
#comvert mips asm to logisim bin code format
#
import os,sys
import pathlib
import subprocess
import re
from optparse import OptionParser

optParser = OptionParser()

optParser.add_option('-i','--input-file',      action = 'store',type = "string", dest = 'input')
optParser.add_option('-o','--output-directory',action = 'store',type = "string", dest = 'output_dir',default='temp')
optParser.add_option("-c","--compiler",        action = 'store',type = "string", dest = "compiler",  default='mars')

optParser.add_option("-r","--range",           action = 'store',     type = "string", dest = "range",  default='.text')
optParser.add_option("-b","--address-binary",  action = 'store_true',dest = "addr_bin",      default=False)
optParser.add_option("-a","--aseembly-only",   action = 'store_true',dest = "aseembly_only", default=False)
optParser.add_option("-d","--dump-data",       action = 'store_true',dest = "dump_data",     default=False)
optParser.add_option("-D","--dump-disassembly",action = 'store_true',dest = "dump_disa",     default=False)

options, args = optParser.parse_args(sys.argv[1:])

def get_mips_compile_cmd(options):
    compiler_map = {
        "mars"  : "Mars.jar",
        "mix"   : "mix_compile.py",
        "kernel": "gcc_compile.py"
    }

    compiler = compiler_map[options.compiler]
        
    namepath = pathlib.Path(options.input)
    name = namepath.stem
    pdir = pathlib.Path('.')
    tooldir = pdir / "tool"
    outputdir = pdir / options.output_dir


    textdumpdir = outputdir/ "{0}.text.bin".format(name)
    datadumpdir = outputdir/ "{0}.data.bin".format(name)
    regdumpdir =  outputdir/ "{0}.reg.hextext".format(name)
    asmdumpdir =  outputdir/ "{0}.assembly.txt".format(name)
    complierdir = tooldir / compiler


    command_file = [str(complierdir), str(namepath)]
    if options.compiler == "mars":
        pre_command = list(command_file)
        pre_command.append("nc")
        pre_command.insert(0,"java -jar")

        command = list(pre_command)
        command.append('a' if options.aseembly_only else '-1')
        # dump text segment
        command.extend(['dump',options.range, 'BEAddrBinary' if options.addr_bin else 'BEBinary', str(textdumpdir)])
        # dump register
        command.extend(['dump', 'reg', 'all', str(regdumpdir)])
        # dump assembly
        if options.dump_disa:
            command.extend(['dump', 'as', 'all', str(asmdumpdir)])
        cmd_str = ' '.join(command)
        print(cmd_str)
        os.system(cmd_str)

        if options.dump_data:
            pre_command.extend(['dump','.data','BEBinary',str(datadumpdir)])
            os.system(' '.join(pre_command))

get_mips_compile_cmd(options)

