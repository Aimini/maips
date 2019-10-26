/*
 mips standard fiexed memory map
*/
module fixed_memory_map(input logic[31:0] vaddr,
input logic  status_erl,
output logic[31:0] paddr);
always_comb begin
    if(vaddr >= 32'hC000_0000)
        paddr = vaddr; //kseg3 kesg2
    else if(vaddr >= 32'hA000_0000)
        paddr = vaddr - 32'hA000_0000; //kesg1
    else if(vaddr >= 32'h8000_0000)
        paddr = vaddr - 32'h8000_0000; //kesg0
    else
        if(status_erl)
            paddr = vaddr; //useg
        else
            paddr = vaddr + 32'h4000_0000; //useg
end
    
endmodule