LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY bit_oring_4 IS
	GENERIC(bus_width: integer:= 16;
			control_address_width: integer := 5);
	PORT(next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
		 CMP: IN std_logic;
		 IR: IN std_logic_vector(bus_width-1 DOWNTO 0);
		 control_address: OUT std_logic_vector(control_address_width-1 DOWNTO 0)
	);
END ENTITY bit_oring_4;

ARCHITECTURE bit_oring_4_arch OF bit_oring_4 IS
BEGIN
	PROCESS(next_address_field, control_address, IR, CMP)
		VARIABLE X: std_logic_vector(control_address_width-1 DOWNTO 0);
	BEGIN
		X := next_address_field;
		X(1) := CMP;
		X(0) := (not CMP) and (IR(5) or IR(4) or IR(3));
		control_address <= X;
	END PROCESS;
END;