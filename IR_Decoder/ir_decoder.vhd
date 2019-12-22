LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.bus_array_pkg.ALL;

ENTITY ir_decoder IS
	GENERIC (address_width : INTEGER := 5);
	PORT (
		IR : IN std_logic_vector(15 DOWNTO 0);
		zero_flag, carry_flag : IN std_logic;
		address : OUT std_logic_vector(4 DOWNTO 0);
		Rsrc, Rdst : OUT std_logic_vector(2 DOWNTO 0);
		is_mov, is_cmp, is_src : OUT std_logic;
		alu_opcode : OUT std_logic_vector(4 DOWNTO 0)
	);
END ir_decoder;

ARCHITECTURE ir_decoder_operation OF ir_decoder IS
	COMPONENT mux IS
		GENERIC (
			selection_line_width : INTEGER := 2;
			bus_width : INTEGER := 16);
		PORT (
			enable : IN std_logic;
			selection_lines : IN std_logic_vector(selection_line_width - 1 DOWNTO 0);
			input : IN bus_array((2 ** selection_line_width) - 1 DOWNTO 0)(bus_width - 1 DOWNTO 0);
			output : OUT std_logic_vector(bus_width - 1 DOWNTO 0));
	END COMPONENT;
	COMPONENT branch_address IS
		GENERIC (address_width : INTEGER := 5);
		PORT (
			branch_opcode : IN std_logic_vector(2 DOWNTO 0);
			zero_flag, carry_flag, is_nop : IN std_logic;
			address : OUT std_logic_vector(address_width - 1 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT address_mode_based IS
		GENERIC (address_width : INTEGER := 5);
		PORT (
			address_mode : IN std_logic_vector(2 DOWNTO 0);
			is_src : IN std_logic;
			address : OUT std_logic_vector(address_width - 1 DOWNTO 0)
		);
	END COMPONENT;
	SIGNAL branch_address_output, address_mode_output : std_logic_vector(address_width - 1 DOWNTO 0);
	SIGNAL address_mode : std_logic_vector(2 DOWNTO 0);
	SIGNAL is_clr, hlt_nop, is_hlt, is_nop, is_1_op, is_2_op, is_branch : std_logic;
BEGIN
	hlt_nop <= IR(15) AND IR(14) AND NOT IR(13) AND NOT IR(13);
	is_nop <= hlt_nop AND NOT IR(11);
	is_hlt <= hlt_nop AND IR(11);
	is_1_op <= IR(15) AND NOT IR(14) AND IR(13) AND NOT IR(12);
	is_2_op <= NOT IR(15) OR is_mov OR is_cmp;
	is_clr <= is_1_op AND IR(11) AND IR(10) AND IR(9) AND IR(8) AND IR(7); -- 11111
	is_mov <= is_clr or (IR(15) AND NOT IR(14) AND NOT IR(13) AND IR(12)); -- 1001
	is_cmp <= IR(15) AND NOT IR(14) AND NOT IR(13) AND NOT IR(12); -- 1000
	is_src <= NOT is_1_op OR is_clr;
	is_branch <= IR(15) AND NOT IR(14) AND IR(13) AND IR(12); -- "1011"
	address_mode <=
		IR(3) & IR(5 DOWNTO 4) WHEN is_1_op
		ELSE
		IR(9) & IR(11 DOWNTO 10);
	u0 : branch_address GENERIC MAP(
		address_width => address_width) PORT MAP(
		IR(11 DOWNTO 9)
		, zero_flag, carry_flag, is_nop, branch_address_output);

	u1 : address_mode_based GENERIC MAP(
		address_width => address_width) PORT MAP(
		address_mode, is_src, address_mode_output
	);
	address <=
		(branch_address_output AND (is_branch OR is_nop)) OR
		("10101" AND is_clr) OR -- clear address
		("11111" AND is_hlt) OR -- halt address
		(address_mode_output AND (is_2_op OR is_1_op));
	alu_opcode <=
		IR(11 DOWNTO 7) WHEN is_1_op
		ELSE
		"00" & IR(14 DOWNTO 12);
	Rsrc <= IR(8 DOWNTO 6);
	Rdst <= IR(2 DOWNTO 0);
END ir_decoder_operation;