LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.bus_array_pkg.all;
USE IEEE.numeric_std.all;

ENTITY address_generator IS
	GENERIC (control_address_width: integer:= 5;
			 bit_orings: integer:= 5;
			 bus_width: integer := 16;
			 selection_line_width: integer := 3);
	PORT (next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
		  IR_decoder_address: IN std_logic_vector(control_address_width-1 DOWNTO 0);
		  address_selection_lines: IN std_logic_vector(selection_line_width-1 DOWNTO 0);
		  IR: IN std_logic_vector(bus_width-1 DOWNTO 0);
		  MOV, SRC_IN, CMP, RST: IN std_logic;
		  next_microinstruction_address: OUT std_logic_vector(control_address_width-1 DOWNTO 0)
	);
END ENTITY address_generator;


ARCHITECTURE address_generator_arch OF address_generator IS
	COMPONENT mux IS
		GENERIC (selection_line_width : integer := 2;
				 bus_width: integer := 16);
		PORT (enable : IN std_logic;
			  selection_lines : IN std_logic_vector(selection_line_width - 1 DOWNTO 0);
			  input: IN bus_array((2 ** selection_line_width) - 1 DOWNTO 0)(bus_width - 1 DOWNTO 0);
			  output: OUT std_logic_vector(bus_width-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT bit_oring_circuits IS
		GENERIC (control_address_width: integer:= 5;
				 bit_orings: integer:= 5;
				 bus_width: integer := 16);
		PORT (next_address_field: IN std_logic_vector(control_address_width-1 DOWNTO 0);
			  IR: IN std_logic_vector(bus_width-1 DOWNTO 0);
			  MOV, SRC, CMP: IN std_logic;
			  bit_oring_addresses: OUT bus_array(bit_orings-1 DOWNTO 0)(control_address_width-1 DOWNTO 0)
		);
	END COMPONENT;
	
	SIGNAL bit_oring_addresses: bus_array(bit_orings-1 DOWNTO 0)(control_address_width-1 DOWNTO 0);
	SIGNAL in_mux_inputs: bus_array((2 ** selection_line_width) - 1 DOWNTO 0)(control_address_width - 1 DOWNTO 0);
	SIGNAL out_mux_inputs: bus_array(1 DOWNTO 0)(control_address_width - 1 DOWNTO 0);
	SIGNAL out_mux_select: std_logic_vector(0 DOWNTO 0);
	SIGNAL SRC: std_logic;
	SIGNAL in_mux_output: std_logic_vector(control_address_width-1 DOWNTO 0);
	CONSTANT bit_oring_0_selector: std_logic_vector(2 DOWNTO 0) := "000";
	CONSTANT IR_decoder_address_selector: std_logic_vector(2 DOWNTO 0) := "101";
BEGIN
	PROCESS(address_selection_lines, SRC_IN, SRC)
	BEGIN
		IF (address_selection_lines = bit_oring_0_selector) THEN
			SRC <= '0';
		ELSIF (address_selection_lines = IR_decoder_address_selector) THEN
			SRC <= SRC_IN;
		END IF;
	END PROCESS;
	b: bit_oring_circuits GENERIC MAP(bus_width => bus_width, control_address_width => control_address_width, bit_orings => bit_orings)
					      PORT MAP(next_address_field, IR, MOV, SRC, CMP, bit_oring_addresses);
	
	in_mux_inputs(bit_orings-1 DOWNTO 0) <= bit_oring_addresses;
	in_mux_inputs(bit_orings) <= IR_decoder_address;
	in_mux_inputs(bit_orings+1) <= next_address_field;

	m0: mux GENERIC MAP(selection_line_width => selection_line_width, bus_width => control_address_width)
		   PORT MAP('1', address_selection_lines, in_mux_inputs, in_mux_output);
		   
	
	out_mux_select(0) <= RST;
	out_mux_inputs(0) <= in_mux_output;
	out_mux_inputs(1) <= "10010";
	m1: mux GENERIC MAP(selection_line_width => 1, bus_width => control_address_width)
		    PORT MAP('1', out_mux_select, out_mux_inputs, next_microinstruction_address);
	
END;