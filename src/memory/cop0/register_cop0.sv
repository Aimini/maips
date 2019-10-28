`ifndef REGISTER_COP0__
`define REGISTER_COP0__
`include "src/memory/cop0/cop0_info.sv"



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
    output logic[31:0] dout,
    input  cop0_info::cop0_exc_data_t excdata,
    output cop0_info::cop0_excreg_t excreg);

    localparam implement_num = 9;
    localparam implement_num_width = $clog2(implement_num);
    typedef logic[implement_num_width - 1:0] index_t;
    typedef logic[31:0] reg_t;

    typedef struct{
       logic[4:0] rd;
       logic[2:0] sel;
       logic[31:0] initial_value;
       logic[31:0] fixed_value_mask,fixed_value;
    } config_t;


/*************************** define of cop0 write mask ***************************************/
    const config_t configurations[implement_num - 1:0] = '{
        '{cop0_info::RD_BADVADDR , cop0_info::SEL_BADVADDR,   32'h00000000, 32'h0,       32'h0 }, //BadVaddr
        '{cop0_info::RD_COUNT    , cop0_info::SEL_COUNT   ,   32'h00000000, 32'h0,       32'h0 }, //Count
        '{cop0_info::RD_COMPARE  , cop0_info::SEL_COMPARE ,   32'h00000000, 32'h0,       32'h0 }, // Compare
        '{cop0_info::RD_STATUS   , cop0_info::SEL_STATUS  ,   32'h00400004, 32'hEFBF00E8,32'h0 }, // Status
        '{cop0_info::RD_CAUSE    , cop0_info::SEL_CAUSE   ,   32'h00000000, 32'h0F7F0083,32'h0 }, // Cause
        '{cop0_info::RD_EPC      , cop0_info::SEL_EPC     ,   32'h00000000, 32'h0,       32'h0 }, // EPC *
        '{cop0_info::RD_EBASE    , cop0_info::SEL_EBASE   ,   32'h80000000, 32'hC0000FFF,32'h80000000 }, // EBase *
        '{cop0_info::RD_LLADDR   , cop0_info::SEL_LLADDR  ,   32'h00000000, 32'h0,       32'h0 }, // LLAddr *
        '{cop0_info::RD_ERROREPC , cop0_info::SEL_ERROREPC,   32'h00000000, 32'h0,       32'h0 }  // ErrorEPC *
    };    

    const config_t invalid_config =     '{5'bx, 3'bx,   32'hx,        32'hx,       32'hx };
    const config_t full_access_config = '{5'bx, 3'bx,   32'hx,        32'h00000000,32'h00000000 };



    /****************************** get_index *******************************/
    
    const index_t status_index =   get_index_by_rd_sel(cop0_info::RD_STATUS  ,cop0_info::SEL_STATUS);
    const index_t cause_index =    get_index_by_rd_sel(cop0_info::RD_CAUSE   ,cop0_info::SEL_CAUSE);
    const index_t epc_index =      get_index_by_rd_sel(cop0_info::RD_EPC     ,cop0_info::SEL_EPC);
    const index_t errorepc_index = get_index_by_rd_sel(cop0_info::RD_ERROREPC,cop0_info::SEL_ERROREPC);
    const index_t ebase_index    = get_index_by_rd_sel(cop0_info::RD_EBASE   ,cop0_info::SEL_EBASE);

    reg_t file[implement_num - 1:0];

     /************** write configuration  **************/
    reg_t data_write;
    index_t write_index;
    config_t write_config;

    /************** read configuration **************/
    reg_t data_read;
    logic[implement_num_width - 1:0] read_index;
    config_t read_config;



    /********************* always logic ***********************************/
    always_ff @(posedge clk) begin
        if(reset) begin
            foreach(file[i]) begin
                file[i] <= configurations[i].initial_value;
            end
        end else begin
            if(we) begin
                assert (write_index < implement_num )
                else begin
                    $error("write invalid cop0 register.");
                    $stop;
                end
                file[write_index] <= data_write;
            end
            if(excdata.exception_happen) begin
                file[epc_index] <= excdata.epc;
                file[cause_index][cop0_info::IDX_CAUSE_BD] <= excdata.in_bd;
                file[cause_index][cop0_info::IDX_CAUSE_EXCCODE_E:cop0_info::IDX_CAUSE_EXCCODE_S] <= excdata.exc_code;
            end
        end
            
         

    end
    /****************************** define of tool function *******************************/
    /*
     get configuration index
    */
    function automatic reg_t get_value_masked(input index_t idx,input reg_t value);
        config_t c = get_config_by_index(idx);
        return  value & ~c.fixed_value_mask | c.fixed_value & c.fixed_value_mask;
    endfunction 

     function automatic reg_t get_value_masked_file(input index_t idx);
        return  get_value_masked(idx,file[idx]);
    endfunction 

    function automatic index_t get_index_by_rd_sel(
        input logic [4:0] rd,input logic[2:0] sel);

        index_t i;
        for(i = '0; i < implement_num; ++i) begin
            if(configurations[i].rd === rd & configurations[i].sel === sel) begin
                return i;
            end
        end
        return implement_num;
    endfunction
    


    function automatic config_t get_config_by_index(input index_t i);
        //return full_access_config; // allow full access when test
        if(i < implement_num) begin
            return  configurations[i];
        end else begin
            return invalid_config;
        end
    endfunction

/*************************** output exception register ***************************************/
    always_comb begin
        excreg.ErrorEPC = get_value_masked_file(errorepc_index);
        excreg.EPC      = get_value_masked_file(epc_index);
        excreg.Status   = get_value_masked_file(status_index);
        excreg.EBase   =  get_value_masked_file(ebase_index);
    end

    /********************* data write process *******************************/
    always_comb begin
        write_index =  get_index_by_rd_sel(write_rd,write_sel);
        write_config = get_config_by_index(write_index);
        data_write = get_value_masked(write_index,din);
    end
    
    
    always_comb begin
        read_index =  get_index_by_rd_sel(read_rd,read_sel);
        read_config = get_config_by_index(read_index);
        data_read = get_value_masked_file(read_index);
        dout = data_read;
    end 
endmodule

`endif