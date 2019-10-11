import sys
with open("lui.asm","w") as f,open("temp/lui.reg.hextext","w") as reg:
    f.write(".text\n")
    for x in range(32):
        i = x%16
        base = 5
        rotate = (base << i)&0xFFFF | base >> (16 - i)
        reg.write("{:0>4x}0000 \n".format(rotate))
        f.write("    lui ${},0x{:0>4x} \n".format(x,rotate))

    f.write("    lui $gp,0xffff \n")
    f.write("    sw  $0, 4($gp) \n") # arg[1] = 0, check all
    f.write("    lui $sp,0x0001 \n") # arg[0] = 0x00010000,check register file
    f.write("    sw  $sp,0($gp) \n")
    f.write("    sw  $0, 0($gp) \n")# exit

with open("temp/lui.reg.hextext","r+") as f:
    all = f.readlines()
    f.seek(0)
    for idx,ele in enumerate(all):
        if idx == 0: #$0
            f.write("00000000\n")
        elif idx == 28: #$gp
            f.write("FFFF0000\n")
        elif idx == 29: #$sp
            f.write("00010000\n")
        else:
            f.write(ele)