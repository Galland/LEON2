onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tbleon/tb/p2/leon0/resetn
add wave -noupdate -format Logic /tbleon/tb/p2/leon0/clk
add wave -noupdate -format Logic /tbleon/tb/p2/leon0/errorn
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/sa
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/sd
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/address
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/data
add wave -noupdate -format Literal /tbleon/tb/p2/leon0/ramsn
add wave -noupdate -format Literal /tbleon/tb/p2/leon0/ramoen
add wave -noupdate -format Literal /tbleon/tb/p2/leon0/rwen
add wave -noupdate -format Literal /tbleon/tb/p2/leon0/romsn
add wave -noupdate -format Logic /tbleon/tb/p2/leon0/iosn
add wave -noupdate -format Logic /tbleon/tb/p2/leon0/oen
add wave -noupdate -format Logic -radix hexadecimal /tbleon/tb/p2/leon0/sdclk
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/sdcsn
add wave -noupdate -format Logic -radix hexadecimal /tbleon/tb/p2/leon0/sdwen
add wave -noupdate -format Logic -radix hexadecimal /tbleon/tb/p2/leon0/sdrasn
add wave -noupdate -format Logic -radix hexadecimal /tbleon/tb/p2/leon0/sdcasn
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/sddqm
add wave -noupdate -format Logic /tbleon/tb/p2/leon0/read
add wave -noupdate -format Logic /tbleon/tb/p2/leon0/writen
add wave -noupdate -format Logic /tbleon/tb/p2/leon0/brdyn
add wave -noupdate -format Logic /tbleon/tb/p2/leon0/bexcn
add wave -noupdate -format Literal /tbleon/tb/p2/leon0/pio
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/memi
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/memo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ioi
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ioo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/apbi
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/apbo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ahbmi
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ahbmo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ahb0/r
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ahbsi
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ahbso
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/ici
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/ico
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/dci
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/dco
add wave -noupdate -format Literal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/fecomb
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/fe
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/de
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/ex
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/me
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/wr
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/sregs
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/fpu_reg
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/fpui
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/fpuo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/uart1/r
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/uart2/r
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/irqctrl0/ir
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ioport0/r
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/timers0/r
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/uart1/apbi
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/uart1/apbo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/uart2/apbi
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/uart2/apbo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/apb0/r
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/rfi
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/rfo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/muli
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/mulo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/divi
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/divo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/tr
add wave -noupdate -format Logic -radix hexadecimal /tbleon/tb/p2/leon0/dsuen
add wave -noupdate -format Logic -radix hexadecimal /tbleon/tb/p2/leon0/dsubre
add wave -noupdate -format Logic -radix hexadecimal /tbleon/tb/p2/leon0/dsuact
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/iu0/dsur
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ahb0/msti
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ahb0/msto
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/ahb0/r
add wave -noupdate -format Logic /tbleon/tb/p2/leon0/sdclk
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/mctrl0/sdo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/mctrl0/mctrlo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/mctrl0/r
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/crami
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/cramo
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/cx/c0/dcache0/r
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/cx/c0/dcache0/rs
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/cx/c0/dcache0/rh
add wave -noupdate -format Literal -radix hexadecimal /tbleon/tb/p2/leon0/mcore0/proc0/cx/c0/dcache0/rl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {63886123 ps} {548912000 ps}
WaveRestoreZoom {318300180 ps} {319262087 ps}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
