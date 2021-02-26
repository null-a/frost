set -e
iverilog -y . -o isa_tb.vvp -DISA_TEST=\"$1\" isa_tb.v
vvp -n isa_tb.vvp
