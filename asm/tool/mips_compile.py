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
    tmpdir = pdir / "temp"
    run_by_mars = tmpdir / ("mars_" + name)
    dump_to_modelsim = tmpdir / ("modelsim_" + name)

    #pre_process(namepath, run_by_mars, dump_to_modelsim)

    hextextdir = tmpdir/ "{0}.hextext".format(name)
    regdumpdir = tmpdir/ "{0}.reg.hextext".format(name)
    special_dumpdir = tmpdir/ "{0}.spec.hextext".format(name)
    Mars_dir =  pdir / 'tool/Mars.jar'

    # runnig an watch result
    #just_run = 'java -jar {} $31 {}'.format(str(Mars_dir),str(run_by_mars))
    #os.system(just_run)

    # dump 
    use_special_dump = len(sys.argv)  > 2
    special_dump = ['java','-jar',str(Mars_dir),'-1','0x00400000-0x007FFFFC']
    normal_dump = ['java','-jar',str(Mars_dir),'-1', 'dump','.text','HexText',str(hextextdir)]
    dump_reg = ['dump','reg','all',str(regdumpdir)]
    # if use_special_dump:
    #     dump_cmd = special_dump
    # else:
    dump_cmd = normal_dump

    dump_cmd.append(str(namepath))
    dump_cmd.extend(dump_reg)
   # print(dump_cmd)
    f = open(special_dumpdir,mode='wb')
    p1 = subprocess.Popen(dump_cmd, stdin=subprocess.PIPE,stdout=f,stderr=f)
    # stdout,stderr=p1.communicate()
    # print(stderr.decode())
    p1.wait()
    f.close()

    wf = None
    with open(special_dumpdir,mode='r') as rf:
        for one in rf.readlines():
            if(re.search('error', one, re.IGNORECASE)):
                print(one,end='')
            
            if(use_special_dump):
                if wf is None:
                    wf = open(hextextdir,mode='w')
                if one.startswith("Mem[") and one.find('Invalid') == -1:
                    contents = one.split(']')[1].split()
                    for word in contents:
                        if len(word) > 0:
                            wf.write(word+'\n')

        



