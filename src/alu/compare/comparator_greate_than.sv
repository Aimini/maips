`ifndef MODUEL_COMPARATOR_GREATER_THAN__
`define MODUEL_COMPARATOR_GREATER_THAN__

module comparator_greater_than #(parameter N = 32)
(input logic[N-1:0] a,b,
 output logic gtu,eq);
    localparam int level = $clog2(N) + 1;
    logic[N-1:0] internal_equ[level];
    logic[N-1:0] internal_greater[level];

    always_comb begin
        automatic int current_node = N; 
        
        internal_equ[0] = ~(a ^ b);
        internal_greater[0] = a &(~b);

        for(int j = 1; j < level; j += 1) begin
            for(int i = 0; i < current_node/2; ++i) begin
            internal_equ[j][i] = internal_equ[j - 1][i*2] & internal_equ[j - 1][i*2 + 1];
            internal_greater[j][i] = internal_greater[j - 1][i*2 + 1] | internal_greater[j - 1][i*2] & internal_equ[j - 1][i*2 + 1];
            end

            if(current_node % 2 != 0) begin
                internal_equ[j][current_node/2] = internal_equ[j - 1][current_node - 1];
                internal_greater[j][current_node/2] = internal_greater[j - 1][current_node - 1];
            end

            current_node = (current_node + 1)/2;
        end
    end
    assign gtu = internal_greater[level - 1][0];
    assign eq = internal_equ[level - 1][0];
endmodule

`endif