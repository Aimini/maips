//div: hi = a/b ,low = a %b
`ifndef MODULE_DIV_MUL__
`define MODULE_DIV_MUL__

/*
    mul: do multiply
    div: do division, div has high priority

    the mul, div, sub, add, a, b are registered by
    excute pipline register, so we can assume it's
    not change in caculate when we generate 
    waiting_result signal correctly.
    
    using_sign
*/
module div_mul #(parameter N = 32)
   (input logic clk,reset,
   input logic clear,hold_result,
      input logic mul,div,using_sign,
      input logic sub,add,
      input logic[N-1:0] a,b,hi_in,lo_in,
      output logic[N-1:0] hi_out,lo_out,
      output logic write_hi_lo,waiting_result);

    localparam NN = $clog2(N);

    // absolute a,b
    logic [N - 1:0] a_neg, b_neg; 
    // a ,b sgin, 1 is negative , 0 postive
    logic a_neg_we,b_neg_we;
    // bit iterator in abs_a,
    //for each stage, a_abs_iter = a31\a30.. or a0\a1\a2...(div)
    // or a0\a1\a2.... a30\a31 (mul)
    logic a_abs_iter; 

    //when doing mul and div, count witch step now.
    logic [NN - 1:0] tick_count;

    // storage hi and lo, when excute MADD,or MSUB,
    // we nned hi and low to sub then Multiply result
    logic [N - 1:0] thi, tlo; // temp hi,lo,storage multiply and division intermediate result;
    
    logic[N-1:0] srcA, srcB, alu_out;
    logic cin,cout,cout_reg;

    logic[N-1:0] a_abs, b_abs,a_abs_reversed;


    /*** if a,b is negative, we need to neg it and store
    it int a_neg and b_neg ***/
    always_ff @(posedge clk) begin
        if(a_neg_we) begin
            a_neg <= alu_out;
        end
        if(b_neg_we) begin
            b_neg <= alu_out;
        end
    end
    always_comb begin
        a_abs = (a[N - 1] & using_sign) ? a_neg : a;
        b_abs = (b[N - 1]  & using_sign) ? b_neg : b;
        a_abs_reversed = {<<{a_abs}};
        a_abs_iter = mul ? a_abs[tick_count] : a_abs_reversed[tick_count];
    end

    /******* tick count *******/
    typedef enum {
        TICK_ONE,
        TICK_RESET,
        TICK_NCARE} tick_funct_t;
    tick_funct_t tick_op;
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
    typedef enum {
        THI_HOLD,
        THI_ALU,
        THI_PARTIAL_MUL,
        THI_PARTIAL_DIV,
        THI_ZERO,
        THI_NCARE} thi_src_t;
    typedef enum  {
        TLO_HOLD,
        TLO_ALU,
        TLO_SR_MUL,
        TLO_SL_DIV,
        TLO_NCARE} tlow_src_t;

    thi_src_t thi_sel;
    tlow_src_t tlo_sel;
    always_ff @(posedge  clk) begin
        case (thi_sel)
            THI_HOLD            : thi <= thi;
            THI_ALU             : thi <= alu_out;
            THI_PARTIAL_MUL     : thi <= {cout,alu_out[N - 1:1]};
            THI_PARTIAL_DIV     : thi <= cout ? alu_out : srcA;
            THI_ZERO            : thi <= 0;
            default:            thi <= 'x;
        endcase

        case(tlo_sel)
            TLO_HOLD    : tlo <= tlo;
            TLO_ALU     : tlo <= alu_out;
            TLO_SR_MUL  : tlo <= {alu_out[0],tlo[N-1:1]};
            TLO_SL_DIV  : tlo <= {tlo[N-2:0],cout};
            default     : tlo <= 'x;
        endcase
    end


    /********** alu ************/
    // stage and operation
    // abs a :  0  - a
    // abs b:   0 -  b
    // mul:  thi  = thi + (abs_a[i] * (2 << i) * abs_b)
    // div:  thi  = thi - abs_b
    // negative mul result: tlo = 0 - tlo
    //                      thi = 0 - thi - cout_Reg
    // negative div result: tlo = 0 - tlo
    //                      thi = 0 - thi
    // MADD(U): tlo =  lo + tlo
    //          thi =  hi + thi + cout_reg
    // MSUB(U): tlo  = lo - tlo
    //          thi  = hi - thi - cout_reg
    typedef enum   {
        SRCA_ZERO,
        SRCA_THI,
        SRCA_THI_WITH_AITER,
        SRCA_HI,
        SRCA_LO,
        SRCA_NCARE
        } alu_srcA_t;

    typedef enum {
        SRCB_THI ,
        SRCB_TLO,
        SRCB_A,
        SRCB_B,
        SRCB_ABS_B,
        SRCB_AITER_B,
        SRCB_NCARE
        } alu_srcB_t;

    typedef enum  {
        CIN_ZERO,
        CIN_ONE,
        CIN_COUT,
        CIN_NCARE
        } alu_cin_t;
        
    alu_srcA_t srcA_select;
    alu_srcB_t srcB_select;
    alu_cin_t  cin_sel;
    logic      neg_srcB;
    always_ff @(posedge clk) begin
        cout_reg <= cout;
    end

    assign {cout,alu_out} = srcA + srcB + cin;
    always_comb begin
        case(srcA_select)
            SRCA_ZERO: srcA = 0;
            SRCA_THI : srcA = thi;
            SRCA_THI_WITH_AITER : srcA = {thi[N-2:0],a_abs_iter};
            SRCA_HI : srcA = hi_in;
            SRCA_LO : srcA = lo_in;
            default:srcA = 'x;
        endcase

        case(srcB_select)
            SRCB_THI : srcB = thi;
            SRCB_TLO : srcB = tlo;
            SRCB_A: srcB = a;
            SRCB_B: srcB = b;
            SRCB_ABS_B  : srcB = b_abs;
            SRCB_AITER_B: srcB = b_abs & ({N{a_abs_iter}});
            default:srcB = 'x;
        endcase
        if(neg_srcB)
            srcB = ~srcB;

        case (cin_sel)
            CIN_ZERO: cin = 0;
            CIN_ONE:  cin = 1;
            CIN_COUT: cin = cout_reg;
            default:  cin = 'x;
        endcase
    end


    /*********** state machine **************/
    typedef enum {WAIT,
    MAKE_ABS_A,MAKE_ABS_B,
    MUL,DIV_INIT,DIV,
    NEG_PRODUCT_TLO, NEG_PRODUCT_THI,
    NEG_QUOTIENT_TLO,NEG_REMAINDER_THI,
    PREVIOUS_SUB_TLO,PREVIOUS_SUB_THI,
    PREVIOUS_ADD_TLO,PREVIOUS_ADD_THI,STORAGE} state_t;
    state_t current_state,next_state;
    
    always_ff @(posedge clk,posedge reset) begin
        if(reset) begin
            current_state <= WAIT;
        end else if(clear) begin
            current_state <= WAIT;
        end else
            current_state = next_state;
    end
    //--------state transform--------
    always_comb begin
        case(current_state)
            WAIT:
                if(using_sign & a[N - 1])
                    next_state = MAKE_ABS_A;
                else if(using_sign & b[N - 1]) 
                    next_state = MAKE_ABS_B;
                else if(mul)
                    next_state = MUL;
                else if(div)
                    next_state = DIV;
                else
                    next_state = WAIT;


            MAKE_ABS_A:
                if(b[N - 1])
                    next_state = MAKE_ABS_B;
                else if(mul)
                    next_state = MUL;
                else
                    next_state = DIV;

            MAKE_ABS_B:
                if(mul)
                    next_state = MUL;
                else
                    next_state = DIV;
                
            // DIV_INIT:
            //     next_state = DIV;
            DIV:
                if(&tick_count) begin
                    if(using_sign) begin
                        if(a[N - 1]^b[N - 1]) 
                            next_state = NEG_QUOTIENT_TLO;
                        else if(a[N - 1])
                            next_state = NEG_REMAINDER_THI;
                        else
                            next_state = STORAGE;
                    end else begin
                        next_state = STORAGE;
                    end
                end

            MUL:
                if(&tick_count) begin
                    if(using_sign & (a[N - 1]^b[N - 1]))
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
                if(a[N - 1])
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
                if(hold_result)
                    next_state = STORAGE;
                else
                    next_state = WAIT;
            default:
                next_state = WAIT;
        endcase
    end

    //state and control

    always_comb begin
        {thi_sel,      tlo_sel,
         srcA_select,  srcB_select,
         cin_sel,      tick_op,
         write_hi_lo, 
         a_neg_we,     b_neg_we} = {
            THI_NCARE,  TLO_NCARE,
            SRCA_NCARE, SRCB_NCARE,
            CIN_NCARE,  TICK_NCARE,
            1'b0,
            1'b0,       1'b0
        };
        write_hi_lo = '0;
        waiting_result = '1;
        neg_srcB = '0;

        hi_out = thi;
        lo_out = tlo;
        case(current_state)
            WAIT:  begin
                 if(!(mul | div))
                    waiting_result = '0;
                // it may jump to  DIV ,MUL directly ,so
                // you must prepare for it
                { tick_op, thi_sel } = {TICK_RESET,THI_ZERO};
            end
               
            MAKE_ABS_A:  begin
                {tick_op,    cin_sel, thi_sel,  srcA_select, srcB_select, neg_srcB, a_neg_we} = 
                {TICK_RESET, CIN_ONE, THI_ZERO, SRCA_ZERO,   SRCB_A,      1'b1,     1'b1};
                
            end
            MAKE_ABS_B:       
                {tick_op,    cin_sel, thi_sel,  srcA_select, srcB_select, neg_srcB, b_neg_we} = 
                {TICK_RESET, CIN_ONE, THI_ZERO, SRCA_ZERO,   SRCB_B,      1'b1,     1'b1 };
            
            MUL :
                {thi_sel,          tlo_sel,    srcA_select, srcB_select,  cin_sel,  tick_op } = 
                { THI_PARTIAL_MUL, TLO_SR_MUL, SRCA_THI,    SRCB_AITER_B, CIN_ZERO, TICK_ONE};
            // DIV_INIT:
            //     {thi_sel,        tlo_sel,    srcA_select,    srcB_select, cin_sel,  tick_op,    neg_srcB } = {
            //     THI_PARTIAL_DIV, TLO_SL_DIV, SRCA_THI,       SRCB_ABS_B,  CIN_ONE,  TICK_RESET, 1'b1}; 
            DIV:              
                {thi_sel,         tlo_sel,    srcA_select,         srcB_select, cin_sel, tick_op,  neg_srcB } = 
                {THI_PARTIAL_DIV, TLO_SL_DIV, SRCA_THI_WITH_AITER, SRCB_ABS_B,  CIN_ONE, TICK_ONE, 1'b1}; 
            NEG_QUOTIENT_TLO:  
                {thi_sel,  tlo_sel, srcA_select, srcB_select, cin_sel, neg_srcB } =  
                {THI_HOLD, TLO_ALU, SRCA_ZERO,   SRCB_TLO,    CIN_ONE, 1'b1}; 
            NEG_REMAINDER_THI:
                {thi_sel, tlo_sel,  srcA_select, srcB_select, cin_sel, neg_srcB } = {
                THI_ALU,  TLO_HOLD, SRCA_ZERO,   SRCB_THI,    CIN_ONE, 1'b1};
            NEG_PRODUCT_TLO:   
                {thi_sel, tlo_sel, srcA_select, srcB_select, cin_sel, neg_srcB } = {
                THI_HOLD, TLO_ALU, SRCA_ZERO,   SRCB_TLO,    CIN_ONE,  1'b1}; 
            NEG_PRODUCT_THI:  
                {thi_sel, tlo_sel, srcA_select, srcB_select, cin_sel, neg_srcB } = {
                THI_ALU, TLO_HOLD, SRCA_ZERO,   SRCB_THI,    CIN_COUT, 1'b1};  
            PREVIOUS_SUB_TLO: 
                {thi_sel, tlo_sel, srcA_select, srcB_select, cin_sel, neg_srcB } = {
                THI_HOLD, TLO_ALU, SRCA_LO,     SRCB_TLO,    CIN_ONE,  1'b1}; 
            PREVIOUS_SUB_THI:   
                {thi_sel, tlo_sel,  srcA_select, srcB_select, cin_sel,  neg_srcB } = {
                THI_ALU,  TLO_HOLD, SRCA_HI,     SRCB_THI,    CIN_COUT, 1'b1};
            PREVIOUS_ADD_TLO:   
                {thi_sel,    tlo_sel,  srcA_select, srcB_select, cin_sel} = 
                {THI_HOLD,   TLO_ALU,  SRCA_LO,     SRCB_TLO,    CIN_ZERO}; 
            PREVIOUS_ADD_THI:
                {thi_sel,    tlo_sel,  srcA_select, srcB_select, cin_sel} = 
                {THI_ALU,   TLO_HOLD,  SRCA_HI,     SRCB_THI,    CIN_COUT}; 
            STORAGE:  begin
                     {thi_sel,    tlo_sel} =  {THI_HOLD,   TLO_HOLD};
                      write_hi_lo = '1; waiting_result = '0;
            end
            default: begin
                      write_hi_lo = '0; waiting_result = '0;
            end
        endcase
    end
endmodule

`endif