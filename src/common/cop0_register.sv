package cop_reg
    typedef struct packed {
        logic bd;               //x  ignore, we don't have delay slot    R: exception in delay slot
        logic ti                //x  Required    R: timer interrupt.
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

    typedef struct packed {
        logic[3:0] cu;  // xxxx Required       RW : Control Coprocessor access; 0 : not allowed; 1: allowed
        logic rp;       // 0    ignore for no reduce power RW: 
        logic fr;       // 0    ignore for 32bit or none fpu
        logic re;       // X    ignore for no reverse endian
        logic mx;       // 0    ignore for no to MDMX™ resources 
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
        logic erl       //1  Required          RW: Error Level      0 : Normal  1: Error
        logic exl       //x  Required          RW: exception level  0 : Normal  1: Eexception
        logic ie        //0  Required          RW: interrupt enable 0 : disable :enable
    } status_t;
    
    typedef struct packed {
        logic[1:0] hi1;         //10    ignore      R
        logic[17:0] base;       //0     Required    RW
        logic[1:0] reserved;     //00   reserved    R
         
        logic[9:0] cpu_number; //preset Required    R : cpu number

    } ebase_t;
endpackage;