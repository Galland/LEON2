onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_msp/clk
add wave -noupdate -format Logic /tb_msp/rst
add wave -noupdate -format Literal -radix hexadecimal /tb_msp/address
add wave -noupdate -format Literal -radix hexadecimal /tb_msp/data
add wave -noupdate -format Literal -expand /tb_msp/ramsn
add wave -noupdate -format Literal /tb_msp/ramoen
add wave -noupdate -format Literal /tb_msp/wrn
add wave -noupdate -format Literal /tb_msp/romsn
add wave -noupdate -format Logic /tb_msp/iosn
add wave -noupdate -format Logic /tb_msp/oen
add wave -noupdate -format Logic /tb_msp/read
add wave -noupdate -format Logic /tb_msp/write
add wave -noupdate -format Logic /tb_msp/brdyn
add wave -noupdate -format Logic /tb_msp/bexcn
add wave -noupdate -format Logic /tb_msp/error
add wave -noupdate -format Logic /tb_msp/wdog
add wave -noupdate -format Logic /tb_msp/dsuen
add wave -noupdate -format Logic /tb_msp/dsutx
add wave -noupdate -format Logic /tb_msp/dsurx
add wave -noupdate -format Logic /tb_msp/dsubre
add wave -noupdate -format Logic /tb_msp/dsuact
add wave -noupdate -format Logic /tb_msp/test
add wave -noupdate -format Literal /tb_msp/pio
add wave -noupdate -format Logic /tb_msp/gnd
add wave -noupdate -format Logic /tb_msp/vcc
add wave -noupdate -format Logic /tb_msp/nc
add wave -noupdate -format Literal /tb_msp/sdcke
add wave -noupdate -format Literal /tb_msp/sdcsn
add wave -noupdate -format Logic /tb_msp/sdwen
add wave -noupdate -format Logic /tb_msp/sdrasn
add wave -noupdate -format Logic /tb_msp/sdcasn
add wave -noupdate -format Literal /tb_msp/sddqm
add wave -noupdate -format Logic /tb_msp/sdclk
add wave -noupdate -format Logic /tb_msp/plllock
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {16290249 ps}
WaveRestoreZoom {2007769 ps} {2759592 ps}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
