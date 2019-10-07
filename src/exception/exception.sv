logic[31:0] EXCEPTION_ADDR_BASE = 32'hBFC0_0000;



CAUSE_OVERFLOW
CAUSE_ADDRESS_ERROR
CAUSE_SYSCALL
CAUSE_BREAK
CAUSE_TRAP
CAUSE_COPROCESSOR_UNUSABLE



module exception_capture(
    input logic address_error_fetch,
    input logic address_error_memory,
    input logic write_mem, // determine write or load cause address error
    input logic syscall,
    input logic break,
    input logic trap,
    input logic cop_unusable,
    output logic exception_code,
    output logic address,
    output logic take
);


endmodule

module exception_address(
input logic exception_code,
input ebase,
input logic iv,bev,
output logic exception_address);
    logic[31:0] base,offset;
    always_comb begin
        base = bev ? 32'hBCF0_0100 : {ebase[31:],};
        if(exception_address == EXC_CODE_INTERRUPT && iv)
            offset = 32'h0000_0200;
        else
            offset = 32'h0000_0180;
        exception_address = base + offset;
    end
endmodule