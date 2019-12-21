LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY CPU IS
	GENERIC (
		bus_width : INTEGER := 16;
		selection_line_width : INTEGER := 3);
	PORT (
		CLK, RST : IN std_logic;
		data_bus : INOUT std_logic_vector(bus_width - 1 DOWNTO 0)
	);
END ENTITY CPU;

ARCHITECTURE CPU_arch OF CPU IS
	COMPONENT general_purpose_registers IS
		GENERIC (
			bus_width : INTEGER := 16;
			selection_line_width : INTEGER := 3);
		PORT (
			CLK, RST, in_enable, out_enable : IN std_logic;
			out_selection_line, in_selection_line : IN std_logic_vector(selection_line_width - 1 DOWNTO 0);
			data_bus : INOUT std_logic_vector(bus_width - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT special_purpose_registers IS
		GENERIC (
			bus_width : INTEGER := 16;
			flags : INTEGER := 5);
		PORT (
			CLK, RST, MDRin, MDRout, MARin, Rd, PCin, PCout, IRin, IRout, SRCin, SRCout, Zin, Zout, Yin : IN std_logic;
			memory_data_in, Z_data_in : IN std_logic_vector(bus_width - 1 DOWNTO 0);
			flag_register_data_in : IN std_logic_vector(flags - 1 DOWNTO 0);
			data_bus : INOUT std_logic_vector(bus_width - 1 DOWNTO 0);
			memory_address_out, memory_data_out, IR_data, Y_data : OUT std_logic_vector(bus_width - 1 DOWNTO 0);
			zero_flag, carry_flag : OUT std_logic
		);
	END COMPONENT;

	COMPONENT control_signals IS
		PORT (
			address : IN std_logic_vector(4 DOWNTO 0);
			next_location_bits : OUT std_logic_vector(2 DOWNTO 0);
			PC_out, MDR_out, Z_out, R_src_out, R_dst_out, SRC_out, IR_out : OUT std_logic;
			PC_in, MDR_in, Z_in, R_src_in, R_dst_in, SRC_in, IR_in, MAR_in, Y_in : OUT std_logic;
			ALU_bits : OUT std_logic_vector(1 DOWNTO 0);
			RD, WR, SRC_clear : OUT std_logic;
			next_address : OUT std_logic_vector(4 DOWNTO 0)
		);

	END COMPONENT;

	COMPONENT ir_decoder IS
		GENERIC (address_width : INTEGER := 5);
		PORT (
			IR : IN std_logic_vector(15 DOWNTO 0);
			zero_flag, carry_flag : IN std_logic;
			address : OUT std_logic_vector(4 DOWNTO 0);
			Rsrc, Rdst : OUT std_logic_vector(2 DOWNTO 0);
			is_mov, is_cmp, is_src : OUT std_logic;
			alu_opcode : OUT std_logic_vector(4 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU IS
		GENERIC (
			N : INTEGER := 16;
			opcode : INTEGER := 5
		);
		PORT (
			A, B : IN std_logic_vector(N - 1 DOWNTO 0);
			Op : IN std_logic_vector(opcode - 1 DOWNTO 0);
			sel : IN std_logic_vector(1 DOWNTO 0);
			C : OUT std_logic_vector(N - 1 DOWNTO 0);
			flags : OUT std_logic_vector(4 DOWNTO 0);
			Cin : IN std_logic
		);
	END COMPONENT;

	COMPONENT RAM IS
		GENERIC (
			word_size : INTEGER := 16;
			address_width : INTEGER := 16;
			RAM_size : INTEGER := 10);
		PORT (
			CLK, WR : IN std_logic;
			address : IN std_logic_vector(address_width - 1 DOWNTO 0);
			data_in : IN std_logic_vector(word_size - 1 DOWNTO 0);
			data_out : OUT std_logic_vector(word_size - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT address_generator IS
		GENERIC (
			control_address_width : INTEGER := 5;
			bit_orings : INTEGER := 5;
			bus_width : INTEGER := 16;
			selection_line_width : INTEGER := 3);
		PORT (
			next_address_field : IN std_logic_vector(control_address_width - 1 DOWNTO 0);
			IR_decoder_address : IN std_logic_vector(control_address_width - 1 DOWNTO 0);
			address_selection_lines : IN std_logic_vector(selection_line_width - 1 DOWNTO 0);
			IR : IN std_logic_vector(bus_width - 1 DOWNTO 0);
			MOV, SRC_IN, CMP : IN std_logic;
			next_microinstruction_address : OUT std_logic_vector(control_address_width - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT RD_signal IS
		PORT (
			RD_in, is_MOV, PC_out, is_SRC : IN std_logic;
			IR_DST_addressing_mode : IN std_logic_vector(2 DOWNTO 0);
			RD_out : OUT std_logic
		);
	END COMPONENT;

	COMPONENT register_selector IS
		GENERIC (
			output_size : INTEGER := 3;
			selection_line_width : INTEGER := 3);
		PORT (
			Rsrc_in, Rsrc_out, Rdst_in, Rdst_out : IN std_logic;
			Rsrc, Rdst : IN std_logic_vector(output_size - 1 DOWNTO 0);
			R_in_enable, R_out_enable : OUT std_logic;
			R_in_selector, R_out_selector : OUT std_logic_vector(selection_line_width - 1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL control_store_address, wide_branch_address, next_address : std_logic_vector(4 DOWNTO 0);
	SIGNAL next_location_bits : std_logic_vector(2 DOWNTO 0);
	SIGNAL PC_out, MDR_out, Z_out, R_src_out, R_dst_out, SRC_out, IR_out : std_logic;
	SIGNAL PC_in, MDR_in, Z_in, R_src_in, R_dst_in, SRC_in, IR_in, MAR_in, Y_in : std_logic;
	SIGNAL ALU_bits : std_logic_vector(1 DOWNTO 0);
	SIGNAL RD_control_signal, WR, SRC_clear, RD : std_logic;
	SIGNAL zero_flag, carry_flag : std_logic;
	SIGNAL MAR_data, MDR_data, IR_data, memory_to_MDR, Y_data, Z_data : std_logic_vector(bus_width - 1 DOWNTO 0);
	SIGNAL alu_opcode : std_logic_vector(4 DOWNTO 0);
	SIGNAL is_SRC, is_MOV, is_CMP, write_to_register_enable, read_from_register_enable : std_logic;
	SIGNAL read_from_selection_line, write_to_selection_line : std_logic_vector(selection_line_width - 1 DOWNTO 0);
	SIGNAL flag_register_data : std_logic_vector(4 DOWNTO 0);
	SIGNAL R_src, R_dst : std_logic_vector(2 DOWNTO 0);

BEGIN
	u0 : control_signals PORT MAP(
		control_store_address,
		next_location_bits,
		PC_out, MDR_out, Z_out, R_src_out, R_dst_out, SRC_out, IR_out,
		PC_in, MDR_in, Z_in, R_src_in, R_dst_in, SRC_in, IR_in, MAR_in, Y_in,
		ALU_bits,
		RD_control_signal, WR, SRC_clear,
		next_address
	);

	u1 : special_purpose_registers GENERIC MAP(
		bus_width => bus_width,
		flags => 5) PORT MAP(
		CLK, RST, MDR_in, MDR_out, MAR_in, RD, PC_in, PC_out, IR_in, IR_out,
		SRC_in, SRC_out, Z_in, Z_out, Y_in,
		memory_to_MDR, Z_data,
		flag_register_data,
		data_bus,
		MAR_data, MDR_data, IR_data, Y_data,
		zero_flag, carry_flag
	);

	u2 : RD_signal PORT MAP(
		RD_control_signal, is_MOV, PC_out, is_SRC,
		IR_data(5 DOWNTO 3),
		RD
	);

	u3 : ir_decoder GENERIC MAP(
		address_width => 5) PORT MAP (
		IR_data,
		zero_flag, carry_flag,
		wide_branch_address,
		R_src, R_dst,
		is_MOV, is_CMP, is_SRC,
		alu_opcode
	);

	u4 : general_purpose_registers GENERIC MAP(
		bus_width => bus_width,
		selection_line_width => selection_line_width)
	PORT MAP(
		CLK, RST, write_to_register_enable, read_from_register_enable,
		read_from_selection_line, write_to_selection_line,
		data_bus
	);

	u5 : ALU GENERIC MAP(
		N => bus_width,
		opcode => 5) PORT MAP(
		Y_data, data_bus,
		alu_opcode,
		ALU_bits,
		Z_data,
		flag_register_data,
		carry_flag
	);

	u6 : RAM GENERIC MAP(
		word_size => bus_width,
		address_width => bus_width,
		RAM_size => 2048) PORT MAP(
		CLK, WR,
		MAR_data,
		MDR_data,
		memory_to_MDR
	);

	u7 : register_selector GENERIC MAP(
		output_size => 3,
		selection_line_width => 3)
	PORT MAP(
		R_src_in, R_src_out, R_dst_in, R_dst_out,
		R_src, R_dst,
		write_to_register_enable, read_from_register_enable,
		write_to_selection_line, read_from_selection_line
	);

	u8 : address_generator GENERIC MAP(
		control_address_width => 5,
		bit_orings => 5,
		bus_width => bus_width,
		selection_line_width => selection_line_width)
	PORT MAP(
		next_address,
		wide_branch_address,
		next_location_bits,
		IR_data,
		is_MOV, is_SRC, is_CMP,
		control_store_address
	);

END;