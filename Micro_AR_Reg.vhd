LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY Micro_AR_reg IS
	PORT(CLK, RST, enable : IN std_logic;
		 D : IN std_logic_vector(4 DOWNTO 0);
		 Q : OUT std_logic_vector(4 DOWNTO 0));
END ENTITY Micro_AR_reg;

ARCHITECTURE Micro_AR_reg_arch OF Micro_AR_reg IS
BEGIN
	PROCESS(CLK, RST)
	BEGIN
		IF(RST = '1') THEN
			Q <= "10010";
		ELSIF enable = '1' AND falling_edge(CLK) THEN
			Q <= D;
		END IF;
	END PROCESS;
END Micro_AR_reg_arch;