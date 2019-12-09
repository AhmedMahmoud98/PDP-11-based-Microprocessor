LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY bit_oring_0 IS
	GENERIC(bus_width: integer:= 16;
			control_address_width: integer := 5);
	PORT(next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
		 MOV: IN std_logic;
		 IR: IN std_logic_vector(bus_width-1 DOWNTO 0);
		 control_address: OUT std_logic_vector(control_address_width-1 DOWNTO 0)
	);
END ENTITY bit_oring_0;

ARCHITECTURE bit_oring_0_arch OF bit_oring_0 IS
BEGIN
	PROCESS(next_address_field, control_address, IR, MOV)
		VARIABLE X: std_logic_vector(control_address_width-1 DOWNTO 0);
	BEGIN
		X := next_address_field;
		X(3) := MOV and (not IR(5)) and (not IR(4)) and (not IR(3));
		X(2) := (not IR(5)) and (not IR(4)) and (not IR(3));
		X(1) := IR(5);
		X(0) := IR(4);
		control_address <= X;
	END PROCESS;
END;