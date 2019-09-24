`ifndef PACKAGE_SIGNAL__
`define PACKAGE_SIGNAL__

`include "common/selector.sv"
import selector::*;

package signals;
    `include "common/signal/compare_t.sv"
    `include "common/signal/flag_t.sv"
    `include "common/signal/control_t.sv"
    `include "common/signal/instruction_t.sv"
endpackage
`endif