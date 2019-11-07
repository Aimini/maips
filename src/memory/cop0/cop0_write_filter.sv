`ifndef __COP0_WRITE_FILTER__
`define __COP0_WRITE_FILTER__
/*
    alougth some bit is mask as bit value in register cop0, but we still
    have some bit can be written by some internal control and read only for mtc0
    
    */
module cop0_write_filter(
    input logic [4:0] rd, input logic [2:0] sel,
    output logic[31:0] wmask);

    typedef struct {
        logic[4:0] rd;
        logic[2:0] sel;
        logic[31:0] wmask; // write mask, 1 meaing can be written by mtc0.
    } config_t;

    localparam CON_LEN = 5;
    const config_t reg_configures[CON_LEN] = '{
        '{rd:5'b01000, sel:3'b000, wmask:32'h00000000}, //BadVaddr
        '{rd:5'b01100, sel:3'b000, wmask:32'h1040FF17}, // Status
        '{rd:5'b01101, sel:3'b000, wmask:32'h00800300}, // Cause
        '{rd:5'b01111, sel:3'b001, wmask:32'h3FFFF000}, // EBase
        '{rd:5'b10001, sel:3'b000, wmask:32'h00000000}  // LLAddr
    };

    const config_t full_access_config = '{rd:5'bx, sel:3'bx, wmask:32'hFFFFFFFF};

    function automatic config_t get_config(input logic[4:0] rd,input logic[2:0] sel);
        //return full_access_config; // allow full access when test
        for(int i = 0; i < CON_LEN;  ++i) begin
            if(rd === reg_configures[i].rd & sel === reg_configures[i].sel) begin
                return reg_configures[i];
            end
        end
        return full_access_config;
    endfunction
    
    config_t current_config;
    always_comb begin
        current_config =  get_config(rd,sel);
        wmask = current_config.wmask;
    end
endmodule
`endif