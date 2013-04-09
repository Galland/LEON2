cd leon
do compile.bat
cd ../tbench
do compile.bat
cd ..
echo ""
echo " LEON model id compiled. Run the test bench with the following commanad:"
echo ""
echo " vsim tb_func32 -do \"run -all\" "
