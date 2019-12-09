LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.bus_array_pkg.all;


ENTITY bit_oring_circuits IS
	GENERIC (control_address_width: integer:= 5;
			 bit_orings: integer:= 5;
			 bus_width: integer := 16);
	PORT (next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
		  IR: IN std_logic_vector(bus_width-1 DOWNTO 0);
		  MOV, SRC, CMP: IN std_logic;
		  bit_oring_addresses: OUT bus_array(bit_orings-1 DOWNTO 0)(control_address_width-1 DOWNTO 0)
	);
END ENTITY bit_oring_circuits;

ARCHITECTURE bit_oring_circuits_arch OF bit_oring_circuits IS
	COMPONENT bit_oring_0 IS
		GENERIC(bus_width: integer:= 16;
				control_address_width: integer := 5);
		PORT(next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
			 MOV: IN std_logic;
			 IR: IN std_logic_vector(bus_width-1 DOWNTO 0);
			 control_address: OUT std_logic_vector(control_address_width-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT bit_oring_1 IS
		GENERIC(bus_width: integer:= 16;
				control_address_width: integer := 5);
		PORT(next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
			 MOV, SRC: IN std_logic;
			 IR: IN std_logic_vector(bus_width-1 DOWNTO 0);
			 control_address: OUT std_logic_vector(control_address_width-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT bit_oring_2 IS
		GENERIC(bus_width: integer:= 16;
				control_address_width: integer := 5);
		PORT(next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
			 MOV, SRC: IN std_logic;
			 control_address: OUT std_logic_vector(control_address_width-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT bit_oring_3 IS
		GENERIC(bus_width: integer:= 16;
				control_address_width: integer := 5);
		PORT(next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
			 SRC: IN std_logic;
			 control_address: OUT std_logic_vector(control_address_width-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT bit_oring_4 IS
		GENERIC(bus_width: integer:= 16;
				control_address_width: integer := 5);
		PORT(next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
			 CMP: IN std_logic;
			 IR: IN std_logic_vector(bus_width-1 DOWNTO 0);
			 control_address: OUT std_logic_vector(control_address_width-1 DOWNTO 0)
		);
	END COMPONENT;
BEGIN
	b0: bit_oring_0 GENERIC MAP (bus_width => bus_width, control_address_width => control_address_width) 
					PORT MAP (next_address_field, MOV, IR, bit_oring_addresses(0));
	b1: bit_oring_1 GENERIC MAP (bus_width => bus_width, control_address_width => control_address_width) 
					PORT MAP (next_address_field, MOV, SRC, IR, bit_oring_addresses(1));
	b2: bit_oring_2 GENERIC MAP (bus_width => bus_width, control_address_width => control_address_width) 
					PORT MAP (next_address_field, MOV, SRC, bit_oring_addresses(2));
	b3: bit_oring_3 GENERIC MAP (bus_width => bus_width, control_address_width => control_address_width) 
					PORT MAP (next_address_field, SRC, bit_oring_addresses(3));
	b4: bit_oring_4 GENERIC MAP (bus_width => bus_width, control_address_width => control_address_width) 
					PORT MAP (next_address_field, CMP, IR, bit_oring_addresses(4));
END;