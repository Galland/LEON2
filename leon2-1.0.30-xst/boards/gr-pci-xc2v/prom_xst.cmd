setPreference -pref UserLevel:NOVICE
setPreference -pref MessageLevel:DETAILED
setPreference -pref ConcurrentMode:FALSE
setPreference -pref UseHighz:FALSE
setPreference -pref ConfigOnFailure:STOP
setPreference -pref StartupCLock:AUTO_CORRECTION
setPreference -pref AutoSignature:FALSE
setPreference -pref KeepSVF:FALSE
setPreference -pref svfUseTime:FALSE
setPreference -pref UserLevel:NOVICE
setPreference -pref MessageLevel:DETAILED
setPreference -pref ConcurrentMode:FALSE
setPreference -pref UseHighz:FALSE
setPreference -pref ConfigOnFailure:STOP
setPreference -pref StartupCLock:AUTO_CORRECTION
setPreference -pref AutoSignature:FALSE
setPreference -pref KeepSVF:FALSE
setPreference -pref svfUseTime:FALSE
setMode -bs
setPreference -pref UserLevel:Novice
setMode -pff
addConfigDevice -size 0 -name "xc18v04" -path "./"
setAttribute -configdevice -attr size -value "0"
setAttribute -configdevice -attr reseveSize -value "0"
setSubmode -pffserial
setAttribute -configdevice -attr activeCollection -value "leon_eth_pci_xst"
addCollection -name "leon_eth_pci_xst"
addDesign -version 0 -name "0"
addDeviceChain -index 0
addDevice -position 1 -file "leon_eth_pci_xst.bit"

addPromDevice -position 1 -size 0 -name "xc18v04"
addPromDevice -position 2 -size 0 -name "xc18v04"
addPromDevice -position 3 -size 0 -name "xc18v04"
setAttribute -configdevice -attr fileFormat -value "mcs"
setAttribute -configdevice -attr swapBit -value "FALSE"
setAttribute -configdevice -attr fillValue -value "FF"
setAttribute -collection -attr dir -value "UP"
setMode -mpm
setMode -cf
setMode -dtconfig
setMode -bsfile
setMode -sm
setMode -ss
setMode -bs
setCable -port parport0
setMode -pff
setMode -bs
setMode -ss
setMode -sm
setMode -bsfile
setMode -dtconfig
setMode -cf
setMode -mpm
setMode -pff
setCurrentDeviceChain -index 0
setMode -pff
setMode -pff
setAttribute -configdevice -attr fillValue -value "FF"
setAttribute -configdevice -attr fileFormat -value "mcs"
setAttribute -collection -attr dir -value "UP"
setAttribute -configdevice -attr path -value "./"
setAttribute -collection -attr name -value "leon_eth_pci_xst"
generate
setCurrentDesign -version 0
setCurrentDesign -version 0
setMode -bs
setPreference -pref UserLevel:Novice
setMode -pff
setMode -mpm
setMode -cf
setMode -dtconfig
setMode -bsfile
setMode -sm
setMode -ss
setMode -bs
addDevice -position 1 -part "xc18v04"
setAttribute -position 1 -attr configFileName -value "leon_eth_pci_xst_0.mcs"

addDevice -position 2 -part "xc18v04"
setAttribute -position 2 -attr configFileName -value "leon_eth_pci_xst_1.mcs"

addDevice -position 3 -part "xc18v04"
setAttribute -position 3 -attr configFileName -value "leon_eth_pci_xst_2.mcs"

addDevice -position 4 -part "xc2v3000"
addDevice -position 5 -part "971A_lqfp.bsd"

setCable -port parport0
setMode -bs
setMode -bs
setMode -ss
setMode -sm
setMode -bsfile
setMode -dtconfig
setMode -cf
setMode -mpm
setMode -pff
setMode -bs
Program -p 1 2 3 -e -v 
