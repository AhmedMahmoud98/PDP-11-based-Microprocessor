LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.bus_array_pkg.ALL;

ENTITY branch_address IS
    GENERIC (address_width : INTEGER := 5);
    PORT (
        branch_opcode : IN std_logic_vector(2 DOWNTO 0);
        zero_flag, carry_flag, is_nop : IN std_logic;
        address : OUT std_logic_vector(address_width - 1 DOWNTO 0)
    );
END branch_address;

ARCHITECTURE branch_address_operation OF branch_address IS
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
    COMPONENT branch_condition IS
        PORT (
            branch_opcode : IN std_logic_vector(2 DOWNTO 0);
            zero_flag, carry_flag : IN std_logic;
            condition_satisfied : OUT std_logic
        );
    END COMPONENT;
    SIGNAL mux_input : bus_array(1 DOWNTO 0)(address_width - 1 DOWNTO 0);
    SIGNAL is_condition_satisfied : std_logic;
BEGIN
    mux_input(0) <= "10010"; -- fetch addresss
    mux_input(1) <= "01101"; -- branch address
    condition : branch_condition PORT MAP(branch_opcode, zero_flag, carry_flag, is_condition_satisfied);
    branch_mux : mux GENERIC MAP(
        selection_line_width => 1, bus_width => address_width) PORT MAP('1',
        "" & (is_condition_satisfied AND NOT is_nop),
        mux_input, address);
END branch_address_operation;