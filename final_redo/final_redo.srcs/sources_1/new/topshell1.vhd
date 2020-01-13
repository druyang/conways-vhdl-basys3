----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/30/2019 04:24:53 PM
-- Design Name: 
-- Module Name: game_topshell - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity game_topshell is
Port ( 
           mclk: in std_logic;
           --Buttons
           reset: in std_logic;
           btnl: in std_logic;
           btnu: in std_logic;
           btnd: in std_logic;
           btnr: in std_logic;
           btnc: in std_logic;
           --VGA 
           color: out std_logic_vector(11 downto 0);
           Hsync : out  STD_LOGIC := '1';
           Vsync : out  STD_LOGIC := '1'
           --Game Controller

           );
end game_topshell;

architecture Behavioral of game_topshell is

signal count1: integer := 1;
signal clk1_unbuf: std_logic := '0';
signal clk1: std_logic := '0';
signal temp_address: std_logic_vector(10 downto 0);
signal doutb_temp1: std_logic_vector(1 downto 0);
signal clk1MHz: std_logic := '0';
signal clk1MHz_unbuf: std_logic := '0';
signal count2: integer := 1;
signal temp_write_en: std_logic := '0';
signal temp_address_in: std_logic_vector(10 downto 0):= "00000000000";
signal temp_data_in: std_logic_vector(1 downto 0):= "00";
signal UNSURE: std_logic_vector(0 downto 0) := "1";
component vga_working is
port (     clk: in std_logic;
           doutb1: in std_logic_vector(1 downto 0);
           RAMaddress: out std_logic_vector(10 downto 0);
           color: out std_logic_vector(11 downto 0);
           Hsync : out  STD_LOGIC := '1';
           Vsync : out  STD_LOGIC := '1';
           reset : in std_logic := '0');
end component;

component button_control is 
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
end component; 

component blk_mem_gen_1 IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END component;
begin

display_to_vga2: vga_working 
port map( 
        clk => mclk, 
        doutb1 => doutb_temp1,
        RAMaddress => temp_address,
        color => color,
        Hsync => Hsync,
        Vsync => Vsync,
        reset => reset
        );

RAM_0_Port: blk_mem_gen_1
  port map (
    clka => mclk,
    ena => temp_write_en,
    wea => UNSURE,
    addra => temp_address_in,
    dina => temp_data_in,
    clkb => mclk,
    enb => '1', 
    addrb => temp_address,
    doutb => doutb_temp1
  );
button_control_port: button_control 
	Port map( 
	    clk => mclk,
		reset => reset,  
		btnl => btnl,
		btnu => btnu,
		btnd => btnd,
		btnr => btnr,
		btnc => btnc,
		write_en => temp_write_en,
		write_addr => temp_address_in,
		write_data => temp_data_in
		); 
clk_div1Hz: process (mclk)
begin
if (rising_edge(mclk)) then
	count1 <=count1+1;
	if (count1 = 500000) then
		clk1_unbuf <= NOT clk1_unbuf;
		count1 <= 1;
	end if;
end if;
end process;

Slow_clock_buffer: BUFG
	port map (I => clk1_unbuf,
		      O => clk1);
		     
		     
clk_div1MHz: process (mclk)
begin
if (rising_edge(mclk)) then
	count2 <=count2+1;
	if (count2 = 50) then
		clk1MHz_unbuf <= NOT clk1Mhz_unbuf;
		count2 <= 1;
	end if;
end if;
end process;

Slow_clock_buffer2: BUFG
	port map (I => clk1MHz_unbuf,
		      O => clk1MHz);
		     
end Behavioral;
