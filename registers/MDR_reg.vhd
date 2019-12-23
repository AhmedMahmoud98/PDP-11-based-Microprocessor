LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY MDR_reg IS
	GENERIC (size : integer := 16);
	PORT(CLK, RST, enable, is_falling : IN std_logic;
		 D : IN std_logic_vector(size-1 DOWNTO 0);
		 Q : OUT std_logic_vector(size-1 DOWNTO 0));
END ENTITY MDR_reg;

ARCHITECTURE MDR_reg_arch OF MDR_reg IS
BEGIN
	PROCESS(CLK, RST, enable, is_falling)
	BEGIN
		IF(RST = '1') THEN
			Q <= (OTHERS => '0');
		ELSIF enable = '1' AND ((is_falling = '0' and rising_edge(CLK)) or (is_falling = '1' and falling_edge(CLK)))  THEN
			Q <= D;
		END IF;
	END PROCESS;
END;