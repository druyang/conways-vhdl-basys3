----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/30/2019 04:33:57 PM
-- Design Name: 
-- Module Name: gamecontrol - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.NUMERIC_STD.ALL;


-- In the top controller, you need to make a clocked process that runs at a slow clock
-- The process will flip the read_address and write_address between the RAM for the current frame and next frame every clock cycle
entity gamelogic is 
	Port (
		gamelogic_en : in std_logic; 
		read_address : in std_logic_vector(10 downto 0 ); 
		read_data : in std_logic_vector(1 downto 0 ); 
		read_enable : in std_logic; 
		write_address	:	out std_logic_vector(10 downto 0); 
		write_data : out std_logic_vector(1 downto 0); 
		write_enable : out std_logic_vector
		); 
end gamelogic; 

architecture Behavioral of gamelogic is 
signal alive_reg : std_logic_vector(2 downto 0) := "00"; 
signal n_count : unsigned(3 downto 0) := "0000";  

begin

datapath: process(gamelogic_en)
begin

if rising_edge(gamelogic_en) then

	-- loops cross the cell grid 
	loop_vertical : for i in 1 to 28 loop 
		loop_horizontal : for j in 1 to 38 loop
			
			-- loops to check if neighbors are live or ded 
			-- checks in a 3x3 grid around the active cell 
				check_loop_vertical : for k in i-1 to i+1 loop
					check_loop_horizontal : for l in j-1 to j+1 loop
						read_address <= std_logic_vector(l) & std_logic_vector(k);
						read_enable <= '1';
						alive_reg <= read_data;

						-- if statement adds up number of alive neighbors 
						if alive_reg(0) = '1' then
							n_count <= n_count + 1; 
						end if ;
					end loop ; -- check_loop_horizontal
				end loop ; -- check_loop_vertical

			-- final neighbor count determines if the cell in the next frame is alive or dead 

			write_address <= std_logic_vector(j) & std_logic_vector(i);
			if n_count < 2 or n_count > 3 then
				write_data <= "00";
			elsif n_count = 3 or n_count = 2 then
				write_data <= "01";
			end if ;

			write_enable <= '1';

		end loop ; -- loop_horizontal
	end loop; -- loop_vertical
	
end if ;

end process; 

end Behavioral; 

