`ifndef __COP0_INFO__
`define __COP0_INFO__
package cop0_info;
    typedef struct packed {
        logic bd;               //x  ignore, we don't have delay slot    R: exception in delay slot
        logic ti;               //x  Required    R: timer interrupt.
        logic[1:0] ce;          //x  Required    R: Coprocessor unit number referenced when a Coprocessor Unusable exception is taken.
        logic dc;               //x  ignore for none Disable count Register function
        logic pci;              //   ignore for no performance counter
        logic[1:0] reserved0;
        logic iv;               //x  Required  RW :Indicates whether an interrupt exception uses the general exception vector or a special interrupt vector:
        logic wp;               //   ignore for no watch Register
        logic[5:0] reserved1;
        logic[7:0] ip;          //x  Required  RW : interrupt pending
        logic       reserved2;  
        logic[3:0] exc_code;    //x  Required  RW :exception code
        logic[1:0] reserved3;
    } cause_t;
    localparam logic[4:0] IDX_CAUSE_BD = 31;
    localparam logic[4:0] IDX_CAUSE_IV = 23;
    localparam logic[4:0] IDX_CAUSE_IP_E = 15;
    localparam logic[4:0] IDX_CAUSE_IP_S = 8;
    localparam logic[4:0] IDX_CAUSE_EXCCODE_E = 6;
    localparam logic[4:0] IDX_CAUSE_EXCCODE_S = 2;
    typedef struct packed {
        logic[3:0] cu;  // xxxx Required       RW : Control Coprocessor access; 0 : not allowed; 1: allowed
        logic rp;       // 0    ignore for no reduce power RW: 
        logic fr;       // 0    ignore for 32bit or none fpu
        logic re;       // X    ignore for no reverse endian
        logic mx;       // 0    ignore for no to MDMXâ„¢ resources 
        logic px;       // 0    ignore for 32bit
        logic bev;      // 1    Required     RW: 0:Normal 1: Bootstrap  
        logic ts;       // 0    ignore for no TLB
        logic sr;       // 0    ignore for no  Soft Reset
        logic nmi;      // ?    Optional     RW: indicates NMI cause Reset 0:(Soft Reset,Rest) , 1:(NMI)
        logic reserved;  //0
        logic[1:0] impl;//x  ignore or use by youself
        logic[7:0] im;  //x  Required          RW: interrupt mask: 
        logic kx;       //0  ignore for 32bit
        logic sx;       //0  ignore for 32bit
        logic ux;       //0  ignore for 32bit
        logic um;       //0  Required          RW: Operating Mode   0 : Kernel, 1: User
        logic r0;       //0  ignore for no supervisor mode
        logic erl;       //1  Required          RW: Error Level      0 : Normal  1: Error
        logic exl;       //x  Required          RW: exception level  0 : Normal  1: Eexception
        logic ie;        //0  Required          RW: interrupt enable 0 : disable :enable
    } status_t;
    const logic[4:0] IDX_STATUS_BEV = 22;
    const logic[4:0] IDX_STATUS_UM =  4;
    const logic[4:0] IDX_STATUS_ERL = 2;
    const logic[4:0] IDX_STATUS_EXL = 1;
    const logic[4:0] IDX_STATUS_IE = 0;
    typedef struct packed {
        logic[1:0] hi1;         //10    ignore      R
        logic[17:0] base;       //0     Required    RW
        logic[1:0] reserved;     //00   reserved    R
         
        logic[9:0] cpu_number; //preset Required    R : cpu number

    } ebase_t;

    /*
    the reg data will used by exception process
*/
typedef struct {
    // used by ert
    logic[31:0] EPC,ErrorEPC,Status,EBase;
} cop0_excreg_t;
/*
    the data should be used to print
*/
typedef struct {
    // status will write through the mtc0, so will only care about cause and other
    // if erl is 1,clear erl, else clear exl.
    logic exception_happen;
    logic in_bd;
    logic[4:0] exc_code;
    logic[31:0] epc;
    logic load_addr;
    logic[31:0] badvaddr;
} cop0_exc_data_t;


    const logic[4:0]  RD_BADVADDR = 5'b01000;
    const logic[4:0]  RD_COUNT    = 5'b01001;
    const logic[4:0]  RD_COMPARE  = 5'b01011;
    const logic[4:0]  RD_STATUS   = 5'b01100;
    const logic[4:0]  RD_CAUSE    = 5'b01101;
    const logic[4:0]  RD_EPC      = 5'b01110;
    const logic[4:0]  RD_EBASE    = 5'b01111;
    const logic[4:0]  RD_LLADDR   = 5'b10001;
    const logic[4:0]  RD_ERROREPC = 5'b11110;

    const logic[2:0]  SEL_BADVADDR = 3'b000;
    const logic[2:0]  SEL_COUNT    = 3'b000;
    const logic[2:0]  SEL_COMPARE  = 3'b000;
    const logic[2:0]  SEL_STATUS   = 3'b000;
    const logic[2:0]  SEL_CAUSE    = 3'b000;
    const logic[2:0]  SEL_EPC      = 3'b000;
    const logic[2:0]  SEL_EBASE    = 3'b001;
    const logic[2:0]  SEL_LLADDR   = 3'b000;
    const logic[2:0]  SEL_ERROREPC = 3'b000;

endpackage

`endif