set -e
iverilog -y . -o cpu_tb.vvp -DISA_TEST=\"$1\" cpu_tb.v
vvp -n cpu_tb.vvp
