
# compatibility
## tech
* rtype itype core instruction set
* 5 stage pipeline
* 5 external interrupt (1 hardware interrupt were connected to count)
* text segmment 0x00400000
* data segement 0x10010000
* ktext segement 0x80000000
* kdata segement 0x90000000
* compatible  interrupt mode
* synthesizable
## notice
* no cache
* no fpu
* slow mul and div(the most easy method)
## instructions
### main

|opcode |000    |001   |010  |011  |100     |101  |110  |111     |
|:-----:|:-----:|:----:|:---:|:---:|:------:|:---:|:---:|:------:|
|000    |`SPECIAL`|`REGIMM`|J|JAL|BEQ  |BNE     |BLEZ |BGTZ |        |
|001    |ADDI   |ADDIU |SLTI |SLTIU|ANDI    |ORI  |XORI |LUI     |
|010    |`COP0`|~~COP1~~|~~COP2~~|~~COP1X~~|~~BEQL~~|~~BNEL~~|~~BLEZL~~|~~BGTZL~~|
|011    |       |      |     |     |`SPECIAL2`|~~JALX~~|~~MSA~~|`SPECIAL3`|
|100    |LB     |LH    |LWL  |LW   |LBU  |LHU     |LWR  |     |  
|101    |SB     |SH    |SWL  |SW   |     |        |SWR  |~~CACHE~~|
|110    |LL     |~~LWC1~~  |~~LWC2~~ |~~PREF~~ |       |~~LDC1~~ |~~LDC2~~ |        |
|111    |SC     |~~SWC1~~  |~~SWC2~~ |     |        |~~SDC1~~ |~~SDC2~~ |        |   
### special(rtype)
funct|000|001|010|011|100|101|110|111
|:-----:|:-----:|:----:|:---:|:---:|:------:|:---:|:---:|:------:|
|000|SLL|~~`MOVCI`~~|`SRL`|SRA|SLLV||`SRLV`|SRAV|
|001|JR|JALR|MOVZ|MOVN|SYSCALL|BREAK||~~SYNC~~|
|010|MFHI|MTHI|MFLO|MTLO|||||
|011|MULT|MULTU|DIV|DIVU|||||
|100|ADD|ADDU|SUB|SUBU|AND|OR|XOR|NOR|
|101|||SLT|SLTU|||||
|110|TGE|TGEU|TLT|TLTU|TEQ||TNE||
|111|||||||||
> * SRL(bit 21)
>   
> |0   |1|
> |:-----:|:-----:|
> |SRL      |ROTR |
> * SRLV(bit 6)
> 
> |0   |  1|
> |:-----:|:-----:|
> |SRLV      |ROTRV |

### REGIMM
|rt      |000|001|010|011|100|101|110|111|
|:-----:|:-----:|:----:|:---:|:---:|:------:|:---:|:---:|:------:|
|00|BLTZ|BGEZ|~~BLTZL~~|~~BGEZL~~|||||
|01|TGEI|TGEIU|TLTI|TLTIU|TEQI||TNEI||
|10|BLTZAL|BGEZAL|~~BLTZALL~~|~~BGEZALL~~|||||
|11||||||||~~SYNCI~~|
### SPECIAL2
|funct  |000|001|010|011|100|101|110|111|
|:-----:|:-----:|:----:|:---:|:---:|:------:|:---:|:---:|:------:|
|000|MADD|MADDU|MUL||MSUB|MSUBU|||
|001|||||||||
|010|||||||||
|011|||||||||
|100|CLZ|CLO|||||||
|101|||||||||
|110|||||||||
|111||||||||~~SDBBP~~|

### SPECIAL3
|SPECIAL3|||||||||
|:-----:|:-----:|:----:|:---:|:---:|:------:|:---:|:---:|:------:|
|funct|000|001|010|011|100|101|110|111|
|000|EXT||||INS||||
|001|||||||||
|010|||||||||
|011|||||||||
|100|BSHFL||||||||
|101|||||||||
|110|||||||||
|111||||~~RDHWR~~|||||

> * BSHFL
> 
> |sa |000|001|010|011|100|101|110|111|
> |:-----:|:-----:|:----:|:---:|:---:|:------:|:---:|:---:|:------:|
> |00|||WSBH||||||
> |01|||||||||
> |10|SEB||||||||
> |11|SEH||||||||

### COP0								
rs|000|001|010|011|100|101|110|111
|:-----:|:-----:|:----:|:---:|:---:|:------:|:---:|:---:|:------:|
|00|MFC0||||MTC0||||
|01|||~~RDPGPR~~|`MFMC0`|||~~WRPGPR~~||
|10|`C0`|`C0`|`C0`|`C0`|`C0`|`C0`|`C0`|`C0`|
|11|`C0`|`C0`|`C0`|`C0`|`C0`|`C0`|`C0`|`C0`|
> * C0
> 
>|funct|000|001|010|011|100|101|110|111|
>|:-----:|:-----:|:----:|:---:|:---:|:------:|:---:|:---:|:------:|
>|000||~~TLBR~~|~~TLBWI~~||||~~TLBWR~~||
>|001|~~TLBP~~||||||||
>|010|||||||||
>|011|ERET|||||||~~DERET~~|
>|100|~~WAIT~~||||||||
>|101|||||||||
>|110|||||||||
>|111|||||||||
>
> * MFMC0
>
## COP0 Register
#### BadVaddr(8,0)
Yes
#### Count(9,0)
Yes
#### Compare(11,0)
Yes
#### Status(12,0)
CU3..CU0|RP|FR|RE|MX|PX|BEV|TS|SR|NMI|0|Impl|IM7..IM2|IM1..IM0|KX|SX|UX|UM|R0|ERL|EXL|IE|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
COP0 only||||||Y||||||Y|Y||||Y||Y|Y|Y|


#### Cause(13,0)

|BD|TI|CE|DC|PCI|0|IV|WP|0|IP7..IP2|IP1..IP0|0|Exc Code|0|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|Y||COP0 only||||Y|||Y|Y|0|Y||
#### EPC(14,0)
Yes
#### EBase(15,1)

|1|0|Exception Base|0|0|CPUNum|
|:-:|:-:|:-:|:-:|:-:|:-:|
|||Y||||
#### LLAddr(17,0)
Yes
#### ErrorEPC(30,0)
Yes


## Exception
* INT
* AdEL
  * unalign load\fetch
  * load kernel segment in user mode
* AdEL
  * unalign store
  * store kernel segment in user mode
* Syscall
* Break Point
* Reserved Instruction
* Cop Unusable
* Trap
* Overflow