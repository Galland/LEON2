
EFFORT=3
DEVICE=xcv800-hq240-4

all:
	@if test "$(SYN)" = "synplify"; then make grsyn; \
	else make grxst; fi;

help:
	@echo
	@echo " choose one of following targets:"
	@echo
	@echo " make all        : synthesis and place&route"
	@echo " make clean      : remove all temporary files except config and fpga bitfiles"
	@echo " make dist-clean : remove all temporary files"
	@echo 
	@echo " XST is used by default, to use Synplify do 'make SYN=synplify'"
	@echo 


grxst:
	@pci=`grep pcicore ../../leon/device.vhd | awk '{print $$3}'` ; \
	eth=`grep ethen ../../leon/device.vhd | awk '{print $$12}'` ; \
	if test "$$pci" != "none"; then \
	  echo " ERROR: PCI is not supported for XSV800 " ; \
	  exit 2; \
	fi; \
	if test "$$eth" != "false"; then make eth_top.ngc ; fi; \
	if test "$$eth" = "false"; then \
	  echo " making leon_xsv800_xst.bit" ; \
	  make leon_xsv800_xst.bit; \
	else \
	  echo " making leon_eth_xsv800_xst.bit" ; \
	  make leon_eth_xsv800_xst.bit; \
	fi; \

grsyn:
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
	  echo " ERROR: PCI is not supported for XSV800 " ; \
	  exit 2; \
	fi;

leon.edf: ../../leon/device.vhd ../../leon/device.v
	synplify_pro -batch leon.prj

leon_eth.edf: ../../leon/device.vhd ../../leon/device.v
	synplify_pro -batch leon_eth.prj

eth_top.ngc: ../../leon/eth_top.v ../../leon/device.v
	../../syn/ise/xstmod eth_top ../../syn/verilog/ethermac.v  $(DEVICE) > xst.scr
	xst -ifn xst.scr

leon_xsv800.ngc: ../../leon/device.vhd
	-rm -rf xst
	xst -ifn ../../syn/ise/leon.xst
	xst -ifn leon.xst
	../../syn/ise/xstrun leon_xsv800 leon_xsv800.vhd  $(DEVICE) > xst.scr
	xst -ifn xst.scr

leon_eth_xsv800.ngc: ../../leon/device.vhd
	-rm -rf xst
	xst -ifn ../../syn/ise/leon.xst
	xst -ifn leon.xst
	../../syn/ise/xstrun leon_eth_xsv800 leon_eth_xsv800.vhd  $(DEVICE) > xst.scr
	xst -ifn xst.scr

leon_xsv800_xst.bit: leon_xsv800.ngc
	../../syn/ise/route_ngc leon_xsv800 leon.ucf $(DEVICE) $(EFFORT)

leon_eth_xsv800_xst.bit: leon_eth_xsv800.ngc
	../../syn/ise/route_ngc leon_eth_xsv800 leon_eth.ucf $(DEVICE) $(EFFORT)


leon.bit: leon.edf
	../../syn/ise/route leon leon.ucf $(DEVICE) $(EFFORT)

leon_eth.bit: leon_eth.edf
	../../syn/ise/route leon_eth leon_eth.ucf $(DEVICE) $(EFFORT)

clean:
	-rm -rf *.ngc *.bgn *.bld *.dly *.drc *.ll *.mrp *.msk *.ncd *.ngd \
	*.ngm *.pad *.par *.pcf *.srp *.twr *.xpi *.nav *.lst *.scr \
	xst *.tlg *.log *.srs *.srr *.plg *.fse *.vhm *.srm *.srd *.edf *.edn \
	*.prd *.ngo *.jhd __projnav* .recordref

dist-clean: clean
	-rm -f *.bit
