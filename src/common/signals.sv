`ifndef PACKAGE_SIGNAL__
`define PACKAGE_SIGNAL__

`include "src/common/selector.sv"
import selector::*;

package signals;
    `include "src/common/signal/compare_t.sv"
    `include "src/common/signal/flag_t.sv"
    `include "src/common/signal/control_t.sv"
    `include "src/common/signal/instruction_t.sv"
endpackage
`endif