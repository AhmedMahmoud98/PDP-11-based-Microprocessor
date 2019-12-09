LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY tristate IS
	GENERIC(bus_width: integer := 16);
	PORT(enable: IN std_logic;
		 input: IN std_logic_vector(bus_width-1 DOWNTO 0);
		 output: OUT std_logic_vector(bus_width-1 DOWNTO 0)
	);
END ENTITY tristate;

ARCHITECTURE tristate_arch OF tristate IS
BEGIN
	output <= input WHEN enable = '1' ELSE (OTHERS => 'Z');
END ;