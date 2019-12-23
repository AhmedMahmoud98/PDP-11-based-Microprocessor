LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY RD_signal IS
	   PORT( RD_in, is_MOV, PC_out, is_SRC: IN std_logic;
		 IR_DST_addressing_mode: IN std_logic_vector(2 DOWNTO 0);
		 RD_out: OUT std_logic
		);
END ENTITY RD_signal;

ARCHITECTURE RD_signal_arch OF RD_signal IS
BEGIN
	RD_out <= (RD_in) AND 
	           NOT((is_MOV) 
		   AND NOT((PC_out) OR (is_SRC) 
		   OR ((IR_DST_addressing_mode(0)) 
		   AND ((IR_DST_addressing_mode(1)) OR (IR_DST_addressing_mode(2))
		   ))));
END;