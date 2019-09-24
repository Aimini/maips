`ifndef  MODULE_STAGE_MEMORY__
`define  MODULE_STAGE_MEMORY__ 

`include "common/selector.sv"

import selector::mem_read_type;
module stage_memory #(parameter N = 32)
(
    /* control signal*/
    input selector::mem_read_type read_mode,
    input selector::mem_write_type write_mode,
    input logic write_mem,
    /* interact with memory */
    memory_interface mif,
    /* pipline output to next stage*/
    input logic[N-1:0] pipline_data_in,
    input logic[N-1:0] pipline_addr_in,
    output logic[N-1:0] pipline_data_out);

    logic [1:0]   byte_index;
    logic [N-3:0] word_addr;
    logic [7:0]  abyte;
    logic [15:0] aword;

    assign mif.write = write_mem;
    assign byte_index = pipline_addr_in[1:0];
    assign word_addr  = pipline_addr_in[N - 1:2];

    always_comb begin
        case(read_mode)
            selector::MEM_READ_BYTE:
                if(|byte_index[1:0]) begin 
                    pipline_data_out = 'x;
                end else begin
                    abyte = mif.dout[8*byte_index +: 8];
                    pipline_data_out = {{N-8{abyte[7]}},abyte};
                end
            selector::MEM_READ_UNSIGN_HALF,selector::MEM_READ_HALF:
                if(byte_index[0]) begin 
                    pipline_data_out = 'x;
                end else begin
                    aword = mif.dout[16*byte_index[1] +: 16];
                    if(read_mode === selector::MEM_READ_UNSIGN_HALF)
                        pipline_data_out = {{N-16{1'b0}},aword};
                    else
                        pipline_data_out = {{N-16{aword[15]}},aword};
                end

            selector::MEM_READ_WORD:
                 pipline_data_out = mif.dout;
            
            selector::MEM_READ_LWL:
                 pipline_data_out = pipline_data_in & ({N{1'b1}} >> (byte_index + 1)*8) | (mif.dout << (3 - byte_index)*8);

            selector::MEM_READ_LWR:
                pipline_data_out = pipline_data_in & ({N{1'b1}} << (N - byte_index*8)) | (mif.dout >> byte_index*8);

            default:
                pipline_data_out = 'x;
        endcase

        case(write_mode)
           selector:: MEM_WRITE_BYTE: begin
                mif.mask = 4'b0001 << byte_index;
                mif.din  = pipline_data_in;
           end
            selector::MEM_WRITE_HALF: begin
                mif.mask = 4'b0011 << byte_index[1];
                mif.din  = pipline_data_in;
            end
            selector::MEM_WRITE_WORD: begin
                mif.mask = 4'b1111;
                mif.din  = pipline_data_in;
            end
            selector::MEM_WRITE_SWL:  begin
                mif.mask = ~(4'b1111 <<(byte_index + 1));
                mif.din  = pipline_data_in >> 8*(3 - byte_index);
            end
            selector::MEM_WRITE_SWR:  begin
                mif.mask = 4'b1111 <<(byte_index);
                mif.din  = pipline_data_in << 8*(byte_index);
            end
            default: begin
                mif.mask = 'x;
                mif.din  = 'x;
            end
        endcase
    end
endmodule

`endif