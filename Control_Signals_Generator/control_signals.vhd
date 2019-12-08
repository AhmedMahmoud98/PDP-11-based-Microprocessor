LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.math_real.all;

ENTITY control_signals IS

	PORT(	
	     	address  : IN std_logic_vector(4 DOWNTO 0);

		BO0, BO1, BO2, BO3, BO4, next_address_enable, IR_decoder_enable : OUT std_logic;
            	PC_out, MDR_out, Z_out, R_src_out, R_dst_out, SRC_out, IR_out  : OUT std_logic;
		PC_in, MDR_in, Z_in, R_src_in, R_dst_in, SRC_in, IR_in, MAR_in, Y_in : OUT std_logic;
		ALU_inc, ALU_dec, ALU_add, ALU_op : OUT std_logic;
		RD, WR, SRC_clear : OUT std_logic;
		next_address : OUT std_logic_vector(4 DOWNTO 0)
	    );

END ENTITY control_signals;

ARCHITECTURE control_signals_arch of control_signals IS
-- Control Store
COMPONENT ROM 

	PORT(   
                address : IN  std_logic_vector(4 DOWNTO 0);
		micro_instruction : OUT std_logic_vector(19 DOWNTO 0)
	    );

END COMPONENT;

-- MicroInstruction Decoder
COMPONENT micro_Instruction_decoder
	
	PORT(	
	     	micro_instruction  : IN std_logic_vector(19 DOWNTO 0);
		BO0, BO1, BO2, BO3, BO4, next_address_enable, IR_decoder_enable : OUT std_logic;
            	PC_out, MDR_out, Z_out, R_src_out, R_dst_out, SRC_out, IR_out  : OUT std_logic;
		PC_in, MDR_in, Z_in, R_src_in, R_dst_in, SRC_in, IR_in, MAR_in, Y_in : OUT std_logic;
		ALU_inc, ALU_dec, ALU_add, ALU_op : OUT std_logic;
		RD, WR, SRC_clear : OUT std_logic;
		next_address : OUT std_logic_vector(4 DOWNTO 0)
	    );

END COMPONENT;

SIGNAL micro_intruction_temp : std_logic_vector(19 DOWNTO 0);

BEGIN
	fetch_micro_instruction:  ROM PORT MAP(address, micro_intruction_temp);
 
	dedcode_micro_instruction: micro_Instruction_decoder PORT MAP(micro_intruction_temp, BO0, BO1, BO2, BO3, BO4, 
									next_address_enable, IR_decoder_enable, 
            								PC_out, MDR_out, Z_out, R_src_out, R_dst_out, SRC_out, IR_out ,
									PC_in, MDR_in, Z_in, R_src_in, R_dst_in, SRC_in, IR_in, MAR_in, Y_in ,
									ALU_inc, ALU_dec, ALU_add, ALU_op, RD, WR, SRC_clear, next_address); 
END control_signals_arch;
