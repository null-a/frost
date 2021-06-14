set -e
iverilog -I ../src -y ../src -y . -o top_tb.vvp -DSIM -DFW=\"firmware/$1/fw.hex\" top_tb.v
vvp -n top_tb.vvp
