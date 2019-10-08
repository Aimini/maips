`ifndef  MODULE_STAGE_MEMORY_LOAD_STORE__
`define  MODULE_STAGE_MEMORY_LOAD_STORE__ 

`include "src/common/selector.sv"
`include "src/memory/memory_interface.sv"


module stage_memory_load_store #(parameter N = 32)
(
    /* control signal*/
    input selector::mem_read_type read_mode,
    input selector::mem_write_type write_mode,
    input logic write_mem,
    /* interact with memory */
    memory_interface.controller mif,
    /* pipeline output to next stage*/
    input logic[N-1:0] data_in,
    input logic[N-1:0] addr_in,
    output logic[N-1:0] data_out,
    output logic address_error);

    logic [1:0]   byte_index;
    logic [N-3:0] word_addr;
    logic [7:0]  abyte;
    logic [15:0] aword;

    assign mif.write = write_mem;
    assign byte_index = addr_in[1:0];
    assign word_addr  = addr_in[N - 1:2];

    assign address_error =  
    (read_mode  === selector::MEM_READ_HALF |
      read_mode  === selector::MEM_READ_UNSIGN_HALF |
      write_mode === selector::MEM_WRITE_HALF) & byte_index[0] |
     (read_mode  === selector::MEM_READ_WORD | write_mode === selector::MEM_WRITE_WORD) & (|byte_index);

    always_comb begin
        case(read_mode)
            selector::MEM_READ_UNSIGN_BYTE,selector::MEM_READ_BYTE: begin
                abyte = mif.dout[8*byte_index +: 8];
                if(read_mode === selector::MEM_READ_UNSIGN_BYTE)
                        data_out = {{N-8{1'b0}},abyte};
                    else
                        data_out = {{N-8{abyte[7]}},abyte};
            end

            selector::MEM_READ_UNSIGN_HALF,selector::MEM_READ_HALF:
                if(byte_index[0]) begin 
                    data_out = 'x;
                end else begin
                    aword = mif.dout[16*byte_index[1] +: 16];
                    if(read_mode === selector::MEM_READ_UNSIGN_HALF)
                        data_out = {{N-16{1'b0}},aword};
                    else
                        data_out = {{N-16{aword[15]}},aword};
                end

            selector::MEM_READ_WORD: 
                if(|byte_index[1:0]) begin 
                    data_out = 'x;
                end else begin
                    data_out = mif.dout;
                end
            
            selector::MEM_READ_LWL:
                 data_out = data_in & ({N{1'b1}} >> (byte_index + 1)*8) | (mif.dout << (3 - byte_index)*8);

            selector::MEM_READ_LWR:
                data_out = data_in & ({N{1'b1}} << (N - byte_index*8)) | (mif.dout >> byte_index*8);

            default:
                data_out = 'x;
        endcase

        case(write_mode)
           selector:: MEM_WRITE_BYTE: begin
                mif.mask = 4'b0001 << byte_index;
                mif.din  = data_in;
           end
            selector::MEM_WRITE_HALF: begin
                mif.mask = 4'b0011 << (byte_index[1] << 1);
                mif.din  = data_in;
            end
            selector::MEM_WRITE_WORD: begin
                mif.mask = 4'b1111;
                mif.din  = data_in;
            end
            selector::MEM_WRITE_SWL:  begin
                mif.mask = ~(4'b1111 <<(byte_index + 1));
                mif.din  = data_in >> 8*(3 - byte_index);
            end
            selector::MEM_WRITE_SWR:  begin
                mif.mask = 4'b1111 <<(byte_index);
                mif.din  = data_in << 8*(byte_index);
            end
            default: begin
                mif.mask = 'x;
                mif.din  = 'x;
            end
        endcase
    end
endmodule

`endif