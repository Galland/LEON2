
define_clock            -name {clk}  -freq 50.0 -clockgroup default_clkgroup
define_clock            -name {pci_clk_in}  -freq 40.000 -clockgroup pci_clkgroup
define_clock            -name {erx_clk}  -freq 30.000 -clockgroup erx_clk_clkgroup
define_clock            -name {etx_clk}  -freq 30.000 -clockgroup etx_clk_clkgroup

define_output_delay -default  8.00 -ref clk:r
define_input_delay -default  10.00 -ref clk:r
define_output_delay -default 14.00 -ref pci_clk_in:r
define_input_delay -default  18.00 -ref pci_clk_in:r
define_output_delay -default  8.00 -ref erx_clk:r
define_input_delay -default  10.00 -ref erx_clk:r
define_output_delay -default  8.00 -ref etx_clk:r
define_input_delay -default  10.00 -ref etx_clk:r

define_global_attribute          syn_useioff {1}
