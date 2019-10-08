`ifndef MAIN_FORWARD__
`define MAIN_FORWARD__


`include "src/common/util.sv"

typedef struct {
    logic forward_rs,forward_rt;
    logic[31:0]rt,rs;
} forward_info_t;
/*
*/

module main_forwarder(
input pipeline_signal_t ps_decode,ps_execute,
ps_memory,ps_write_back,
output forward_info_t decode_forward_info,
execute_forward_info
  );

  // fowrad_info_t memory_to_execute;
  // fowrad_info_t write_back_to_execute;
  // fowrad_info_t write_back_to_decode;

  // single_forwarder unit_memory_to_execute_forwarder
  // (ps_memory,ps_execute,memory_to_execute);

  // single_forwarder unit_write_back_to_execute_forwarder
  // (ps_write_back,ps_execute,memory_to_execute);

  // single_forwarder unit_write_back_to_decode_forwarder
  // (ps_write_back,ps_decode,write_back_to_decode);

    signals::unpack_t execute_unpack,decode_unpack;
    extract_instruction execute_ei(.instruction(ps_execute.instruction),
    .ei(execute_unpack));

    extract_instruction decode_ei(.instruction(ps_decode.instruction),
    .ei(decode_unpack));

    always_comb begin
        execute_forward_info.forward_rs = '0;
        execute_forward_info.rs = 'x;  
        execute_forward_info.forward_rt = '0;
        execute_forward_info.rt =  'x;
        if(ps_memory.control.write_reg & ps_memory.dest_reg != 0) begin
            if(execute_unpack.rs == ps_memory.dest_reg) begin
                execute_forward_info.forward_rs = '1;
                execute_forward_info.rs = ps_memory.dest_reg_data;
            end

            if(execute_unpack.rt == ps_memory.dest_reg) begin
                execute_forward_info.forward_rt = '1;
                execute_forward_info.rt = ps_memory.dest_reg_data;
            end 
        end else begin
            if(ps_write_back.control.write_reg  & ps_write_back.dest_reg != 0) begin
                if(execute_unpack.rs == ps_write_back.dest_reg) begin
                    execute_forward_info.forward_rs = '1;
                    execute_forward_info.rs = ps_write_back.dest_reg_data;
                end

                if(execute_unpack.rt == ps_write_back.dest_reg) begin
                    execute_forward_info.forward_rt = '1;
                    execute_forward_info.rt = ps_write_back.dest_reg_data;
                end
            end
        end
        decode_forward_info.forward_rs = '0;
        decode_forward_info.rs = 'x;
        decode_forward_info.forward_rt = '0;
        decode_forward_info.rt = 'x;
        if(ps_write_back.control.write_reg  & ps_write_back.dest_reg != 0) begin
            if(decode_unpack.rs == ps_write_back.dest_reg) begin
                decode_forward_info.forward_rs = '1;
                decode_forward_info.rs = ps_write_back.dest_reg_data;
            end

            if(decode_unpack.rt == ps_write_back.dest_reg) begin
                decode_forward_info.forward_rt = '1;
                decode_forward_info.rt = ps_write_back.dest_reg_data;
            end 
        end
    end
  
endmodule

`endif
