import os
import sys

outfilename = "kernel"

cmd = ["mips-mti-elf-g++",
       "-EL -g -Wall",        # little endianness
       "-e __start",  # entry name
       R"-I .  -I D:\mips-mti-elf\tools\lib\gcc\mips-mti-elf\7.4.0\include",
       "-flto",
       "-fschedule-insns", "-fschedule-insns2",
       "-march=mips32r2", "-mno-micromips -mabi=32",
       "-msoft-float", 
       "-nostartfiles", #"-nostdlib",
       "-fdata-sections", "-ffunction-sections",
       "-O3","-mno-gpopt","-G0","-mno-check-zero-division",
       R"crt0.s main.cpp printf.c",
       f"-o {outfilename}",
       "-Wl,--gc-sections,-G0,-T,kernel.lds",
       f"& mips-mti-elf-objdump -S -d {outfilename}",
       f"> {outfilename}.disa.txt"]




dump_text = f"mips-mti-elf-objcopy {outfilename} --only-section=.text --reverse-bytes=4 -O binary {outfilename}.text.bin"
dump_data = f"mips-mti-elf-objcopy {outfilename} --only-section=.data --reverse-bytes=4 -O binary {outfilename}.data.bin"
print(' '.join(cmd))
os.system(' '.join(cmd))
os.system(dump_text)
os.system(dump_data)
