
EFFORT=3
DEVICE=xcv1000e-fg1156-6

all:
	@if test "$(SYN)" = "synplify"; then make avsyn; \
	 else make avxst; fi;

help:
	@echo
	@echo " choose one of following targets:"
	@echo
	@echo " make all        : synthesis and place&route "
	@echo " make clean      : remove all temporary files except config and fpga bitfiles"
	@echo " make dist-clean : remove all temporary files"
	@echo 
	@echo " XST is used by default, to use Synplify do 'make SYN=synplify'" 
	@echo 


avxst:
	@pci=`grep pcicore ../../leon/device.vhd | awk '{print $$3}'` ; \
	eth=`grep ethen ../../leon/device.vhd | awk '{print $$12}'` ; \
	if test "$$pci" = "opencores"; then make pci_bridge32.ngc; fi; \
	if test "$$eth" != "false"; then make eth_top.ngc ; fi; \
	if test "$$pci" = "none"; then \
	  if test "$$eth" = "false"; then \
	    echo " making leon_xst.bit" ; \
	    make leon_xst.bit; \
	  else \
	    echo " making leon_eth_xst.bit" ; \
	    make leon_eth_xst.bit; \
	  fi; \
	else \
	  if test "$$eth" = "false"; then \
	    echo " making leon_pci_xst.bit" ; \
	    make leon_pci_xst.bit; \
	  else \
	    echo " making leon_eth_pci_xst.bit" ; \
	    make leon_eth_pci_xst.bit; \
	  fi; \
	fi;
	

avsyn:
	@pci=`grep pcicore ../../leon/device.vhd | awk '{print $$3}'` ; \
	eth=`grep ethen ../../leon/device.vhd | awk '{print $$12}'` ; \
	if test "$$pci" = "none"; then \
	  if test "$$eth" = "false"; then \
	    echo " making leon.bit" ; \
	    make leon.bit; \
	  else \
	    echo " making leon_eth.bit" ; \
	    make leon_eth.bit; \
	  fi; \
	else \
	  if test "$$eth" = "false"; then \
	    echo " making leon_pci.bit" ; \
	    make leon_pci.bit; \
	  else \
	    echo " making leon_eth_pci.bit" ; \
	    make leon_eth_pci.bit; \
	  fi; \
	fi;
	

leon.edf: ../../leon/device.vhd ../../leon/device.v
	synplify -batch leon.prj

leon_eth.edf: ../../leon/device.vhd ../../leon/device.v
	synplify -batch leon_eth.prj

leon_pci.edf: ../../leon/device.vhd ../../leon/device.v
	synplify -batch leon_pci.prj

leon_eth_pci.edf: ../../leon/device.vhd ../../leon/device.v
	synplify -batch leon_eth_pci.prj

eth_top.ngc: ../../leon/eth_top.v ../../leon/device.v
	../../syn/ise/xstmod eth_top ../../syn/verilog/ethermac.v  $(DEVICE) > xst.scr
	xst -ifn xst.scr

pci_bridge32.ngc: ../../leon/pci_top.v ../../leon/device.v
	../../syn/ise/xstmod pci_bridge32 ../../syn/verilog/pcibridge.v  $(DEVICE) > xst.scr
	xst -ifn xst.scr

leon.ngc: ../../leon/device.vhd
	-rm -rf xst
	xst -ifn ../../syn/ise/leon.xst
	../../syn/ise/xstrun leon ../../leon/leon.vhd  $(DEVICE) > xst.scr
	xst -ifn xst.scr

leon_pci.ngc: ../../leon/device.vhd
	-rm -rf xst
	xst -ifn ../../syn/ise/leon.xst
	../../syn/ise/xstrun leon_pci ../../leon/leon_pci.vhd  $(DEVICE) > xst.scr
	xst -ifn xst.scr

leon_eth.ngc: ../../leon/device.vhd
	-rm -rf xst
	xst -ifn ../../syn/ise/leon.xst
	../../syn/ise/xstrun leon_eth ../../leon/leon_eth.vhd  $(DEVICE) -uc leon_eth.xcf > xst.scr
	xst -ifn xst.scr

leon_eth_pci.ngc: ../../leon/device.vhd
	-rm -rf xst
	xst -ifn ../../syn/ise/leon.xst
	../../syn/ise/xstrun leon_eth_pci ../../leon/leon_eth_pci.vhd  $(DEVICE) -uc leon_eth_pci.xcf > xst.scr
	xst -ifn xst.scr

leon_xst.bit: leon.ngc
	../../syn/ise/route_ngc leon leon.ucf $(DEVICE) $(EFFORT)

leon_pci_xst.bit: leon_pci.ngc
	../../syn/ise/route_ngc leon_pci leon_pci.ucf $(DEVICE) $(EFFORT)

leon_eth_xst.bit: leon_eth.ngc
	../../syn/ise/route_ngc leon_eth leon_eth.ucf $(DEVICE) $(EFFORT)

leon_eth_pci_xst.bit: leon_eth_pci.ngc
	../../syn/ise/route_ngc leon_eth_pci leon_eth_pci.ucf $(DEVICE) $(EFFORT)

leon.bit: leon.edf
	../../syn/ise/route leon leon.ucf $(DEVICE) $(EFFORT)

leon_eth.bit: leon_eth.edf
	../../syn/ise/route leon_eth leon_eth.ucf $(DEVICE) $(EFFORT)

leon_pci.bit: leon_pci.edf
	../../syn/ise/route leon_pci leon_pci.ucf $(DEVICE) $(EFFORT)

leon_eth_pci.bit: leon_eth_pci.edf
	../../syn/ise/route leon_eth_pci leon_eth_pci.ucf $(DEVICE) $(EFFORT)

clean:
	-rm -rf *.ngc *.bgn *.bld *.dly *.drc *.ll *.mrp *.msk *.ncd *.ngd \
	*.ngm *.pad *.par *.pcf *.srp *.twr *.xpi *.nav *.lst *.scr \
	xst *.tlg *.log *.srs *.srr *.plg *.fse *.vhm *.srm *.srd *.edf *.edn \
	*.prd *.ngo *.jhd __projnav*

dist-clean: clean
	-rm -f *.bit
