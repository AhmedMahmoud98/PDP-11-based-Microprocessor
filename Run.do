# Initialization
#delete wave *
#add wave *

# Monitor registers
add wave /cpu/u4/r7/reg_out
add wave /cpu/u4/registers_loop(6)/rx/reg_out
add wave /cpu/u4/registers_loop(5)/rx/reg_out
add wave /cpu/u4/registers_loop(4)/rx/reg_out
add wave /cpu/u4/registers_loop(3)/rx/reg_out
add wave /cpu/u4/registers_loop(2)/rx/reg_out
add wave /cpu/u4/registers_loop(1)/rx/reg_out
add wave /cpu/u4/registers_loop(0)/rx/reg_out#add wave /cpu/u1/SRC_reg/reg_out

add wave /cpu/u8/SRC_OUT
add wave /cpu/u5/ALU_Result
# Monitor RAM
add wave /cpu/u6/RAM_data

force -deposit /CLK 1 0, 0 50 -r 100
force -deposit /RST 1
run 100
force -deposit /RST 0
run 1000000