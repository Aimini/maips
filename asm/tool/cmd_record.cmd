tool\mips_compile.py manual_asm\sw_dbg.asm
generate\lui.py & tool\mips_compile.py lui_1.asm & tool\mips_compile.py lui_2.asm 
generate\ori.py & tool\mips_compile.py ori_1.asm & tool\mips_compile.py ori_2.asm 
generate\sll.py & tool\mips_compile.py sll_1.asm & tool\mips_compile.py sll_2.asm 

generate\addu.py & tool\mips_compile.py addu.asm
:: generate\j_jal.py  & tool\mips_compile.py j.asm --special & tool\mips_compile.py jal.asm --special
generate\addiu.py & tool\mips_compile.py addiu.asm
generate\beq.py & tool\mips_compile.py beq.asm
generate\bne.py & tool\mips_compile.py bne.asm
generate\blez.py & tool\mips_compile.py blez.asm
generate\bgtz.py & tool\mips_compile.py bgtz.asm
generate\slti.py & tool\mips_compile.py slti.asm
generate\sltiu.py & tool\mips_compile.py sltiu.asm
generate\andi.py & tool\mips_compile.py andi_1.asm & tool\mips_compile.py andi_2.asm
generate\xori.py & tool\mips_compile.py xori_1.asm & tool\mips_compile.py xori_2.asm

tool\mips_compile.py manual_asm\sys_serial_test.asm
generate\mthi_mfhi.py & tool\mips_compile.py mthi_mfhi.asm
generate\mtlo_mflo.py & tool\mips_compile.py mtlo_mflo.asm
generate\multu.py & tool\mips_compile.py multu.asm
generate\divu.py & tool\mips_compile.py divu.asm
generate\mult.py & tool\mips_compile.py mult.asm
generate\mult.py & tool\mips_compile.py mult.asm
generate\div.py
generate\msubu.py