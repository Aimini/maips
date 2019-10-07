module sign_extend #(parameter NI = 16,parameter NO = 32)
(input logic[NI - 1:0] i, output logic[NO - 1:0] o);
    assign o =  {{NO - NI{i[NI - 1]}},i};
endmodule
