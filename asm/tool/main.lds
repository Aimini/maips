 SECTIONS
 {
    . = 0x80000000;
    .text  ALIGN(0x10) : {
     *(.excetion_handler) *(.text)  *(.text.*)  }


    . = 0x90000000;

    .data ALIGN(0x10) : { 
      _gp = ABSOLUTE(.) + 0x8000;
      _gp_lo  = _gp & 0x0000FFFF;
      _gp_hi  = (_gp >> 16) & 0x0000FFFF;
      *(.sdata) *(.sdata.*)
      *(.scommon) *(.scommon.*)
      _bss_start = ABSOLUTE(.);
      *(.sbss) *(.sbss.*)
      *(.bss)  *(.bss.*)
      _bss_end = ABSOLUTE(.);
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
