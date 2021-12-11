LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY test_module IS
	GENERIC (
				DATA_W      : INTEGER := 8
				);
	PORT	  (
				clk_in	   : in  STD_LOGIC;
				reset_in    : in  STD_LOGIC;
				--
				data_in     : in  STD_LOGIC_VECTOR(DATA_W-1 downto 0);
				--
				out_0			: out STD_LOGIC_VECTOR(DATA_W-1 downto 0);
				out_valid_0	: out STD_LOGIC;
				--
				out_1			: out STD_LOGIC_VECTOR(DATA_W-1 downto 0);
				out_valid_1	: out STD_LOGIC;
				--
				out_2			: out STD_LOGIC_VECTOR(DATA_W-1 downto 0);
				out_valid_2	: out STD_LOGIC;
				--
				out_3			: out STD_LOGIC_VECTOR(DATA_W-1 downto 0);
				out_valid_3	: out STD_LOGIC
				);
END ENTITY test_module;

ARCHITECTURE rtl OF test_module IS

	CONSTANT c_out_count : INTEGER := 4;
	
	FUNCTION f_gen_enable(op_0 : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
		VARIABLE res : STD_LOGIC_VECTOR(op_0'length-1 downto 0) := (others => '1');
	BEGIN
		for idx in op_0'length-1 downto 1 loop
			for j in idx-1 downto 0 loop
				res(idx) := res(idx) and not(op_0(j));
			end loop;
		end loop;
		--
		RETURN res;
	END FUNCTION f_gen_enable;

	TYPE t_d2arr IS ARRAY (natural range <>) OF STD_LOGIC_VECTOR(DATA_W-1 downto 0);
	SIGNAL s_out_arr   : t_d2arr(c_out_count-1 downto 0);
	
	SIGNAL s_data_in   : STD_LOGIC_VECTOR(DATA_W-1 downto 0) 	  := (others => 'X');
	SIGNAL s_in_valid	 : STD_LOGIC := 'X';
	
	SIGNAL s_isequal   : STD_LOGIC_VECTOR(c_out_count-1 downto 0) := (others => 'X');
	
	SIGNAL s_ena       : STD_LOGIC_VECTOR(c_out_count-1 downto 0) := (others => 'X');
	
	SIGNAL s_out_valid : STD_LOGIC_VECTOR(c_out_count-1 downto 0) := (others => 'X');

BEGIN

	process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if(reset_in = '1') then
				s_in_valid <= '0';
			else
				s_in_valid <= '1';
			end if;
		end if;
	end process;

	process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if(reset_in = '1') then
				s_data_in <= (others => '0');
			else
				s_data_in <= data_in;
			end if;
		end if;
	end process;
	
eq_gen:
	for idx in (s_isequal'length-1) downto 0 generate
	begin
		s_isequal(idx) <= '1' when (s_out_arr(idx) = s_data_in) else '0';
	end generate eq_gen;
	
	s_ena <= f_gen_enable(s_isequal);
	
	process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			for idx in s_out_arr'length-1 downto 0 loop
				if((reset_in or not(s_in_valid) or s_ena(idx)) = '1') then
					if((reset_in or not(s_in_valid)) = '1') then
						s_out_valid(idx) <= '0';
						s_out_arr(idx)   <= (others => '0');
					else
						if(idx > 0) then
							s_out_valid(idx) <= s_out_valid(idx-1);
							s_out_arr(idx)   <= s_out_arr(idx-1);
						else
							s_out_valid(idx) <= '1';
							s_out_arr(idx)   <= s_data_in;
						end if;
					end if;
				end if;
			end loop;
		end if;
	end process;	

	out_0 		<= s_out_arr(0);
	out_valid_0 <= s_out_valid(0);
	--
	out_1 		<= s_out_arr(1);
	out_valid_1 <= s_out_valid(1);
	--
	out_2 		<= s_out_arr(2);
	out_valid_2 <= s_out_valid(2);
	--
	out_3 		<= s_out_arr(3);
	out_valid_3 <= s_out_valid(3);
	
END rtl;
