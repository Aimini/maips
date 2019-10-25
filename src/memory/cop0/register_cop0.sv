`ifndef REGISTER_COP0__
`define REGISTER_COP0__
/*
    we : write register wit internal define mask; the input data bit corresponding mask  bit is 0 will not be write.
  din: data will be write into register than indcated by rd and sel,
    rd:   write register file selector field ,rd
    sel:  write register file selector field ,sel
    
    rrd,rsel:   read selector
    dout:       data out selected by rrd,rsel
*/
module register_cop0(input logic clk,reset,
    input logic we,
    input logic [4:0] write_rd,
    input logic [2:0] write_sel,
    input logic[31:0] din,
    input logic [4:0] read_rd,
    input logic [2:0] read_sel,
    output logic[31:0] dout);

    logic[31:0] initial_value[4:0][2:0];
    typedef struct{
       logic[4:0] rd;
       logic[2:0] sel;
       logic[31:0] initial_value;
       logic[31:0] fixed_value_mask,fixed_value;
    } config_t;

    localparam implement_num = 9;
    localparam implement_num_width = $clog2(implement_num);
    const config_t configurations[implement_num - 1:0] = '{
        '{5'b01000, 3'b000,   32'h00000000, 32'h0,       32'h0 }, //BadVaddr
        '{5'b01001, 3'b000,   32'h00000000, 32'h0,       32'h0 }, //Count
        '{5'b01011, 3'b000,   32'h00000000, 32'h0,       32'h0 }, // Compare
        '{5'b01100, 3'b000,   32'h00400004, 32'hEFBF00E8,32'h0 }, // Status
        '{5'b01101, 3'b000,   32'h00000000, 32'h0F7F0083,32'h0 }, // Cause
        '{5'b01110, 3'b000,   32'h00000000, 32'h0,       32'h0 }, // EPC *
        '{5'b01111, 3'b001,   32'h80000000, 32'hC0000FFF,32'h80000000 }, // EBase *
        '{5'b10001, 3'b000,   32'h00000000, 32'h0,       32'h0 }, // LLAddr *
        '{5'b11110, 3'b000,   32'h00000000, 32'h0,       32'h0 }  // ErrorEPC *
    };
    const config_t invalid_config =     '{5'bx, 3'bx,   32'hx,        32'hx,       32'hx };
    const config_t full_access_config = '{5'bx, 3'bx,   32'hx,        32'h00000000,32'h00000000 };

    logic[31:0] file[implement_num - 1:0];

    logic[31:0] data_write;
    logic[implement_num_width - 1:0] write_index;
    config_t write_config;

    logic[31:0] data_read;
    logic[implement_num_width - 1:0] read_index;
    config_t read_config;

    always_ff @(posedge clk) begin
        if(reset) begin
            foreach(file[i]) begin
                file[i] <= configurations[i].initial_value;
            end
        end else if(we) begin
            assert (write_index < implement_num )
            else begin
                $error("write invalid cop0 register.");
                $stop;
            end
            file[write_index] <=  data_write & ~write_config.fixed_value_mask | write_config.fixed_value_mask & write_config.fixed_value;
        end
    end
    /*
     get configuration index
    */
    function automatic logic[implement_num_width - 1:0] get_index_by_rd_sel(
        input logic [4:0] rd,input logic[2:0] sel);

        logic[implement_num_width - 1:0] i;
        for(i = '0; i < implement_num; ++i) begin
            if(configurations[i].rd === rd & configurations[i].sel === sel) begin
                return i;
            end
        end
        return implement_num;
    endfunction

    function automatic config_t get_config_by_index(input logic[implement_num_width - 1:0] i);

        //return full_access_config; // allow full access when test
        if(i < implement_num) begin
            return  configurations[i];
        end else begin
            return invalid_config;
        end
    endfunction

    assign data_write = din;
    assign dout = data_read;

    always_comb begin
        write_index =  get_index_by_rd_sel(write_rd,write_sel);
        write_config = get_config_by_index(write_index);
    end
    
    
    always_comb begin
        read_index =  get_index_by_rd_sel(read_rd,read_sel);
        read_config = get_config_by_index(read_index);
        data_read = file[read_index] & ~read_config.fixed_value_mask | read_config.fixed_value & read_config.fixed_value_mask;
    end 
    

endmodule

`endif