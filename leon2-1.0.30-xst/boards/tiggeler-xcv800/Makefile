
EFFORT=3
DEVICE=xcv800-hq240-6

all:
	@if test "$(SYN)" = "synplify"; then make leon.bit; else make leon_xst.bit; fi;

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

leon.edf: ../../leon/device.vhd ../../leon/device.v
	synplify -batch leon.prj

leon.ngc: ../../leon/device.vhd
	-rm -rf xst
	xst -ifn ../../syn/ise/leon.xst
	../../syn/ise/xstrun leon ../../leon/leon.vhd  $(DEVICE) > xst.scr
	xst -ifn xst.scr

leon_xst.bit: leon.ngc
	../../syn/ise/route_ngc leon leon.ucf $(DEVICE) $(EFFORT)

leon.bit: leon.edf
	../../syn/ise/route leon leon.ucf $(DEVICE) $(EFFORT)

clean:
	-rm -rf *.ngc *.bgn *.bld *.dly *.drc *.ll *.mrp *.msk *.ncd *.ngd \
	*.ngm *.pad *.par *.pcf *.srp *.twr *.xpi *.nav *.lst *.scr \
	xst *.tlg *.log *.srs *.srr *.plg *.fse *.vhm *.srm *.srd *.edf *.edn \
	*.prd *.ngo *.jhd __projnav*

dist-clean: clean
	-rm -f *.bit
