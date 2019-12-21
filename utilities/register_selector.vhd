LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.bus_array_pkg.all;

ENTITY register_selector IS
	GENERIC (word_size : integer := 16;
			 selection_line_width : integer := 3);
	PORT (Rsrc_in, Rsrc_out, Rdst_in, Rdst_out: IN std_logic;
		  Rsrc, Rdst: IN std_logic_vector(word_size-1 DOWNTO 0);
		  R_in_enable, R_out_enable: OUT std_logic;
		  R_in_selector, R_out_selector: OUT std_logic_vector(selection_line_width-1 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE register_selector_arch OF register_selector IS
	COMPONENT mux IS
		GENERIC (selection_line_width : integer := 2;
				 bus_width: integer := 16);
		PORT (enable : IN std_logic;
			  selection_lines : IN std_logic_vector(selection_line_width - 1 DOWNTO 0);
			  input: IN ram_type((2 ** selection_line_width) - 1 DOWNTO 0)(bus_width - 1 DOWNTO 0);
			  output: OUT std_logic_vector(bus_width-1 DOWNTO 0)
		);
	END COMPONENT;
	
	SIGNAL in_mux_input, out_mux_input: bus_array(1 DOWNTO 0)(word_size-1 DOWNTO 0); 
	SIGNAL in_mux_select, out_mux_select: std_logic_vector(0 DOWNTO 0);
BEGIN
	-- In/Out Enables
	R_in_enable <= Rsrc_in or Rdst_in;
	R_out_enable <= Rsrc_out or Rdst_out;
	-- Reg_in
	in_mux_select(0) <= Rsrc_in;
	in_mux_input(0) <= Rdst;
	in_mux_input(1) <= Rsrc;
	in_mux: mux GENERIC MAP (selection_line_width => selection_line_width, bus_width => word_size)
				PORT MAP (R_in_enable, in_mux_select, in_mux_input, R_in_selector); 
	-- Reg_out
	out_mux_select(0) <= Rsrc_out;
	out_mux_input(0) <= Rdst;
	out_mux_input(1) <= Rsrc;
	out_mux: mux GENERIC MAP (selection_line_width => selection_line_width, bus_width => word_size)
				PORT MAP (R_out_enable, out_mux_select, out_mux_input, R_out_selector); 
END;