
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
define_attribute          {pci_rst_in_n} xc_padtype {ibuf_pci33_3}
define_attribute          {pci_clk_in} xc_padtype {ibuf_pci33_3}
define_attribute          {pci_gnt_in_n} xc_padtype {ibuf_pci33_3}
define_attribute          {pci_idsel_in} xc_padtype {ibuf_pci33_3}
define_attribute          {pci_lock_n} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_ad[31:0]} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_cbe_n[3:0]} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_frame_n} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_irdy_n} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_trdy_n} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_devsel_n} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_stop_n} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_perr_n} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_par} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_req_n} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_serr_n} xc_padtype {iobuf_pci33_3}
define_attribute          {pci_arb_req_n[0:3]} xc_padtype {ibuf_pci33_3}
define_attribute          {pci_arb_gnt_n[0:3]} xc_padtype {obuf_pci33_3}
define_attribute          {p:power_state[1:0]} xc_padtype {obuf_pci33_3}
define_attribute          {p:pme_enable} xc_padtype {obuf_pci33_3}
define_attribute          {p:pme_clear} xc_padtype {obuf_pci33_3}
define_attribute          {pme_status} xc_padtype {ibuf_pci33_3}
define_attribute          {pci_host} xc_padtype {ibuf_pci33_3}
define_attribute          {pci_66} xc_padtype {ibuf_pci33_3}
define_attribute -disable {pci_irdy_n} xc_nodelay {1}
define_attribute -disable {pci_frame_n} xc_nodelay {1}
define_attribute -disable {pci_gnt_in_n} xc_nodelay {1}
define_attribute -disable {pci_stop_n} xc_nodelay {1}
define_attribute -disable {pci_rst_in_n} xc_nodelay {1}
define_attribute -disable {pci_trdy_n} xc_nodelay {1}
