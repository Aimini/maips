`ifndef  MODULE_STAGE_MEMORY_LOAD_STORE__
`define  MODULE_STAGE_MEMORY_LOAD_STORE__ 

`include "src/common/selector.sv"
`include "src/memory/memory_interface.sv"


/*
    read_mode:
    write_mode: reigister_data: when you read data from memory, 
some instruction (lwr lwl)will reserve some original value in register
so you must pass it as argument
    mem_data_out: d ata from memory and will write to register
processed_data: the data that storage to register
    mem_data_In: the data storage to memory
addr: memory address
*/
module stage_memory_load_store #(parameter N = 32)
(
    input selector::mem_read_type read_mode,
    input selector::mem_write_type write_mode,
    input logic[31:0] register_data,mem_data_out,
    output logic[31:0] processed_data,mem_data_in,
    input logic[31:0] addr,
    output logic[3:0] byte_mask);

    logic [1:0]   byte_index;
    logic [N-3:0] word_addr;
    logic [7:0]  abyte;
    logic [15:0] aword;

    assign byte_index = addr[1:0];
    assign word_addr  = addr[N - 1:2];

    always_comb begin
        case(read_mode)
            selector::MEM_READ_UNSIGN_BYTE,selector::MEM_READ_BYTE: begin
                abyte = mem_data_out[8*byte_index +: 8];
                if(read_mode === selector::MEM_READ_UNSIGN_BYTE)
                        processed_data = {{N-8{1'b0}},abyte};
                    else
                        processed_data = {{N-8{abyte[7]}},abyte};
            end

            selector::MEM_READ_UNSIGN_HALF,selector::MEM_READ_HALF:
                if(byte_index[0]) begin 
                    processed_data = 'x;
                end else begin
                    aword = mem_data_out[16*byte_index[1] +: 16];
                    if(read_mode === selector::MEM_READ_UNSIGN_HALF)
                        processed_data = {{N-16{1'b0}},aword};
                    else
                        processed_data = {{N-16{aword[15]}},aword};
                end

            selector::MEM_READ_WORD: 
                if(|byte_index[1:0]) begin 
                    processed_data = 'x;
                end else begin
                    processed_data = mem_data_out;
                end
            
            selector::MEM_READ_LWL:
                 processed_data =
                  register_data & ({N{1'b1}} >> (byte_index + 1)*8)
                  | (mem_data_out << (3 - byte_index)*8);

            selector::MEM_READ_LWR:
                processed_data =
                 register_data & ({N{1'b1}} << (N - byte_index*8)) 
                  | (mem_data_out >> byte_index*8);

            default:
                processed_data = 'x;
        endcase

        case(write_mode)
           selector:: MEM_WRITE_BYTE: begin
                byte_mask = 4'b0001 << byte_index;
                mem_data_in  = register_data << 8*byte_index;
           end
            selector::MEM_WRITE_HALF: begin
                byte_mask = 4'b0011 << ({byte_index[1],1'b0});
                mem_data_in  = register_data << 8*(byte_index[1] << 1);
            end
            selector::MEM_WRITE_WORD: begin
                byte_mask = 4'b1111;
                mem_data_in  = register_data;
            end
            selector::MEM_WRITE_SWL:  begin
                byte_mask = ~(4'b1111 <<(byte_index + 1));
                mem_data_in = register_data >> 8*(3 - byte_index);
            end
            selector::MEM_WRITE_SWR:  begin
                byte_mask = 4'b1111 <<(byte_index);
                mem_data_in  = register_data << 8*(byte_index);
            end
            default: begin
                byte_mask = 'x;
                mem_data_in  = 'x;
            end
        endcase
    end
endmodule

`endif