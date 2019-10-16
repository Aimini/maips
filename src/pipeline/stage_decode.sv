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
    logic [31:0] rs_data,rt_data;
    logic [31:0]  hi_reg, lo_reg;
    logic write_reg;
    pipeline_signal_t p_out;

    pipeline_interface reconnect(.clk(pif.clk),.reset(pif.reset));

    pipeline_base unit_pb(.pif(reconnect),.nullify_instruction('1));

    main_decoder unit_decoder(pif.signal_out.instruction, ctl);

    extract_instruction unit_ei(pif.signal_out.instruction, unpack);
    
    register_file #(.out(2), .addr(5), .width(32))
     unit_rf(.clk(pif.clk), .reset(pif.reset),
     .we(write_reg), .waddr(dest_reg), .din(dest_reg_data),
     .raddr('{unpack.rs,  unpack.rt}),
     .dout('{rs_data,rt_data}));

    always @(posedge pif.clk) begin
       /* $display("decode [opcode:%6b, rs:%2d, rt:%2d, rd:%2d]",unpack.opcode, unpack.rs, unpack.rt, unpack.rd);*/
       if(pif.reset) begin
           lo_reg <= '0;
           hi_reg <= '0;
       end else begin
        if(pif.signal_in.control.write_lo)
            lo_reg <= pif.signal_in.dest_lo_data;
        if(pif.signal_in.control.write_hi)
            hi_reg <= pif.signal_in.dest_hi_data;
       end
    end

    assign reconnect.signal_in = pif.signal_in;
    assign reconnect.nullify = pif.nullify;
    assign reconnect.stall = pif.stall;
    assign reconnect.bubble = pif.bubble;

    assign pif.signal_out = p_out;

    assign p_out.rs = forward.rs.f ? forward.rs.data : rs_data;
    assign p_out.rt = forward.rt.f ? forward.rt.data : rt_data;
    assign p_out.control = ctl;

    assign p_out.pc =     reconnect.signal_out.pc;
    assign p_out.pcadd4 = reconnect.signal_out.pcadd4;

    assign p_out.pcjump = 
        {p_out.pcadd4[31:28],
         p_out.instruction[25:0],
          2'b00};

    assign p_out.instruction = reconnect.signal_out.instruction;
        
    assign p_out.hi = forward.hi.f ? forward.hi.data : hi_reg;
    assign p_out.lo = forward.lo.f ? forward.lo.data : lo_reg;

    assign dest_reg =      pif.signal_in.dest_reg;
    assign dest_reg_data = pif.signal_in.dest_reg_data;
    assign write_reg  =    pif.signal_in.control.write_reg;

endmodule
`endif