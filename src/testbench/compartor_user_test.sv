`include "src/alu/compare/comparator.sv"

module compartor_user_testN #(parameter N) ();
	logic[N-1:0] a,b;
        signals::compare_t cs_s,cu_s;
	comparator_system #(N) cs(a,b,cs_s);
        comparator_user  #(N)  cu(a,b,cu_s);

    task test_byN();
            for(int i = 0; i < 2**N; ++i) begin
                for(int j = 0; j < 2**N; ++j) begin
                    a = i; b = j; #2;
                    if(cs_s != cu_s) begin
                        $error("(%0d,%0d), (%b) != (%b)" ,a,b,cs_s,cu_s);
                        $stop;
                    end
                end
            end
            $display("success with %0d! bit",N);
    endtask
    initial begin
    	test_byN();
    end
endmodule

module compartor_user_test();
 compartor_user_testN #(3) T1();
 compartor_user_testN #(5) T2();
 compartor_user_testN #(8) T3();
 compartor_user_testN #(16) T4();
 compartor_user_testN #(17) T5();

endmodule