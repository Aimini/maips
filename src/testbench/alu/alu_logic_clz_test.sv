`include "src/alu/alu_logic/alu_logic_clz.sv"
module alu_logic_clz_test();
    localparam N = 32;
    logic clk;
    logic[N - 1:0] number;
    logic[$clog2(N):0] count;
    alu_logic_clz #(N) clz7(.a(number),.y(count));

    function automatic int clz_function(input logic[N - 1:0] x);
        int c = 0;
        begin
            for(int i = 0; i < N; ++i)
                if(x[N - i - 1] == 0)
                    ++c;
                else
                    break;
            return  c;
        end
    endfunction

    function automatic logic[N - 1:0] get_test_data(logic[N - 1:0] seed);
        return $urandom_range(0,2**N - 1);
    endfunction

    int x;
    initial begin
        for(int j = 0; j < 1000000; ++j) begin
            number = get_test_data(j); #1;
            x = clz_function(number);
            assert (count == x) 
            else  $error("%b lead zero be %0d, expect %0d",number,count,x); 
        end
        $info("finish.");
    end
endmodule