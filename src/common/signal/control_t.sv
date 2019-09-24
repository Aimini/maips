

typedef struct{
    selector::pc_source pc_src;
    selector::alu_function alu_funct;
    selector::alu_sourceA alu_srcA;
    selector::alu_sourceB alu_sreB; 
    selector::write_regiter rwrite_reg;
} control_t;