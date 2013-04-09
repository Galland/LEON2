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
setMode -pff
setMode -pff
setMode -pff
addConfigDevice -size 512 -name "xcf04s" -path "/home/jiri/ibm/vhdl/leon2-1.0.28-xst/boards/gr-xc3s1500/"
setSubmode -pffserial
addPromDevice -position 1 -size -1 -name "xcf04s"
addPromDevice -position 2 -size -1 -name "xcf01s"
setMode -pff
setSubmode -pffserial
setAttribute -configdevice -attr size -value "0"
addCollection -name "leon_eth"
setAttribute -collection -attr dir -value "UP"
addDesign -version 0 -name "0000"
addDeviceChain -index 0
addDevice -position 1 -file "/home/jiri/ibm/vhdl/leon2-1.0.28-xst/boards/gr-xc3s1500/leon_eth.bit"
setMode -pff
setAttribute -configdevice -attr fillValue -value "FF"
setAttribute -configdevice -attr fileFormat -value "mcs"
setAttribute -collection -attr dir -value "UP"
setAttribute -configdevice -attr path -value "/home/jiri/ibm/vhdl/leon2-1.0.28-xst/boards/gr-xc3s1500/"
setAttribute -collection -attr name -value "leon_eth"
generate
setCurrentDesign -version 0
setMode -bs
setCable -port auto
Identify
setAttribute -position 1 -attr devicePartName -value "xcf04s"
setAttribute -position 1 -attr configFileName -value "/home/jiri/ibm/vhdl/leon2-1.0.28-xst/boards/gr-xc3s1500/leon_eth_0.mcs"
setAttribute -position 2 -attr devicePartName -value "xcf04s"
setAttribute -position 2 -attr configFileName -value "/home/jiri/ibm/vhdl/leon2-1.0.28-xst/boards/gr-xc3s1500/leon_eth_1.mcs"
Program -p 1 2 -e -v 
