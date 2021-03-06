LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY bit_oring_1 IS
	GENERIC(bus_width: integer:= 16;
			control_address_width: integer := 5);
	PORT(next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
		 MOV, SRC: IN std_logic;
		 IR: IN std_logic_vector(bus_width-1 DOWNTO 0);
		 control_address: OUT std_logic_vector(control_address_width-1 DOWNTO 0)
	);
END ENTITY bit_oring_1;

ARCHITECTURE bit_oring_1_arch OF bit_oring_1 IS
BEGIN
	PROCESS(next_address_field, control_address, IR, MOV, SRC)
		VARIABLE X: std_logic_vector(control_address_width-1 DOWNTO 0);
	BEGIN
		X := next_address_field;
		X(2) := SRC AND (not IR(9));
		X(1) := (not SRC) and MOV;
		X(0) := (IR(9) and SRC) or (IR(3) and (not SRC));
		control_address <= X;
	END PROCESS;
END;