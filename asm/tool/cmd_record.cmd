tool\mips_compile.py manual_asm\sw_dbg.asm

generate\lui.py
generate\ori.py
generate\sll.py

generate\addu.py 
:: generate\j_jal.py  & tool\mips_compile.py j.asm --special & tool\mips_compile.py jal.asm --special
generate\addiu.py
generate\beq.py 
generate\bne.py 
generate\blez.py
generate\bgtz.py
generate\slti.py
generate\sltiu.py
generate\andi.py
generate\xori.py

tool\mips_compile.py manual_asm\sys_serial_test.asm
generate\mthi_mfhi.py
generate\mtlo_mflo.py
generate\multu.py
generate\divu.py
generate\mult.py
generate\div.py

generate\maddu.py
generate\msubu.py
generate\madd.py
generate\msub.py

generate\mul.py

generate\clz.py
generate\clo.py

generate\lw.py
generate\lh.py
generate\lb.py

tool\mips_compile.py manual_asm\print_string.asm

generate\jr.py
generate\jalr.py
generate\movn_movz.py
generate\srl_rotr_sra.py srl
generate\srl_rotr_sra.py rotr
generate\srl_rotr_sra.py sra
generate\sllv.py
generate\srlv_rotrv_srav.py srlv
generate\srlv_rotrv_srav.py rotrv
generate\srlv_rotrv_srav.py srav
generate\subu.py

generate\and.py
generate\or.py
generate\xor.py
generate\nor.py