`ifndef PACKAGE_SIGNAL__
`define PACKAGE_SIGNAL__

`include "src/common/selector.sv"

package signals;
    `include "src/common/signal/compare_t.sv"
    `include "src/common/signal/flag_t.sv"
    `include "src/common/signal/control_t.sv"
    `include "src/common/signal/unpack_t.sv"
endpackage
`endif