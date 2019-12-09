LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY bit_oring_2 IS
	GENERIC(bus_width: integer:= 16;
			control_address_width: integer := 5);
	PORT(next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
		 MOV, SRC: IN std_logic;
		 control_address: OUT std_logic_vector(control_address_width-1 DOWNTO 0)
	);
END ENTITY bit_oring_2;

ARCHITECTURE bit_oring_2_arch OF bit_oring_2 IS
BEGIN
	PROCESS(next_address_field, control_address, MOV, SRC)
		VARIABLE X: std_logic_vector(control_address_width-1 DOWNTO 0);
	BEGIN
		X := next_address_field;
		X(2) := SRC;
		X(1) := (not SRC) and MOV;
		control_address <= X;
	END PROCESS;
END;