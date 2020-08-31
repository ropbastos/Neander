library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           acc : out  STD_LOGIC_VECTOR(7 downto 0);
			  PCdata : out STD_LOGIC_VECTOR(7 downto 0));
end main;

architecture Structural of main is

	-- ## COMPONENTS ##

	component ALU
		 Port ( X : in  STD_LOGIC_VECTOR(7 downto 0);
				  Y : in  STD_LOGIC_VECTOR(7 downto 0);
				  selALU : in  STD_LOGIC_VECTOR(2 downto 0);
				  Nflag : out  STD_LOGIC;
				  Zflag : out  STD_LOGIC;
				  result : out  STD_LOGIC_VECTOR (7 downto 0));
	end component;

	component controlUnit
		 Port ( clk : in  STD_LOGIC;
				  rst : in  STD_LOGIC;
				  Nflag : in  STD_LOGIC;
				  Zflag : in  STD_LOGIC;
				  opCode : in  STD_LOGIC_VECTOR (3 downto 0);
				  loadPC : out  STD_LOGIC;
				  incPC : out  STD_LOGIC;
				  remMuxSel : out  STD_LOGIC;
				  remLoad : out  STD_LOGIC;
				  readCtrl : out  STD_LOGIC;
				  writeCtrl : out  STD_LOGIC_VECTOR(0 downto 0);
				  rdmLoad : out  STD_LOGIC;
				  accLoad : out  STD_LOGIC;
				  selALU : out  STD_LOGIC_VECTOR(2 downto 0);
				  nzLoad : out  STD_LOGIC;
				  riLoad : out  STD_LOGIC);
	end component;

	component dff
		 Port ( clk : in  STD_LOGIC;
				  rst : in  STD_LOGIC;
				  en : in  STD_LOGIC;
				  D : in  STD_LOGIC;
				  Q : out  STD_LOGIC);
	end component;

	component mux2to1
		 Port ( in0 : in  STD_LOGIC_VECTOR (7 downto 0);
				  in1 : in  STD_LOGIC_VECTOR (7 downto 0);
				  sel : in  STD_LOGIC;
				  dataOut : out  STD_LOGIC_VECTOR (7 downto 0));
	end component;

	component programCounter
		 Port ( clk : in  STD_LOGIC;
				  rst : in  STD_LOGIC;
				  inc : in  STD_LOGIC;
				  load : in  STD_LOGIC;
				  D : in  STD_LOGIC_VECTOR (7 downto 0);
				  Q : out  STD_LOGIC_VECTOR (7 downto 0));
	end component;

	component reg8bits
		 Port ( clk : in  STD_LOGIC;
				  rst : in  STD_LOGIC;
				  en : in  STD_LOGIC;
				  D : in  STD_LOGIC_VECTOR (7 downto 0);
				  Q : out  STD_LOGIC_VECTOR (7 downto 0));
	end component;

	COMPONENT ram256add8bits
	  PORT (
		 clka : IN STD_LOGIC;
		 rsta : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	  );
	END COMPONENT;

	-- ## SIGNALS ##

	-- Control signals
	signal loadPC : STD_LOGIC;
	signal incPC : STD_LOGIC;
	signal remMuxSel : STD_LOGIC;
	signal remLoad : STD_LOGIC;
	signal readCtrl : STD_LOGIC;
	signal writeCtrl : STD_LOGIC_VECTOR(0 downto 0);
	signal rdmLoad : STD_LOGIC;
	signal accLoad : STD_LOGIC;
	signal selALU : STD_LOGIC_VECTOR(2 downto 0);
	signal nzLoad : STD_LOGIC;
	signal riLoad : STD_LOGIC;

	-- Component linkage signals
	signal PCout : std_logic_vector(7 downto 0);
	signal remMuxOut : std_logic_vector(7 downto 0);
	signal remOut : std_logic_vector(7 downto 0);
	signal rdmMuxOut : std_logic_vector(7 downto 0);
	signal rdmOut : std_logic_vector(7 downto 0);
	signal ramOut : std_logic_vector(7 downto 0);
	signal accOut : std_logic_vector(7 downto 0);
	signal ALUresult : std_logic_vector(7 downto 0);
	signal ALUnFlag : std_logic;
	signal ALUzFlag : std_logic;
	signal nFFOut : std_logic;
	signal zFFOut : std_logic;
	signal riOut : std_logic_vector(7 downto 0);

begin

	-- PORT MAPPINGS
	ram : ram256add8bits
	 PORT MAP (
		clka => clk,
		rsta => rst,
		wea => writeCtrl,
		addra => remOut,
		dina => rdmOut,
		douta => ramOut
	 );
  
	ALU_inst : ALU
	 PORT MAP ( 
		X => accOut,
		Y => rdmOut,
		selALU => selALU,
		Nflag => ALUnFlag,
		Zflag => ALUzFlag,
		result => ALUresult
	 );
	
	controlUnit_inst : controlUnit
	 PORT MAP ( 
	  clk => clk,
	  rst => rst,
	  Nflag => nFFout,
	  Zflag => zFFout,
	  opCode => riOut(7 downto 4),
	  loadPC => loadPC,
	  incPC => incPC,
	  remMuxSel => remMuxSel,
	  remLoad => remLoad,
	  readCtrl => readCtrl,
	  writeCtrl => writeCtrl,
	  rdmLoad => rdmLoad,
	  accLoad => accLoad,
	  selALU => selALU,
	  nzLoad => nzLoad,
	  riLoad => riLoad
	 );

	Zflag : dff
	 PORT MAP ( 
	  clk => clk,
	  rst => rst,
	  en => nzLoad,
	  D => ALUzFlag,
	  Q => zFFout
	 );

	Nflag : dff
	 PORT MAP ( 
	  clk => clk,
	  rst => rst,
	  en => nzLoad,
	  D => ALUnFlag,
	  Q => nFFout
	 );

	remMux : mux2to1
	 PORT MAP ( 
	  in0 => PCout,
	  in1 => rdmOut,
	  sel => remMuxSel,
	  dataOut => remMuxOut
	 );
		 
	rdmMux : mux2to1
	 PORT MAP ( 
	  in0 => accOut,
	  in1 => ramOut,
	  sel => readCtrl,
	  dataOut => rdmMuxOut
	 );

	PC : programCounter
	 PORT MAP ( 
	  clk => clk,
	  rst => rst,
	  inc => incPC,
	  load => loadPC,
	  D => rdmOut,
	  Q => PCout
	 );

	remReg : reg8bits
	 PORT MAP ( 
	  clk => clk,
	  rst => rst,
	  en => remLoad,
	  D => remMuxOut,
	  Q => remOut
	 );
	 
	rdmReg : reg8bits
	 PORT MAP ( 
	  clk => clk,
	  rst => rst,
	  en => rdmLoad,
	  D => rdmMuxOut,
	  Q => rdmOut
	 );
	 
	riReg : reg8bits
	 PORT MAP ( 
	  clk => clk,
	  rst => rst,
	  en => riLoad,
	  D => rdmOut,
	  Q => riOut
	 );
	 
	accReg : reg8bits
	 PORT MAP ( 
	  clk => clk,
	  rst => rst,
	  en => accLoad,
	  D => ALUresult,
	  Q => accOut
	 );
	 -- SIGNAL MAPPINGS
	 
	 acc <= accOut;
	
	 PCdata <= PCout;

end Structural;

