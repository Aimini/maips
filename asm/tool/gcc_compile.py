import os
import sys
from optparse import OptionParser
parser = OptionParser()
parser.add_option("-o", "--output", action="store",
                  dest="output",
                  default=False,
                  help="indicate output file")
(options, args) = parser.parse_args()
outfilename = options.output

passed = sys.argv[1:]
cmd = ["mips-mti-elf-g++",
       "-EL -Wall",        # little endianness
       "-e __start",  # entry name,
       "-march=mips32r2", "-mno-micromips -mabi=32",
       "-msoft-float", "-fno-delayed-branch",
       "-nostartfiles", "-nostdlib",
       "-mno-check-zero-division -O0",
       ' '.join(passed),
       "-Wl,--gc-sections,-G64,-T,tool\\main.lds",
       "& mips-mti-elf-objdump -S -D {}".format(outfilename),
       f"> {outfilename}.disa.txt"]



dump_text = f"mips-mti-elf-objcopy {outfilename} --only-section=.text -O binary {outfilename}.text.bin"
dump_data = f"mips-mti-elf-objcopy {outfilename} --only-section=.data -O binary {outfilename}.data.bin"
print(' '.join(cmd))
os.system(' '.join(cmd))
os.system(dump_text)
os.system(dump_data)
