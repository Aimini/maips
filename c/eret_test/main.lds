 SECTIONS
 {
    . = 0x80000000;
    .text  : { *(.text)  *(.text.*)  }
    . = 0x90000000;
    .data : { 
      _gp = ABSOLUTE(.) + 0x8000;
      _gp_lo  = _gp & 0x0000FFFF;
      _gp_hi  = (_gp >> 16) & 0x0000FFFF;
      *(.sdata) *(.sdata.*)
      *(.scommon) *(.scommon.*)
      *(.bss)  *(.bss.*)
      *(.sbss) *(.sbss.*)
      *(.rodata) *(.rodata.*)
      *(.data)
    }
    /*.bss : {
      *(.bss)
    }
    .sbss : {
      *(.sbss)
    }
    .rodata : {
      *(.rodata)
    }
    .data :{
      *(.data)
    }*/
 }
