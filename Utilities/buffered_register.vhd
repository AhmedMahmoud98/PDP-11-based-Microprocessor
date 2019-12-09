LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY buffered_reg IS
	GENERIC (size : integer := 16);
	PORT(CLK, RST, in_enable, out_enable : IN std_logic;
		 D : IN std_logic_vector(size-1 DOWNTO 0);
		 Q : OUT std_logic_vector(size-1 DOWNTO 0));
END ENTITY buffered_reg;

ARCHITECTURE buffered_reg_arch OF buffered_reg IS
	COMPONENT reg IS
		GENERIC (size : integer := 16);
		PORT(CLK, RST, enable : IN std_logic;
			 D : IN std_logic_vector(size-1 DOWNTO 0);
			 Q : OUT std_logic_vector(size-1 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT tristate IS
		GENERIC(bus_width: integer := 16);
		PORT(enable: IN std_logic;
			 input: IN std_logic_vector(bus_width-1 DOWNTO 0);
			 output: OUT std_logic_vector(bus_width-1 DOWNTO 0)
		);
	END COMPONENT;
	
	SIGNAL reg_out: std_logic_vector(size-1 DOWNTO 0);
BEGIN
	r: reg GENERIC MAP(size => size) PORT MAP(CLK, RST, in_enable, D, reg_out);
	t: tristate GENERIC MAP(bus_width => size) PORT MAP(out_enable, reg_out, Q);
END;