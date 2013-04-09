
EFFORT=3
DEVICE=xcv800-hq240-6

all:
	xst -ifn leon.xst

clean:
	-rm -rf *.ngc *.bgn *.bld *.dly *.drc *.ll *.mrp *.msk *.ncd *.ngd \
	*.ngm *.pad *.par *.pcf *.srp *.twr *.xpi *.nav *.lst *.scr \
	xst *.tlg *.log *.srs *.srr *.plg *.fse *.vhm *.srm *.srd *.edf *.edn \
	*.prj *.prd *.ngo *.jhd __projnav*

dist-clean: clean
	-rm -f *.bit
