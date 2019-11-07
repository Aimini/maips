 SECTIONS
 {
    . = 0x80000000;
    ENTRY(__start)
    .text  ALIGN(0x10) : { *(.text)  *(.text.*)  }


    . = 0x90000000;

    .data ALIGN(0x10) : { 
      _gp = ABSOLUTE(.) + 0x8000;
      _gp_lo  =  _gp & 0x0000FFFF;
      _gp_hi  = (_gp >> 16) & 0x0000FFFF;
      
      *(.sdata) *(.sdata.*)
      *(.scommon) *(.scommon.*);

       _bss_start = ABSOLUTE(.);
       _bss_start_lo  =  _bss_start & 0x0000FFFF;
       _bss_start_hi  = (_bss_start >> 16) & 0x0000FFFF;
      *(.sbss) *(.sbss.*)
      *(.bss)  *(.bss.*);
      _bss_end = ABSOLUTE(.);
      _bss_end_lo  =  _bss_end & 0x0000FFFF;
      _bss_end_hi  = (_bss_end >> 16) & 0x0000FFFF;

      *(.rodata) *(.rodata.*)
      *(.data)
    }
 }
