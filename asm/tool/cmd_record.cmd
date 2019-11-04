tool\mips_compile.py manual_asm\sw_dbg.asm

generate\lui.py
generate\ori.py
generate\sll.py

generate\addu.py 
generate\j_jal.py  & tool\mips_compile.py j.asm --special & tool\mips_compile.py jal.asm --special
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

generate\slt_sltu.py slt
generate\slt_sltu.py sltu

generate\bltz.py
generate\bltzal.py
generate\bgez.py
generate\bgezal.py

generate\sb_sh_sw.py sb
generate\sb_sh_sw.py sh
generate\sb_sh_sw.py sw
generate\lbu_lhu.py lbu
generate\lbu_lhu.py lbu
generate\lwr_swr.py
generate\lwl_swl.py
generate\ins_ext.py ext
generate\ins_ext.py ins
generate\seb_seh.py seb
generate\seb_seh.py seh
generate\wsbh.py seh


geneate_gcc\syscall.py syscall
geneate_gcc\syscall.py break
geneate_gcc\syscall.py tge
geneate_gcc\syscall.py tgeu
geneate_gcc\syscall.py tlt
geneate_gcc\syscall.py tltu
geneate_gcc\syscall.py teq
geneate_gcc\syscall.py tne
geneate_gcc\syscall.py tgei
geneate_gcc\syscall.py tgeiu
geneate_gcc\syscall.py tlti
geneate_gcc\syscall.py tltiu
geneate_gcc\syscall.py teqi
geneate_gcc\syscall.py tnei
geneate_gcc\syscall.py ov_add
geneate_gcc\syscall.py ov_sub
geneate_gcc\syscall.py ov_addi
geneate_gcc\address.py unalign_load
geneate_gcc\address.py unalign_store
geneate_gcc\address.py unalign_pc
geneate_gcc\syscall.py reserved
geneate_gcc\soft_interrupt.py
geneate_gcc\di_ei.py
geneate_gcc\ll_sc.py