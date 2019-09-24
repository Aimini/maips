//div: hi = a/b ,low = a %b
`ifndef MODULE_DIV_MUL__
`define MODULE_DIV_MUL__

module div_mul #(parameter N = 32)
   (input logic clk,reset,
      input logic mul,div,sign_unsign,
      input logic sub,add,
      input logic[N-1:0] a,b,
      output logic[N-1:0] hi,lo,waiting_result);

    localparam NN = $clog2(N);

    logic [N - 1:0] aa,reverse_aa,ab; // absolute a,b
    logic bs,as; // a ,b sgin
    logic initial_we; 
    logic op_bit; //operation bit,for each stage, op_bit = a31\a30.. or a0\a1\a2...

    logic [NN - 1:0] tick_count;
    
    logic [N - 1:0] thi,tlo; // temp hi,lo,storage multiply and division intermediate result;
    logic[N-1:0] srcA,srcB,alu_out;
    logic cin,cout,cout_reg;




    /************* lo and hi ***************/
    logic hi_we,lo_we;
    always_ff @(posedge clk,posedge reset) begin
        if(reset)  begin
            hi <= 0;
            lo <= 0;
        end else begin
            if(hi_we) hi = thi;
            if(lo_we) lo = lo_we;
        end


    end

    /*** process sign and unsign ***/
    always_ff @(posedge clk) begin
        if(initial_we) begin
            aa <= a[N - 1] & sign_unsign ? -a : a;
            ab <= b[N - 1] & sign_unsign ? -b : b;
            bs <= b[N - 1];
            as <= a[N - 1];
        end
    end
    always_comb begin
        reverse_aa = {<<{aa}};
        op_bit = mul ? aa[tick_count] : reverse_aa[tick_count];
    end


     /******* tick count *******/
     typedef enum logic[7:0] {TICK_ONE,TICK_RESET,TICK_NCARE} tick_funct;
     tick_funct tick_op;
     always_ff @(posedge clk) begin
      case(tick_op)
            TICK_ONE:
                tick_count <= tick_count + 1;
            TICK_RESET:
                tick_count <= 0;
          default:
                tick_count <= 'x;
      endcase
    end

    /******* temp hi ,temp lo *******/
    typedef enum logic[7:0] {THI_HOLD,THI_ALU,THI_PARTIAL_MUL,THI_PARTIAL_DIV,THI_ZERO,THI_NCARE = 'x} thi_src_t;
    typedef enum logic[7:0] {TLO_HOLD,TLO_SR_MUL,TLO_SL_DIV,TLO_ALU,TLO_NCARE = 'x} tlow_funct;
    thi_src_t thi_sel;
    tlow_funct tlo_op;
    always_ff @(posedge  clk) begin
        case (thi_sel)
            THI_HOLD            : thi <= thi;
            THI_ALU             : thi <= alu_out;
            THI_PARTIAL_MUL : thi <= {cout,alu_out[N - 1:1]};
            THI_PARTIAL_DIV     : thi <= {alu_out[N - 2:0],op_bit};
            THI_ZERO            : thi <= 0;
            default: thi <= 'x;
        endcase

        case(tlo_op)
            TLO_HOLD   : tlo <= tlo;
            TLO_SR_MUL : tlo <= {alu_out[0],tlo[N-1:1]};
            TLO_SL_DIV : tlo <= {alu_out[1],tlo[N-1:1],cout};
            TLO_ALU: tlo <= alu_out;
            default: tlo <= 'x;
        endcase
    end


    /********** alu ************/
    typedef enum logic[7:0]  {SRCA_ZERO,SRCA_THI,SRCA_HI,SRCA_LO,SRCA_NCARE = 'x} alu_srcA_t;
    typedef enum logic[7:0]  {SRCB_THI ,SRCB_TLO,SRCB_NTHI,SRCB_NTLO,SRCB_AB,SRCB_NAB,SRCB_OPAB,SRCB_NCARE = 'x} alu_srcB_t;
    typedef enum logic[7:0]  {CIN_ZERO,CIN_ONE,CIN_COUT,CIN_NCARE = 'x} alu_cin_t;
    alu_srcA_t srcA_select;
    alu_srcB_t srcB_select;
    alu_cin_t  cin_sel;

    always_ff @(posedge clk) begin
        cout_reg <= cout;
    end

    assign {cout,alu_out} = a + b + cin;
    always_comb begin
        case(srcA_select)
            SRCA_ZERO: srcA = 0;
            SRCA_THI : srcA = thi;
            SRCA_HI : srcA = hi;
            SRCA_LO : srcA = lo;
            default:srcA = 'x;
        endcase

        case(srcB_select)
            SRCB_THI : srcB = thi;
            SRCB_TLO : srcB = tlo;
            SRCB_NTHI: srcB = ~thi;
            SRCB_NTLO: srcB = ~tlo;
            SRCB_AB  : srcB = ab;
            SRCB_OPAB: srcB = ab & {N{op_bit}};
            default:srcB = 'x;
        endcase

        case (cin_sel)
            CIN_ZERO: cin = 0;
            CIN_ONE:  cin = 1;
            CIN_COUT: cin = cout_reg;
            default:  cin = 'x;
        endcase
    end


    /*********** state machine **************/
    typedef enum {WAIT,MUL,DIV_INIT,DIV,
    NEG_PRODUCT_TLO,NEG_PRODUCT_THI,
    NEG_QUOTIENT_TLO,NEG_REMAINDER_THI,
    PREVIOUS_SUB_TLO,PREVIOUS_SUB_THI,
    PREVIOUS_ADD_TLO,PREVIOUS_ADD_THI,STORAGE} state_t;
    state_t current_state,next_state;

    always_ff @(posedge clk) begin
        if(reset) begin
            current_state <= WAIT;
        end else
            current_state = next_state;
    end
    //--------state transform--------
    always_comb begin
        case(current_state)
            WAIT:
                if(mul)
                    next_state = MUL;
                else if(div) 
                    next_state = DIV;
                else
                    next_state = WAIT;
            DIV_INIT:
                next_state = DIV;
            DIV:
                if(&tick_count) begin
                    if(as^bs)
                        next_state = NEG_QUOTIENT_TLO;
                    else if(as)
                        next_state = NEG_REMAINDER_THI;
                    else
                        next_state = STORAGE;
                end

            MUL:
                if(&tick_count) begin
                    if(as^bs)
                        next_state = NEG_PRODUCT_TLO;
                    else
                        next_state = STORAGE;
                end
            
            NEG_PRODUCT_TLO: //negative quotion or axb[31:0]
                next_state = NEG_PRODUCT_THI;
            NEG_PRODUCT_THI:
                if(sub) //multiply , need to check sub and add
                    next_state =  PREVIOUS_SUB_TLO;
                else if(add)
                    next_state =  PREVIOUS_ADD_THI;
                else
                    next_state =  STORAGE; 
            NEG_QUOTIENT_TLO:
                if(as)
                    next_state = NEG_REMAINDER_THI;
                else
                    next_state = STORAGE;

            NEG_REMAINDER_THI:
                next_state = STORAGE;

            PREVIOUS_SUB_TLO:
                next_state = PREVIOUS_SUB_THI;
            PREVIOUS_SUB_THI:
                next_state = STORAGE;
            PREVIOUS_ADD_THI:
                next_state = PREVIOUS_ADD_THI;
            PREVIOUS_ADD_TLO:
                next_state = STORAGE;
            STORAGE:
                next_state = WAIT;
            default:
                next_state = WAIT;
        endcase
    end

    //state and control
    localparam control_len = $size({thi_sel,tlo_op,srcA_select,srcB_select,cin_sel,tick_op,hi_we,lo_we,initial_we});
    
    logic[control_len - 1: 0] control;
    assign {thi_sel,tlo_op,srcA_select,srcB_select,cin_sel,tick_op,hi_we,lo_we,initial_we} = control;
    always_comb begin
        case(current_state)
            WAIT:              control = {THI_ZERO ,      TLO_NCARE,    SRCA_NCARE, SRCB_NCARE, CIN_NCARE, TICK_RESET, 3'b001};
            MUL :              control = {THI_PARTIAL_MUL,TLO_SR_MUL,   SRCA_THI,   SRCB_AB,    CIN_ZERO,  TICK_ONE  , 3'b000};
            DIV_INIT:          control = {THI_PARTIAL_DIV,TLO_SL_DIV,   SRCA_THI,   SRCB_NAB,   CIN_ONE,   TICK_RESET, 3'b000};
            DIV:               control = {THI_PARTIAL_DIV,TLO_SL_DIV,   SRCA_THI,   SRCB_NAB,   CIN_ONE,   TICK_ONE  , 3'b000};
            NEG_QUOTIENT_TLO:  control = {THI_HOLD       ,TLO_ALU,      SRCA_ZERO,  SRCB_NTLO,  CIN_ONE,   TICK_NCARE, 3'b000};
            NEG_REMAINDER_THI: control = {THI_ALU        ,TLO_HOLD,     SRCA_ZERO,  SRCB_NTHI,  CIN_ONE,   TICK_NCARE, 3'b000};
            NEG_PRODUCT_TLO:   control = {THI_HOLD       ,TLO_ALU,      SRCA_ZERO,  SRCB_NTLO,  CIN_ONE,   TICK_NCARE, 3'b000};
            NEG_PRODUCT_THI:   control = {THI_ALU        ,TLO_HOLD,     SRCA_ZERO,  SRCB_NTHI,  CIN_COUT,  TICK_NCARE, 3'b000};
            PREVIOUS_SUB_TLO:   control = {THI_HOLD      ,TLO_ALU,      SRCA_LO  ,  SRCB_NTLO,  CIN_ONE,   TICK_NCARE, 3'b000};
            PREVIOUS_SUB_THI:   control = {THI_ALU       ,TLO_HOLD,     SRCA_HI  ,  SRCB_NTHI,  CIN_COUT,  TICK_NCARE, 3'b000}; 
            PREVIOUS_ADD_TLO:   control = {THI_HOLD      ,TLO_ALU,      SRCA_LO  ,  SRCB_TLO,   CIN_ZERO,  TICK_NCARE, 3'b000};
            PREVIOUS_ADD_THI:   control = {THI_ALU       ,TLO_HOLD,     SRCA_HI  ,  SRCB_THI,   CIN_COUT,  TICK_NCARE, 3'b000}; 
            STORAGE:           control = {THI_NCARE      ,TLO_NCARE,    SRCA_NCARE, SRCB_NCARE, CIN_NCARE, TICK_NCARE, 3'b110}; 
            default:           control = {THI_NCARE      ,TLO_NCARE,    SRCA_NCARE, SRCB_NCARE, CIN_NCARE, TICK_NCARE, 3'b000}; 
        endcase
    end

    assign waiting_result = (current_state != WAIT);
endmodule

`endif