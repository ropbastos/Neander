library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux2to1 is
    Port ( in0 : in  STD_LOGIC_VECTOR (7 downto 0);
           in1 : in  STD_LOGIC_VECTOR (7 downto 0);
           sel : in  STD_LOGIC;
           dataOut : out  STD_LOGIC_VECTOR (7 downto 0));
end mux2to1;

architecture Dataflow of mux2to1 is

begin
	
	dataOut <= in0 when (sel = '0') else in1;
			
end Dataflow;

