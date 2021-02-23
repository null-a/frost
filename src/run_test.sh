set -e
cp ../tests/$1.hex ./tmp.hex
iverilog -y . -o cpu_tb.vvp cpu_tb.v
vvp -n cpu_tb.vvp
rm tmp.hex cpu_tb.vvp
