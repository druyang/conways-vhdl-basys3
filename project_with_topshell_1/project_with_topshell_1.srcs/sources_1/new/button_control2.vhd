library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.NUMERIC_STD.ALL;


entity button_control is 
	Port ( clk : in std_logic; 
		reset : in std_logic; 
		btnl : in std_logic; 
		btnu : in std_logic; 
		btnd : in std_logic; 
		btnr : in std_logic; 
		btnc : in std_logic;
		write_en : out std_logic;
		write_addr: out std_logic_vector(10 downto 0);
		write_data: out std_logic_vector(1 downto 0)
		); 
end button_control; 

architecture Behavioral of button_control is 

type statetype is (idle, update_current, update_next); 
signal current_state, next_state : statetype := idle; 

-- monopulsed signals
signal btnl_mp, btnu_mp, btnd_mp,  btnr_mp,  btnc_mp: std_logic := '0';				
-- synchronizer signals, source from lab 4 			
signal btnl_sync, btnu_sync, btnd_sync, btnr_sync, btnc_sync: std_logic_vector(1 downto 0) := "00";	
signal btnout, btnold : std_logic_vector(4 downto 0) := "00000"; 
signal x_cord, y_cord : unsigned(5 downto 0) := (others => '0'); 
signal data_out : std_logic_vector(1 downto 0) := "00";
signal leftsignal, rightsignal, upsignal, downsignal, centersignal, datasignal, write_signal: std_logic := '0';

begin 
monopulser: process(clk, btnl_sync, btnu_sync, btnd_sync, btnr_sync, btnc_sync)
begin	
	if rising_edge(clk) then	
		btnl_sync <= btnl & btnl_sync(1);	
		btnu_sync <= btnu & btnu_sync(1);
		btnd_sync <= btnd & btnd_sync(1);
		btnr_sync <= btnr & btnr_sync(1);
		btnc_sync <= btnc & btnc_sync(1);
	end if;
	
	btnl_mp <= btnl_sync(1) and not(btnl_sync(0));
	btnu_mp <= btnu_sync(1) and not(btnu_sync(0));
	btnd_mp <= btnd_sync(1) and not(btnd_sync(0));
	btnr_mp <= btnr_sync(1) and not(btnr_sync(0));
	btnc_mp <= btnc_sync(1) and not(btnc_sync(0));

	btnout <= btnc_mp & btnl_mp & btnu_mp & btnd_mp & btnr_mp;

end process monopulser;

 
memory_ui : process(btnout, current_state) 
begin 

		case current_state is 

          
			when idle => 
          		datasignal <= '0';
          		write_signal <= '0';
				if btnout /= "00000" then
					write_signal <= '1'; 
					next_state <= update_current;
				end if ;

			-- state for updating the current address' values
			when update_current => 
				
				next_state <= update_next;

				if btnout = "01000" then
					leftsignal <= '1';
					upsignal <= '0'; 
					downsignal <= '0';
					rightsignal <= '0';
					centersignal <= '0';
	          		datasignal <= '0'; 
	          		write_signal <= '0'; 					
				elsif btnout = "00100" then
					upsignal <= '1';
          		leftsignal <= '0';
				downsignal <= '0';
				rightsignal <= '0';
				centersignal <= '0';
          		datasignal <= '0'; 
          		write_signal <= '0';
				elsif btnout = "00010" then
					downsignal <= '1'; 
          		leftsignal <= '0';
				upsignal <= '0'; 
				rightsignal <= '0';
				centersignal <= '0';
          		datasignal <= '0'; 
          		write_signal <= '0';
				elsif btnout = "00001" then
					rightsignal <= '1';	
          		leftsignal <= '0';
				upsignal <= '0'; 
				downsignal <= '0';
				centersignal <= '0';
          		datasignal <= '0'; 		
          		write_signal <= '0';		
				elsif btnout = "10000" then
					centersignal <= '1';	
          		leftsignal <= '0';
				upsignal <= '0'; 
				downsignal <= '0';
				rightsignal <= '0';
          		datasignal <= '0'; 	
          		write_signal <= '0';						
				end if ;

			-- state for updating the next cell's address and values based off of movement
			when update_next =>
				datasignal <= '1'; 
				centersignal <= '0';	
          		leftsignal <= '0';
				upsignal <= '0'; 
				downsignal <= '0';
				rightsignal <= '0';
				write_signal <= '1'; 
				next_state <= idle;	
		end case;

 
end process memory_ui;

-- 00 sel' alive'
-- 01 se' alive' 
-- 10 sel 
-- 11 sel 

datapath : process(clk)
begin

	if rising_edge(clk) then
		
		if leftsignal = '1' then
  			if x_cord = 0 then
				x_cord <= "100111";
			else
				x_cord <= x_cord - 1;
			end if ;
		elsif upsignal = '1' then
			if y_cord = 0 then
				y_cord <= "011101";
			else
				y_cord <= y_cord - 1;
			end if ;	
		elsif downsignal = '1' then
			if y_cord = "011101" then
              y_cord <= (others => '0');
			else
			 	y_cord <= y_cord + 1;
			end if ;	
		elsif rightsignal = '1' then
			if x_cord = "100111" then
				x_cord <= (others => '0');
			else
			 	x_cord <= x_cord + 1;	
			end if;
		end if ;

		if centersignal = '1' then
			data_out(0) <= not data_out(0);																
        elsif datasignal = '1' then 
          	data_out(1) <= '1';
		else
			data_out(1) <= '0';
		end if ;

		if write_signal = '1' then 
			write_en <= '1';
		else 
			write_en <= '0'; 
		end if; 
	
	end if ;
	
    write_addr <= std_logic_vector(x_cord) & std_logic_vector(y_cord(4 downto 0)); 
    write_data <= data_out;
end process datapath;
 
state_update : process(clk, reset)
begin
	if reset = '1' then
	 	current_state <= idle;
	 elsif rising_edge(clk) then
	 	current_state <= next_state;
 	
 	end if ; 
end process state_update;

end Behavioral; 