LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.bus_array_pkg.ALL;

ENTITY address_mode_based IS
    GENERIC (address_width : INTEGER := 5);
    PORT (
        address_mode : IN std_logic_vector(2 DOWNTO 0);
        is_src : IN std_logic;
        address : OUT std_logic_vector(address_width - 1 DOWNTO 0)
    );
END address_mode_based;

ARCHITECTURE address_mode_based_operation OF address_mode_based IS
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
    SIGNAL register_addresses : bus_array(3 DOWNTO 0)(address_width - 1 DOWNTO 0);
    SIGNAL all_addresses : bus_array(3 DOWNTO 0)(address_width - 1 DOWNTO 0);
    SIGNAL register_address: std_logic_vector(address_width - 1 downto 0);
BEGIN
    register_addresses(0) <= "00100"; -- register direct destination
    register_addresses(1) <= "00101"; -- register direct source
    register_addresses(2) <= "00000"; -- register indirect
    register_addresses(3) <= "00000"; -- register indirect
    register_mux : mux GENERIC MAP(selection_line_width => 2, bus_width => address_width) PORT MAP('1', address_mode(2) & is_src, register_addresses, register_address);
    
    all_addresses(0) <= register_address;
    all_addresses(1) <= "00001"; -- autoincrement address
    all_addresses(2) <= "00010"; -- autodecrement address
    all_addresses(3) <= "00011"; -- indexed address
    all_addresses_mux: mux GENERIC MAP(selection_line_width => 2, bus_width => address_width) PORT MAP('1', address_mode(1) & address_mode(0), all_addresses, address);
END address_mode_based_operation;