`ifndef COMPARE_FLAG_MUX__
`define COMPARE_FLAG_MUX__

module compare_flag_mux(input selector::flag_select select, input signals::compare_t f,output logic o);
    always_comb begin
        case(select)    
            selector::FLAG_EQ:    o = f.eq;
            selector::FLAG_NE:    o = f.neq;
            selector::FLAG_LE:    o = f.lt | f.eq;
            selector::FLAG_GE:    o = f.gt | f.eq;
            selector::FLAG_LT:    o = f.lt;
            selector::FLAG_GT:    o = f.gt;
            selector::FLAG_LEU:   o = f.ltu | f.eq;
            selector::FLAG_GEU:   o = f.gtu | f.eq;
            selector::FLAG_LTU:   o = f.ltu;
            selector::FLAG_GTU:   o = f.gtu;
            default:
                o = 'x;
        endcase
    end
endmodule

`endif
