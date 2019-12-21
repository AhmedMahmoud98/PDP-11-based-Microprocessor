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
        if (Op(opcode-3 downto 0) = "000") then  -- SUB,CMP
          ALU_Result <= std_logic_vector(signed('0' & A)-signed('0' & B));
        elsif (Op(opcode-3 downto 0) = "001") then  -- ADD
          ALU_Result <= std_logic_vector(signed('0' & A)+signed('0' & B));
        elsif (Op(opcode-3 downto 0) = "010") then  --ADC
          if(Cin = '1') then
            ALU_Result <= std_logic_vector(signed('0' & A)+signed('0' & B)+1);
          else
            ALU_Result <= std_logic_vector(signed('0' & A)+signed('0' & B));
          end if;
        elsif (Op(opcode-3 downto 0) = "011") then --SBC
          if(Cin = '1') then
            ALU_Result <= std_logic_vector(signed('0' & A)-signed('0' & B)-1);
          else
            ALU_Result <= std_logic_vector(signed('0' & A)-signed('0' & B));
          end if;
        elsif (Op(opcode-3 downto 0) = "100") then  --and 
          ALU_Result(N-1 downto 0) <= A and B;
          ALU_Result(N) <= '0';
        elsif (Op(opcode-3 downto 0) = "101") then  -- or
          ALU_Result(N-1 downto 0) <= A or B;
          ALU_Result(N) <= '0';
        elsif (Op(opcode-3 downto 0) = "110") then  --xnor
          ALU_Result(N-1 downto 0) <= A xnor B;
          ALU_Result(N) <= '0';
        end if;
      elsif(Op(opcode-1 downto opcode-2) = "01") then
        if (Op(opcode-3 downto 0) = "000") then  --inv
          ALU_Result(N-1 downto 0) <= not A;
          ALU_Result(N) <= '0';
        elsif (Op(opcode-3 downto 0) = "001") then  --lsr
          ALU_Result(N-1 downto 0) <= '0' & A(N-1 downto 1);
          ALU_Result(N) <= '0';
        elsif (Op(opcode-3 downto 0) = "010") then  --ror
          ALU_Result(N-1 downto 0) <= A(0) & A(N-1 downto 1);
          ALU_Result(N) <= '0';
        elsif (Op(opcode-3 downto 0) = "011") then  --RRC
          ALU_Result(N-1 downto 0) <= Cin & A(N-1 downto 1);
          ALU_Result(N) <= '0';
        elsif (Op(opcode-3 downto 0) = "100") then --ASR
          ALU_Result(N-1 downto 0) <= A(N-1) & A(N-1 downto 1);
          ALU_Result(N) <= '0';
        elsif (Op(opcode-3 downto 0) = "101") then--lsl 
          ALU_Result(N-1 downto 0) <= A(N-2 downto 0) & '0';
          ALU_Result(N) <= '0';
        elsif (Op(opcode-3 downto 0) = "110") then --ROL
          ALU_Result(N-1 downto 0) <= A(N-2 downto 0) & A(N-1);
          ALU_Result(N) <= '0';
        else  --RCL
          ALU_Result(N-1 downto 0) <= A(N-2 downto 0) & Cin;
          ALU_Result(N) <= '0';
        end if;
      elsif(Op(opcode-1 downto opcode-2) = "10") then
        if (Op(opcode-3 downto 0) = "000") then  -- INC
          ALU_Result <= std_logic_vector(signed('0' & B)+1); 
        elsif (Op(opcode-3 downto 0) = "001") then   --DEC
          ALU_Result <= std_logic_vector(signed('0' & B)-1);
        end if;
      end if;
    end if;
 end process;
 f(0) <= A(N-1) when (sel = "11" and Op = "01111") 
        else A(0) when (sel = "11" and Op = "01011")
        else ALU_Result(N) when (sel = "11" and (Op = "00000" or Op = "00001" or Op = "00010" or Op = "00011" or Op = "10000" or Op = "10001"));
 f(1) <= '0' when (ALU_Result(N-1) = '0' and sel = "11") else '1' when (ALU_Result(N-1) = '1' and sel = "11");                                               --sign flag
 f(2) <= '1' when (ALU_Result(N-1 downto 0) = (ALU_Result(N-1 downto 0)'range => '0') and sel = "11") else '0' when sel = "11";  --zero flag
 f(3) <= '1' when ALU_Result(N) = '1' and sel = "11"
        else (f(1) xor f(0)) when (sel = "11" and (Op = "01001" or Op = "01010" or Op = "01011" or Op = "01100" or Op = "01101" or Op = "01110" or Op = "01111"))
        else '0' when sel = "11";                                                                               --overflow flag
 f(4) <= '1' when ALU_Result(0) = '0' and sel = "11" else '0' when sel = "11";                                                 --parity flag
 C <= ALU_Result(N-1 downto 0);    -- ALU out
 flags <= f;
end Behavioral;
