library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity vga_driver_part3_1_tb is
end vga_driver_part3_1_tb;





architecture Behavioral of vga_driver_part3_1_tb is

component vga_driver_part3_1 is
    Port ( clk : in  STD_LOGIC;
           --reset : in  STD_LOGIC;
           doutb: in std_logic_vector(1 downto 0);
           RAMaddress: in std_logic_vector(10 downto 0);
           Hsync : out  STD_LOGIC;
           Vsync : out  STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (2 downto 0));
end component;
 
signal clk: std_logic := '0';
signal doutb: std_logic_vector(1 downto 0) := "00";
signal RAMaddress:  std_logic_vector(10 downto 0);
signal Hsync :   STD_LOGIC := '0';
signal Vsync :   STD_LOGIC := '0';
signal RGB :   STD_LOGIC_VECTOR (2 downto 0);
--signal reset: std_logic := '0';

--signal HDISP : integer := 639;
--signal HFPorch : integer := 16;
--signal HSyncPulse : integer := 96;
--signal HBPorch : integer := 48;

--signal VDISP : integer := 479;
--signal VFPorch : integer := 10; 
--signal VSyncPulse: integer := 2;
--signal VBPorch : integer := 33;

--signal posH : integer := 0;
--signal posV : integer := 0;

----signal temp : std_logic := '0';
signal count : integer := 0;

--signal VidToggle : std_logic := '0';

signal clk25: std_logic := '0';

--signal blockaddressH: std_logic_vector(9 downto 0);
--signal blockaddressV: std_logic_vector(8 downto 0);
----signal blockaddress: std_logic_vector(15 downto 0);
--signal temp_address: std_logic_vector(10 downto 0);
--signal temp_mem_address: std_logic_vector(10 downto 0);
--signal counterX: unsigned(5 downto 0) := "000000";
--signal counterY: unsigned(4 downto 0) := "00000";
--signal counter3: unsigned(3 downto 0) := "0000";

--signal vsynctemp, hsynctemp: std_logic := '0';

--signal doutb: std_logic_vector (1 downto 0);
constant clk_period : time := 40 ns;

begin

dut : vga_driver_part3_1 PORT MAP(
		clk  => clk,
        doutb => doutb,
		RAMaddress => RAMaddress,
        hsync => hsync,
        vsync 	=> vsync,
        rgb => rgb);
--component blk_mem_gen_0 IS
--  PORT (
--    clka : IN STD_LOGIC;
--    ena : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
--    clkb : IN STD_LOGIC;
--    enb : IN STD_LOGIC;
--    addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
--    doutb : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
--  );
--END component;
clk_proc:process
begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
end process;

clk_div: process (clk)
begin
if(rising_edge(clk)) then
	count <=count+1;
	if (count = 4) then
		clk25 <= NOT clk25;
		count <= 1;
	end if;
	--clk25 <= temp;
end if;
end process;

stim_proc: process
	begin
    RAMaddress <= "00000000000";
    doutb <= "10";
    wait for 10*clk_period;
    RAMaddress <= "00000000001";
    doutb <= "01";
    wait for 10*clk_period;
    RAMaddress <= "00000000010";
    doutb <= "01";
    wait for 10*clk_period;
    RAMaddress <= "00000000010";
    doutb <= "11";
    wait;
end process;


end architecture;
