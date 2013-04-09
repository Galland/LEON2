CONFIG = default
VLIB = vlib
VCOM = vcom
VSIM = vsim
BOARD = gr-pci-xc2v
NCVHPAR = -nocopyright 
NCVLPAR = -nocopyright
NCELPAR = -nocopyright
GHDLPAR = --ieee=synopsys 

all:
	@echo
	@echo " choose one of following targets:"
	@echo
	@echo " make xgates     : compile Xilinx gate level models with modelsim"
	@echo " make vsim       : compile simulation model with modelsim"
	@echo " make ncsim      : compile simulation model with ncsim"
	@echo " make vss        : compile simulation model with synopsys-vss"
	@echo " make test       : run tb_func32 testbench with modelsim simulator"
	@echo " make config     : configure VHDL model for the GR-PCI-XC2V fpga board"
	@echo " make xconfig    : run the graphical configuration tool"
	@echo " make fpga       : do synthesis and p&r for the GR-PCI-XC2V fpga board"
	@echo " make clean      : remove all temporary files except config and fpga bitfiles"
	@echo " make dist-clean : remove all temporary files"
	@echo 
	@echo " To target other fpga boards than the GR-PCI-XC2V, add BOARD=xxx"
	@echo " where xxx is one of gr-pci-xc2v, gr-cpci-xc2v, avnet-xcv1000e," 
	@echo " gr-xc3s1500, tiggeler-xcv800, hecht-xsv800 or billo-mblaze-xc2v"
	@echo 
	@echo " When synthesising for Virtex fpga's, Xilinx XST is used by default."
	@echo " To use Synplify, add parameter SYN=synplify. Place&route effort is" 
	@echo " by default std, but can be set through the EFFORT parameter. The CONFIG" 
	@echo " parameter can be used to specify alternative model configurations." 
	@echo 
	@echo " Examples: "
	@echo "           make config fpga EFFORT=high CONFIG=60mhz" 
	@echo "           make config fpga BOARD=avnet-xcv1000e SYN=synplify EFFORT=med" 
	@echo 

xgates:
	cd leon; make xlib

vsim:
	cd leon; make
	cd tbench; make

ncsim:
	cd leon; make VCOM="ncvhdl $(NCVHPAR) -work work" \
	VLOG="ncvlog $(NCVLPAR) -work work" VLIB=mkdir
	cd tbench; make VCOM="ncvhdl $(NCVHPAR) -work work" \
	VLOG="ncvlog $(NCVLPAR) -work work" VLIB=mkdir
	ncelab $(NCELPAR) tb_func32

ghdl:
	cd leon; make VCOM="ghdl -a $(GHDLPAR) --workdir=work" \
	VLOG="echo no verilog support:" VLIB=mkdir
	cd tbench; make VCOM="ghdl -a $(GHDLPAR) --workdir=../leon/work" \
	VLOG="echo no verilog support:" VLIB=mkdir 
	ghdl -e $(GHDLPAR) --workdir=leon/work tb_func32

vss:
	cd leon; make VCOM="vhdlan -nc -interp" VLIB="mkdir"
	cd tbench; make VCOM="vhdlan -nc -interp" VLIB="mkdir"

test: vsim
	$(VSIM) -quiet -c tb_func32 -do "run -all"
dep:
	cd tkconfig; make dep
wconfig:
	cd tkconfig; make wconfig
xconfig:
	cd tkconfig; make xconfig
tsoft: 
	cd tsource; make
pci: 
	make vsim
	cd tbpci; ./core.bat
fpga:
	cd boards/$(BOARD); make all
config:
	cp boards/$(BOARD)/config-$(CONFIG) tkconfig/.config 
	make dep
clean:
	cd boards; make clean
	cd leon; make clean
	cd tbench; make clean
	cd tsource; make clean
	cd tkconfig; make clean
	cd syn; make clean
	-rm -rf dumpdata.txt trnscrpt transcript vsim.wlf vsim.wav \
	tbpci/actelpci_lib  tbpci/adpms_lib */nc*.log nc*.log \
	tb_*

dist-clean: clean
	cd tkconfig; make dist-clean
	cd boards; make dist-clean
