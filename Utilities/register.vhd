LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY reg IS
	GENERIC (size : integer := 16);
	PORT(CLK, RST, enable : IN std_logic;
		 D : IN std_logic_vector(size-1 DOWNTO 0);
		 Q : OUT std_logic_vector(size-1 DOWNTO 0));
END ENTITY reg;

ARCHITECTURE reg_arch OF reg IS
BEGIN
	PROCESS(CLK, RST)
	BEGIN
		IF(RST = '1') THEN
			Q <= (OTHERS => '0');
		ELSIF enable = '1' AND rising_edge(CLK) THEN
			Q <= D;
		END IF;
	END PROCESS;
END reg_arch;