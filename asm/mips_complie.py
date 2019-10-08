#
#comvert mips asm to logisim bin code format
#
import os,sys


if len(sys.argv) > 0:
    filename = sys.argv[1]
    hextext_file = "java -jar Mars4_5.jar " \
    " $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15 " \
    " $16 $17 $18 $19 $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $30 $31 " \
    " dump .text HexText {0}.hextext {0}".format(filename)
    os.system(hextext_file)
with open("{0}.hextext".format(filename),mode='r+') as f:
    content = f.read();
    f.seek(0)
    # f.write('v2.0 raw\n')
    f.write(content)



