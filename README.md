# FIR-IIR

uses Icaurus verilog

$env:Path += ";C:\iverilog\bin"                     #maybe

python py/gen_coeff.py

iverilog -g2012 -o testbench/fir_tb.vvp fir_filter.v testbench/fir_tb.v

iverilog -g2012 -o testbench/iir_tb.vvp iir_filter.v testbench/iir_tb.v

vvp testbench/iir_tb.vvp > iir_debug_output.txt     #maybe

python py/check_output.py