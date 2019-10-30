    
`ifndef ADDRESS_ERROR_CHECKER__
`define ADDRESS_ERROR_CHECKER__
`include "src/common/selector.sv"
/*
     check address error exception
*/
module address_error_checker( 
    input selector::mem_read_type read_mode,
    input selector::mem_write_type write_mode,
    input logic[31:0] addr,pc,
    input logic in_kernel_mode,read_mem,write_mem,
    output logic read_error,store_error);


    logic access_kernel,
    unalign_word_read,     unalign_word_write,
    unalign_half_word_read,unalign_half_word_write,
    unalign_pc;
    logic[1:0] byte_index;

    assign byte_index = addr[1:0];

    assign access_kernel = (~in_kernel_mode & addr[31]);

    assign unalign_word_read =  (read_mode  === selector::MEM_READ_WORD) & (|addr[1:0]);
    assign unalign_word_write = (write_mode === selector::MEM_WRITE_WORD) & (|addr[1:0]);


    assign unalign_half_word_read = (read_mode  === selector::MEM_READ_HALF |
      read_mode  === selector::MEM_READ_UNSIGN_HALF)  & byte_index[0];
    assign unalign_half_word_write = (write_mode === selector::MEM_WRITE_HALF) & byte_index[0];
    
    assign unalign_pc = |(pc[1:0]);



    assign read_error  = read_mem  & (unalign_word_read | unalign_half_word_read  | access_kernel) | unalign_pc;
    assign store_error = write_mem & (unalign_word_write| unalign_half_word_write | access_kernel);
endmodule

`endif
