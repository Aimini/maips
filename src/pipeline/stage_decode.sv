`ifndef STAGE_DECODE__
`define STAGE_DECODE__

`include "src/pipeline/pipeline_interface.sv"
`include "src/pipeline/decoder/main_decoder.sv"
`include "src/common/encode/main_opcode.sv"
`include "src/memory/register_file.sv"
`include "src/pipeline/forward/main_forwarder.sv"

module stage_decode(pipeline_interface.port pif,input forward_info_t forward);

    signals::unpack_t unpack;
    signals::control_t ctl;
    logic [4:0] dest_reg;
    logic [31:0] dest_reg_data;
    logic [31:0] rs,rt;
    logic write_reg;
    pipeline_interface reconnect(.clk(pif.clk),.reset(pif.reset));;

    pipeline_base unit_pb(reconnect);

    main_decoder uint_decoder(pif.signal_out.instruction, ctl);

    extract_instruction uint_ei(pif.signal_out.instruction, unpack);
    
    register_file #(.out(2), .addr(5), .width(32))
     unit_rf(.clk(pif.clk), .reset(pif.reset),
     .we(write_reg), .waddr(dest_reg), .din(dest_reg_data),
     .raddr('{unpack.rs,  unpack.rt}),
     .dout('{rs,rt}));

    always @(posedge pif.clk) begin
        $display("decode [opcode:%6b, rs:%2d, rt:%2d, rd:%2d]",unpack.opcode, unpack.rs, unpack.rt, unpack.rd);
    end

    always_comb begin
        reconnect.signal_in = pif.signal_in;
        reconnect.nullify = pif.nullify;
        reconnect.stall = pif.stall;
        
        pif.signal_out.rs = forward.forward_rs ? forward.rs : rs;
        pif.signal_out.rt = forward.forward_rt ? forward.rt : rt;
        pif.signal_out.control = ctl;
        
        pif.signal_out.pc = reconnect.signal_out.pc;
        pif.signal_out.pcadd4 = reconnect.signal_out.pcadd4;
        pif.signal_out.instruction = reconnect.signal_out.instruction;

        dest_reg = pif.signal_in.dest_reg;
        dest_reg_data = pif.signal_in.dest_reg_data;
        write_reg  = pif.signal_in.control.write_reg;
    end

endmodule
`endif