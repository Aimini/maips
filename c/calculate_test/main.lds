 SECTIONS
 {
    . = 0x00400000;
    .text ALIGN(0x10) : { *(.text)  *(.text.*)  }
    . = 0x10010000;
    .data ALIGN(0x10) : { 
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
