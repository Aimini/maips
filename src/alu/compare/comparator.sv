`ifndef  MODULE_COMPARATOR__
`define  MODULE_COMPARATOR__

`include "src/alu/compare/comparator_greate_than.sv"
`include "src/common/signals.sv"
import signals::*;

module comparator #(parameter N = 5)
(input logic[N-1:0] a,b,
 output signals::compare_t signal);
    comparator_user #(N) cmp(a,b,signal);
endmodule

module comparator_system #(parameter N = 32)
(input logic[N-1:0] a,b,
 output signals::compare_t signal);
    logic signed [N - 1:0] sa,sb;
    assign sa = a;
    assign sb = b;
    
    assign signal.eq =  a === b;
    assign signal.neq = a !== b;
    assign signal.gt = sa > sb;
    assign signal.lt = sa < sb;
    assign signal.gtu = a > b;
    assign signal.ltu = a < b;
endmodule

module comparator_user #(parameter N = 32)
(input logic[N-1:0] a,b,
 output signals::compare_t signal);

    comparator_greater_than #(N) cmp(a,b,signal.gtu,signal.eq);
    
    assign signal.neq =  ~signal.eq;
    assign signal.ltu = ~(signal.gtu | signal.eq);
    assign signal.gt =  ~a[N - 1] &  b[N - 1] | ~(a[N - 1] ^ b[N - 1]) & signal.gtu;
    assign signal.lt =   a[N - 1] & ~b[N - 1] | ~(a[N - 1] ^ b[N - 1]) & signal.ltu; 
endmodule

`endif