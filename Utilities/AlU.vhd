library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.all;
entity ALU is
  generic ( 
      N : integer:=16;
      opcode : integer:=5
    );
    Port (
      A, B     : in  std_logic_vector(N-1 downto 0);  
      Op : in std_logic_vector(opcode-1 downto 0);
      sel  : in  std_logic_vector(1 downto 0);  
      C   : out  std_logic_vector(N-1 downto 0); 
      flags : out std_logic_vector(4 downto 0);
      Cin : in std_logic
    );
end ALU; 
architecture Behavioral of ALU is
signal ALU_Result : std_logic_vector (N downto 0) := (others => '0');
signal f : std_logic_vector(4 downto 0) := (others => '0');
begin
  process(A,B,Op,sel,Cin)
  begin
    if (sel = "00") then  -- INC
      ALU_Result <= std_logic_vector(signed('0' & B)+1); 
    elsif (sel = "01") then   --DEC
      ALU_Result <= std_logic_vector(signed('0' & B)-1);
    elsif (sel = "10") then   --ADD
      ALU_Result <= std_logic_vector(signed('0' & A)+signed('0' & B)); 
    else    --operation
      if(Op(opcode-1 downto opcode-2) = "00") then--2 operand
        if (Op = "00000") then  -- SUB,CMP
          ALU_Result <= std_logic_vector(signed('0' & A)-signed('0' & B));
        elsif (Op = "00001") then  -- ADD
          ALU_Result <= std_logic_vector(signed('0' & A)+signed('0' & B));
        elsif (Op = "00010") then  --ADC
          if(Cin = '1') then
            ALU_Result <= std_logic_vector(signed('0' & A)+signed('0' & B)+1);
          else
            ALU_Result <= std_logic_vector(signed('0' & A)+signed('0' & B));
          end if;
        elsif (Op = "00011") then --SBC
          if(Cin = '1') then
            ALU_Result <= std_logic_vector(signed('0' & A)-signed('0' & B)-1);
          else
            ALU_Result <= std_logic_vector(signed('0' & A)-signed('0' & B));
          end if;
        elsif (Op = "00100") then  --and 
          ALU_Result(N-1 downto 0) <= A and B;
          ALU_Result(N) <= '0';
        elsif (Op = "00101") then  -- or
          ALU_Result(N-1 downto 0) <= A or B;
          ALU_Result(N) <= '0';
        elsif (Op = "00110") then  --xnor
          ALU_Result(N-1 downto 0) <= A xnor B;
          ALU_Result(N) <= '0';
        else
          ALU_Result <= (others => 'X');
        end if;
      elsif(Op(opcode-1 downto opcode-2) = "01") then
        if (Op = "01000") then  --inv
          ALU_Result(N-1 downto 0) <= not A;
          ALU_Result(N) <= '0';
        elsif (Op = "01001") then  --lsr
          ALU_Result(N-1 downto 0) <= '0' & A(N-1 downto 1);
          ALU_Result(N) <= '0';
        elsif (Op = "01010") then  --ror
          ALU_Result(N-1 downto 0) <= A(0) & A(N-1 downto 1);
          ALU_Result(N) <= '0';
        elsif (Op = "01011") then  --RRC
          ALU_Result(N-1 downto 0) <= Cin & A(N-1 downto 1);
          ALU_Result(N) <= '0';
        elsif (Op = "01100") then --ASR
          ALU_Result(N-1 downto 0) <= A(N-1) & A(N-1 downto 1);
          ALU_Result(N) <= '0';
        elsif (Op = "01101") then--lsl 
          ALU_Result(N-1 downto 0) <= A(N-2 downto 0) & '0';
          ALU_Result(N) <= '0';
        elsif (Op = "01110") then --ROL
          ALU_Result(N-1 downto 0) <= A(N-2 downto 0) & A(N-1);
          ALU_Result(N) <= '0';
        elsif (Op = "01111") then  --RCL
          ALU_Result(N-1 downto 0) <= A(N-2 downto 0) & Cin;
          ALU_Result(N) <= '0';
        end if;
      elsif(Op(opcode-1 downto opcode-2) = "10") then
        if (Op = "10000") then  -- INC
          ALU_Result <= std_logic_vector(signed('0' & B)+1); 
        elsif (Op = "10001") then   --DEC
          ALU_Result <= std_logic_vector(signed('0' & B)-1);
        else
          ALU_Result <= (others => 'X');
        end if;
      else
        ALU_Result <= (others => 'X');
      end if;
    end if;
 end process;
 f(0) <= A(N-1) when (sel = "11" and Op = "01111") 
        else A(0) when (sel = "11" and Op = "01011")
        else ALU_Result(N) when (Op = "00000" or Op = "00001" or Op = "00010" or Op = "00011" or Op = "10000" or Op = "10001")
        else '0';                                                                               --carry flag
 f(1) <= '0' when ALU_Result(N-1) = '0' else '1';                                               --sign flag
 f(2) <= '1' when ALU_Result(N-1 downto 0) = (ALU_Result(N-1 downto 0)'range => '0') else '0';  --zero flag
 f(3) <= '1' when ALU_Result(N) = '1' else '0';                                                 --overflow flag
 f(4) <= '1' when ALU_Result(0) = '0' else '0';                                                 --parity flag
 C <= (others => 'X') when (sel = "11" and Op = "00000111") else ALU_Result(N-1 downto 0);      -- ALU out
 flags <= f;
end Behavioral;