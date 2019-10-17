`ifndef DIV_MUL_TEST__
`define DIV_MUL_TEST__

`include "src/alu/div_mul/div_mul.sv"
module div_mul_test();
    
    localparam N = 32;

    logic clk,reset;
    logic clear, hold_result;
    logic mul,div,using_sign;
    
    logic sub,add;
    logic[N - 1:0] a,b,hi_in,lo_in;

    logic[N - 1:0] hi_out,lo_out;
    logic write_hi_lo,waiting_result;

    div_mul #(N) unit(.clk(clk),.reset(reset),
        .clear(clear), .hold_result(hold_result),
      .mul(mul),.div(div),.using_sign(using_sign),
      .sub(sub),.add(add),
      .a(a),.b(b),.hi_in(hi_in),.lo_in(lo_in),
      .hi_out(hi_out),.lo_out(lo_out),
      .write_hi_lo(write_hi_lo),.waiting_result(waiting_result));
    
    always begin
        clk = 1; #5ns;
        clk = 0; #5ns;
    end


    logic[31:0] bound_case[] =  {0, 1, 2, 2**16 - 2, 2**16 - 1, 2**16, 2**16 + 1, 2*16 + 2, 2**32 - 2, 2**32 - 1};
    class test_data_t;
        rand logic[31:0] hi,lo,a,b;
        logic no_zero,using_bound;
        constraint const_no_zero 
        { 
            if(no_zero)
            {
                b >  0;
            }
        };
        constraint const_bound 
        {
            if(using_bound)
            {
                a  inside {bound_case};
                b  inside {bound_case}; 
            }
        };
    endclass

    typedef struct packed {
        logic sub, add, using_sign, mul,div;
    } config_t;

    task automatic test_one_pair(input config_t con, input test_data_t td);
        string fname;
        string operand;
        logic[N*2 - 1:0] result;
        logic[N*2 - 1:0] multiply_result;
        logic[N - 1:0] remainder, quotient;
        logic signed[N - 1:0] sa,sb;

        {sub, add, using_sign, mul,div} = con;
        hi_in = td.hi;
        lo_in = td.lo;
        sa = td.a;
        sb = td.b;
        a = td.a;
        b = td.b;

        //switcch singed/unsigned div or mul
        if(con.using_sign) begin
            remainder = sa % sb;
            quotient = sa/ sb;
            multiply_result = sa*sb;
        end else begin
            remainder = a % b;
            quotient = a/ b;
            multiply_result = a*b;
        end
        
        if(con.mul) begin
            result = multiply_result;
        end else begin
            result = {remainder, quotient};
        end
        
        fname = using_sign ? "signed" : "unsigned";
        operand = con.mul ? "*" : "/";
        if(con.mul)
            fname = {fname," multiply"};
        if(con.div)
            fname = {fname," division"};
        do begin

            @(negedge clk);
        end while(waiting_result);
        // $display("%x %s %x = %x",td.a, operand ,td.b,result);
        assert({hi_out,lo_out} === result)
        else $error("function %s: %x %s %x = %x, but we get %x",
            fname, td.a, operand, td.b, result, {hi_out,lo_out});
    endtask

    task automatic test_one_mode_bench(input config_t con);
        logic[N - 1:0] aa,bb;
        test_data_t td = new;

        int rresult = 0;
        td.no_zero = 0;
        if(con.div === 1)
            td.no_zero = 1;
        //test boundary value
        td.using_bound = 1;
        for(int j = 0; j < 50000; ++j) begin
            if(td.randomize()) begin
                test_one_pair(con, td);
            end else begin
                $error("randomize failed!");
                $stop;
            end
        end
        
        //test random value
        td.using_bound = 0;
        for(int i = 0; i < 200000; ++i) begin
            if(td.randomize()) begin
                test_one_pair(con, td);
            end else begin
                $error("randomize failed!");
                $stop;
            end
        end
    endtask

     task automatic test_all_bench();
        config_t all_config[] = '{
            //'{0,0,0,1,0}, // unsigned mul
            //'{0,0,0,0,1}, // unsigned div
            //'{0,0,1,1,0}, // signed mul
            '{0,0,1,0,1} // signed div
        };
       
        for(int i = 0; i < all_config.size(); ++i) begin
            config_t one_configuration = all_config[i];
            test_one_mode_bench(one_configuration);
        end
    endtask

    initial begin
        clear = 0;
        hold_result = 0;
        reset = 1;
        repeat(2) @(negedge clk);
        reset = 0;
        test_all_bench();
        $finish;
    end

endmodule

`endif