LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY falling_edge_reg IS
	GENERIC (size : integer := 16);
	PORT(CLK, RST, enable : IN std_logic;
		 D : IN std_logic_vector(size-1 DOWNTO 0);
		 Q : OUT std_logic_vector(size-1 DOWNTO 0));
END ENTITY falling_edge_reg;

ARCHITECTURE IR_reg_arch OF falling_edge_reg IS
BEGIN
	PROCESS(CLK, RST, enable)
	BEGIN
		IF(RST = '1') THEN
			Q <= (OTHERS => '0');
		ELSIF enable = '1' AND falling_edge(CLK) THEN
			Q <= D;
		END IF;
	END PROCESS;
END;