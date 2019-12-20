LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.bus_array_pkg.ALL;

ENTITY branch_condition IS
    PORT (
        branch_opcode : IN std_logic_vector(2 DOWNTO 0);
        zero_flag, carry_flag : IN std_logic;
        condition_satisfied : OUT std_logic
    );
END branch_condition;

ARCHITECTURE branch_condition_operation OF branch_condition IS
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
    SIGNAL branch_conditions : bus_array(7 DOWNTO 0)(0 DOWNTO 0);
    SIGNAL mux_output : std_logic_vector(0 DOWNTO 0);
BEGIN
    branch_conditions(0)(0) <= '1';
    branch_conditions(1)(0) <= zero_flag;
    branch_conditions(2)(0) <= NOT zero_flag;
    branch_conditions(3)(0) <= NOT carry_flag;
    branch_conditions(4)(0) <= NOT carry_flag OR zero_flag;
    branch_conditions(5)(0) <= carry_flag;
    branch_conditions(6)(0) <= carry_flag OR zero_flag;
    u0 : mux GENERIC MAP(selection_line_width => 3, bus_width => 1) PORT MAP('1', branch_opcode, branch_conditions, mux_output);
    condition_satisfied <= mux_output(0);
END branch_condition_operation;