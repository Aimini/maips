import os
import sys
from optparse import OptionParser


cmd = ["mips-mti-elf-g++",
       "-EL -g -Wall",        # little endianness
       "-e __start",  # entry name
       R"-I .\..\include\ -I D:\mips-mti-elf\tools\lib\gcc\mips-mti-elf\7.4.0\include",
       "-flto",
       "-fschedule-insns -fschedule-insns2",
       "-march=mips32r2", "-mno-micromips -mabi=32",
       "-msoft-float", #"-fno-delayed-branch",
       "-nostartfiles", #"-nostdlib",
       "-fdata-sections", "-ffunction-sections",
       "-mno-check-zero-division -O1",
       R".\..\include\printf-master\printf.c",
       R' start.s main.c -o ..\temp\main',
       "-Wl,--gc-sections,-G64,-T,main.lds",
       R"& mips-mti-elf-objdump -S -d ..\temp\main",
       R"> ..\temp\main.disa.txt"]




dump_text = R"mips-mti-elf-objcopy ..\temp\main --only-section=.text -O binary ..\temp\kernel.text.bin"
dump_data = R"mips-mti-elf-objcopy ..\temp\main --only-section=.data -O binary ..\temp\kernel.data.bin"
print(' '.join(cmd))
os.system(' '.join(cmd))
os.system(dump_text)
os.system(dump_data)
