LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.math_real.all;

ENTITY micro_Instruction_decoder IS

	PORT(	
	     	micro_instruction  : IN std_logic_vector(19 DOWNTO 0);
		BO0, BO1, BO2, BO3, BO4, next_address_enable, IR_decoder_enable : OUT std_logic;
            	PC_out, MDR_out, Z_out, R_src_out, R_dst_out, SRC_out, IR_out  : OUT std_logic;
		PC_in, MDR_in, Z_in, R_src_in, R_dst_in, SRC_in, IR_in, MAR_in, Y_in : OUT std_logic;
		ALU_inc, ALU_dec, ALU_add, ALU_op : OUT std_logic;
		RD, WR, SRC_clear : OUT std_logic;
		next_address : OUT std_logic_vector(4 DOWNTO 0)
	    );

END ENTITY micro_Instruction_decoder;

ARCHITECTURE micro_Instruction_decoder_arch of micro_Instruction_decoder IS

COMPONENT decoder
GENERIC (selection_line_width : integer := 2);
	PORT(	
		enable           : IN std_logic;
	     	selection_lines  : IN std_logic_vector(selection_line_width DOWNTO 0);
            	output           : OUT std_logic_vector((2 ** selection_line_width) - 1 DOWNTO 0)
	    );

END COMPONENT;
 
-- Temp Signals for the decoder output
SIGNAL group1_decoder_output, group2_decoder_output, group3_decoder_output: std_logic_vector(7 DOWNTO 0);
SIGNAL group4_decoder_output, group5_decoder_output, group6_decoder_output: std_logic_vector(3 DOWNTO 0);

-- Dummy signals for No operation 
SIGNAL no_operation, group4_dummy : std_logic;

BEGIN
	-- Group 0 => Next address field
	Group0: next_address <= micro_instruction(19 DOWNTO 15);
	
	-- Group 1 => How to get the next address
	Group1:   decoder GENERIC MAP(selection_line_width => 3) 
				PORT MAP('1', micro_instruction(14 DOWNTO 12), output => group1_decoder_output);
	(no_operation, next_address_enable, IR_decoder_enable, BO4, BO3, BO2, BO1, BO0) <= group1_decoder_output;
	
	-- Group 2 => out Signals
	Group2:   decoder GENERIC MAP(selection_line_width => 3) 
				PORT MAP('1', micro_instruction(11 DOWNTO 9), group2_decoder_output);
	(no_operation, IR_out, SRC_out, R_dst_out, R_src_out, Z_out, MDR_out, PC_out)  <= group2_decoder_output;

	-- Group 3 => in Signals
	Group3:   decoder GENERIC MAP(selection_line_width => 3) 
				PORT MAP('1', micro_instruction(8 DOWNTO 6), group3_decoder_output);
	(no_operation, PC_in, IR_in, MDR_in, Y_in, MAR_in, SRC_in, R_src_in)  <= group3_decoder_output;

	-- Group 4 => in Signals 2
	Group4:   decoder GENERIC MAP(selection_line_width => 2) 
				PORT MAP('1', micro_instruction(5 DOWNTO 4), group4_decoder_output);
	(no_operation, group4_dummy, R_dst_in, Z_in)  <= group4_decoder_output;

	-- Group 5 => Alu Operations
	Group5:   decoder GENERIC MAP(selection_line_width => 2) 
				PORT MAP('1', micro_instruction(3 DOWNTO 2), group5_decoder_output);
	(ALU_op, ALU_add, ALU_dec, ALU_inc) <= group5_decoder_output;

	-- Group 6 => Memory Signals & Extra signal to clear the SRC register
	Group6:   decoder GENERIC MAP(selection_line_width => 2) 
				PORT MAP('1', micro_instruction(1 DOWNTO 0), group6_decoder_output);
	(no_operation, SRC_clear, WR, RD) <= group6_decoder_output;

END micro_Instruction_decoder_arch;
