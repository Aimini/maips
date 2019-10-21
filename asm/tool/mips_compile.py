#
#comvert mips asm to logisim bin code format
#
import os,sys
import pathlib
import subprocess
import re

def pre_process(rfilename,mars_filename,sim_fliename):
    with open(rfilename,mode='r') as fr,\
         open(mars_filename ,mode='w') as mfw,\
         open(sim_fliename ,mode='w')  as sfw:
        find_my_sysall(fr.readlines(),mfw,sfw)

def find_my_sysall(lines,mwfp,swfp):
    state = 0
    # 0 normal , 1 find my_syscall 2, else,
    for one in lines:
        s =  one.strip()
        if state == 0 and s == "###--my_syscall":
            state = 1
        if state == 1:
            if s == "###--else":
                state = 2
            elif s == "###--end_syscall":
                state = 0
        if state == 2:
            if s == "###--end_syscall":
                state = 0

        if(state == 0):
            mwfp.write(one)
            swfp.write(one)
        elif(state == 1):
            swfp.write(one)
        elif(state == 2):
            mwfp.write(one)

    if(state != 0):
        print("warning: somthing wrong with your ###--my_syscall")

# dump_reg =  " $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15 " \
#     " $16 $17 $18 $19 $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $30 $31 " 

if len(sys.argv) > 1:
    namepath = pathlib.Path(sys.argv[1])
    name = namepath.name
    pdir = namepath.parent
    pdir = pathlib.Path('.')
    tooldir = pdir / "tool"
    tmpdir = pdir / "temp"
    run_by_mars = tmpdir / ("mars_" + name)
    dump_to_modelsim = tmpdir / ("modelsim_" + name)

    #pre_process(namepath, run_by_mars, dump_to_modelsim)

    hextextdir = tmpdir/ "{0}.hextext".format(name)
    datadumpdir = tmpdir/ "{0}.data.hextext".format(name)
    regdumpdir = tmpdir/ "{0}.reg.hextext".format(name)
    asmdumpdir = tmpdir/ "{0}.assembly.hextext".format(name)
    special_dumpdir = tmpdir/ "{0}.spec.hextext".format(name)
    Mars_dir = tooldir / 'Mars.jar'

    # dump 
    use_special_dump = len(sys.argv)  > 2
    command = ['java','-jar',str(Mars_dir),sys.argv[1],'-1']
    command_asm = ['java','-jar',str(Mars_dir),sys.argv[1],'a']
    dump_range = '0x00400000-0x0FFFFFFC'
    dump_text = '.text'
    dump_data = ['dump','.data','HexText',str(datadumpdir)]
    dump_reg = ['dump','reg','all',str(regdumpdir)]
    dump_asm = ['dump','as','all',str(asmdumpdir)]
    if use_special_dump:
        dump_segment = ['dump',dump_range,'HexText']
    else:
        dump_segment = ['dump',dump_text,'HexText']
        
    dump_segment.append(str(hextextdir))
    command.extend(dump_segment)
    command.extend(dump_reg)
    command.extend(dump_asm)
    command_asm.extend(dump_data)
    f = open(special_dumpdir,mode='wb')
    cmd_str = ' '.join(command)
    #print(cmd_str)
    os.system(cmd_str)
    os.system(' '.join(command_asm))
    # if no data to dump ,still create empty file
    with open(datadumpdir,"a") as f:
        pass

        



