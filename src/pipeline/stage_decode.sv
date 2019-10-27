`ifndef STAGE_DECODE__
`define STAGE_DECODE__

`include "src/pipeline/pipeline_interface.sv"
`include "src/pipeline/decoder/main_decoder.sv"
`include "src/common/encode/main_opcode.sv"
`include "src/memory/register_file.sv"
`include "src/memory/cop0/register_cop0.sv"
`include "src/pipeline/forward/main_forwarder.sv"

module stage_decode(pipeline_interface.port pif,input forward_info_t forward);
    
    signals::unpack_t unpack;
    signals::control_t ctl;
    logic [4:0] dest_reg;
    logic [31:0] dest_reg_data,dest_cop0_data;
    logic [31:0] rs_data,rt_data,cop0_data;
    logic [31:0]  hi_reg, lo_reg;
    logic [4:0] dest_cop0_rd;
    logic [2:0]dest_cop0_sel;
    cop0_info::cop0_exc_data_t cop0_excdata;
    cop0_info::cop0_excreg_t cop0_excreg;
    logic write_reg,write_cop0;
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

     register_cop0  unit_cop0(
         .clk(pif.clk), .reset(pif.reset),  .we(write_cop0),
      .write_rd(dest_cop0_rd), .write_sel(dest_cop0_sel),.din(dest_cop0_data), 
      .read_rd(unpack.rd),   .read_sel(unpack.sel), .dout(cop0_data),
      //------------------exception control ----------------------
      .excdata(cop0_excdata),
      //---------- output
      .excreg(cop0_excreg));

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


    
    assign p_out.pcjump = 
        {p_out.pcadd4[31:28],
         p_out.instruction[25:0],
          2'b00};

    assign dest_reg =      pif.signal_in.dest_reg;
    assign dest_reg_data = pif.signal_in.dest_reg_data;
    assign write_reg  =    pif.signal_in.control.write_reg;

    assign dest_cop0_rd  =  pif.signal_in.dest_cop0_rd;
    assign dest_cop0_sel =  pif.signal_in.dest_cop0_sel;
    assign dest_cop0_data = pif.signal_in.dest_cop0_data;
    assign write_cop0    =  pif.signal_in.control.write_cop0;
    // assign cop0_excctl   =  pif.signal_in.control.cop0_excctl;
    assign p_out.dest_cop0_sel = unpack.sel;
    assign p_out.dest_cop0_rd  = unpack.rd;
    always_comb begin
        //-----------------------------------------------------
        /*      DONT. CHANGE. SEQENCE. */
        p_out.rs = rs_data; p_out.rt = rt_data;
        p_out.hi = hi_reg;  p_out.lo = lo_reg;
        p_out.cop0 = cop0_data;
        p_out.cop0excreg = cop0_excreg;
        /*      DONT. CHANGE. SEQENCE. */
        process_forward_data(p_out, forward);
        //-----------------------------------------------------
        p_out.instruction = reconnect.signal_out.instruction;
        p_out.control = ctl;
        p_out.pcsub4 =  reconnect.signal_out.pcsub4;
        p_out.pc =      reconnect.signal_out.pc;
        p_out.pcadd4 =  reconnect.signal_out.pcadd4;
        p_out.pcadd8 =  reconnect.signal_out.pcadd8;

    end
endmodule
`endif