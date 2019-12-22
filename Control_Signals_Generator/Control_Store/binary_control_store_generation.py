import numpy as np
control_store_file = open("control_store.txt", "r")

control_store = [line.rstrip() for line in control_store_file]
control_store_data = [line.split(", ") for line in control_store] 

groups = { 
           2: [("PC_out", "000"), ("MDR_out", "001"), ("Z_out", "010"), ("R_src_out", "011"),
               ("R_dst_out", "100"), ("SRC_out", "101"), ("IR_out", "110"), ("DUMMY", "111")],
           
           3: [("R_src_in", "000"), ("SRC_in", "001"), ("MAR_in", "010"), ("Y_in", "011"),
               ("MDR_in", "100"), ("IR_in", "101"), ("PC_in", "110"), ("DUMMY", "111")],
           
           4: [("Z_in", "00"), ("R_dst_in", "01"), ("DUMMY", "11")],
           5: [("ALU_inc", "00"), ("ALU_dec", "01"), ("ALU_add", "10"), ("ALU_op", "11"),
               ("DUMMY", "00")],
               
           6: [("RD", "00"), ("WR", "01"), ("SRC_clear", "10"), ("DUMMY", "11")]
         }

control_store_binary = { 
                         0:["11000", "010"],   1:["01011", "110"], 
                         2:["01010", "110"],   3:["00110", "110"],
                         4:["10110", "110"],   5:["00000", "000"],
                         6:["00111", "110"],   7:["01000", "110"],
                         8:["01001", "110"],   9:["11000", "001"],
                         10:["11000", "001"],  11:["11000", "001"],
                         12:["10010", "110"],  13:["01110", "110"],
                         14:["01111", "110"],  15:["10010", "110"],
                         16:["10010", "110"],  17:["10010", "110"],
                         18:["10011", "110"],  19:["10100", "110"],
                         20:["00000", "101"],  21:["00000", "000"],
                         22:["10000", "100"],  23:["00000", "111"], 
                         24:["10110", "110"],  25:["11000", "011"],
                         26:["10010", "110"],  27:["11010", "110"],
                         28:["00000", "000"],  29:["00000", "111"],
                         30:["00000", "111"],  31:["00000", "111"]
                        }
                            
found_in_group = False
for line_number in range(32):
    for group in groups:
        for control_signal in control_store_data[line_number]:
            required_binary = [item[1] for idx , item in enumerate(groups[group]) if groups[group][idx][0] == control_signal]
            
            if(len(required_binary) != 0):
                found_in_group = True
                control_store_binary[line_number].append(required_binary[0])
                break
            
        if(not found_in_group):
            group_length = len(groups[group])
            control_store_binary[line_number].append(groups[group][group_length - 1][1])
        found_in_group = False
            

control_store_binary_file = open("control_store_binary.txt", "w")

for line in control_store_binary:
    line_binary = ' '.join(map(str, control_store_binary[line])) 
    control_store_binary_file.write(line_binary + "\n")
    
  
                 
                 