-- Code for Full_Adder; to be used as component in Array_Multiplier --
library ieee;
use ieee.std_logic_1164.all;

entity Full_Adder is
 	port( cin, x, y : in std_logic;
 			s, cout : out std_logic);
end Full_Adder; 

architecture structure of Full_Adder is
begin
 	s <= x xor y xor cin;
 	cout <= (x and y) or (x and cin) or (y and cin);
end structure;

---------------------------------------------------------------
-- Code for Array_Multiplier --
-- multiples binary unsigned or signed (2's complement) numbers depending on mode of operation --
library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 

entity Array_Multiplier is
	generic (N: INTEGER:= 31); --since rollno. ends with 71 (2017uee0071)
 	port (A,B: in std_logic_vector (N-1 downto 0); -- Numbers to be multiplied
	 	mode: in std_logic;	-- Mode of operation: mode = '0' for unsigned
		 					-- 					mode = '1' for signed
 		P: out std_logic_vector (2*N-1 downto 0)); -- Product
end Array_Multiplier;   

architecture structure of Array_Multiplier is
 	component Full_Adder
 		port( cin, x, y : in std_logic;
 				s, cout : out std_logic);
 	end component;
 
	type Signal_Matrix is array (natural range <>, natural range <>) of std_logic;
 	signal ab: Signal_Matrix(N-1 downto 0, N-1 downto 0);
 	signal sum: Signal_Matrix(N downto 0, N downto 0);
 	signal carry: Signal_Matrix(N downto 0, N-1 downto 0);
	signal cpa_in: std_logic_vector (N downto 0);

begin
	-- Array of N*N full adders: CSA --
 	gen_row_i: for i in 0 to N-1 generate -- to generate rows
 		gen_col_j: for j in 0 to N-1 generate -- to generate columns
 			-- generate mode independet cell --
			cell_p_ij: if (i < N-1 and j < N-1) or (i = N-1 and j = N-1) generate
				ab(i,j) <= A(i) and B(j);
				fij: Full_Adder port map 
					(cin => carry(i,j), x => sum(i,j+1) , y => ab(i,j),
 					s => sum(i+1,j), cout => carry(i+1,j));
			end generate;
			-- generate mode dependent cell --
			cell_pn_ij: if (i < N-1 and j = N-1) or (i = N-1 and j < N-1) generate
				ab(i,j) <= mode xor (A(i) and B(j));
				fij: Full_Adder port map 
					(cin => carry(i,j), x => sum(i,j+1) , y => ab(i,j),
 					s => sum(i+1,j), cout => carry(i+1,j));
 			end generate;
 		end generate;
 	end generate;
	
	-- Last row : CPA --
 	gen_row_last: for j in 0 to N-1 generate
		P(j) <= sum(j+1,0);
 		carry(0,j) <= '0';
		sum(0,j+1) <= '0';
		-- CPA cell --
	 	flj: Full_Adder port map 
			(cin => carry(N,j), x => sum(N,j+1) , y => cpa_in(j),
 			s => P(N+j), cout => cpa_in(j+1)); 
		ini: if j>1 generate
			sum(j,N) <= '0';
		end generate;
	end generate;
	
	sum(N,N) <= mode;
	sum(1,N) <= mode;
	cpa_in(0) <= '0';
	
end structure;