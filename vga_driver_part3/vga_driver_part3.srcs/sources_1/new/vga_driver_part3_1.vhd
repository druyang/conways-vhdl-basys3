library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_driver_part3_1 is
    Port ( clk : in  STD_LOGIC;
           --reset : in  STD_LOGIC;
           alive : in std_logic;
           RAMaddress: in std_logic_vector(10 downto 0);
           Hsync : out  STD_LOGIC;
           Vsync : out  STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (2 downto 0)
           );
end vga_driver_part3_1;



architecture Behavioral of vga_driver_part3_1 is

signal reset: std_logic := '0';

signal HDISP : integer := 639;
signal HFPorch : integer := 16;
signal HSyncPulse : integer := 96;
signal HBPorch : integer := 48;

signal VDISP : integer := 479;
signal VFPorch : integer := 10; 
signal VSyncPulse: integer := 2;
signal VBPorch : integer := 33;

signal posH : integer := 0;
signal posV : integer := 0;

--signal temp : std_logic := '0';
signal count : integer := 1;

signal VidToggle : std_logic := '0';

signal clk25: std_logic := '0';

signal blockaddressH: std_logic_vector(9 downto 0);
signal blockaddressV: std_logic_vector(8 downto 0);
--signal blockaddress: std_logic_vector(15 downto 0);
signal temp_address: std_logic_vector(10 downto 0);
signal temp_mem_address: std_logic_vector(10 downto 0);
signal counterX: unsigned(5 downto 0) := "000000";
signal counterY: unsigned(4 downto 0) := "00000";
signal counter3: unsigned(3 downto 0) := "0000";

signal vsynctemp, hsynctemp: std_logic := '0';

signal doutb: std_logic_vector (1 downto 0);
begin

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

HSync_proc : process(HDISP, HFPorch, HSyncPulse, HBPorch, posH, clk25)--took reset out
begin
	
    if (reset = '1') then
    	Hsync <= '0';
    	hsynctemp <= '0';
    elsif (rising_edge(clk25)) then
    	if (posH >= (HDISP + HFPorch) and posH <= (HDISP + HFPorch + HSyncPulse)) then
        	Hsync <= '0';
        	hsynctemp <= '0';
        else
        	Hsync <= '1';
        	hsynctemp <= '1';
        end if;
    end if;
end process;

VSync_proc : process(VDISP, VFPorch, VSyncPulse, VBPorch, reset, posV, clk25)
begin
    if (reset = '1') then
    	Vsync <= '0';
    	vsynctemp <= '0';
    elsif (rising_edge(clk25)) then
    	if (posV > (VDISP + VFPorch) and posV <= (VDISP + VFPorch + VSyncPulse)) then
        	Vsync <= '0';
        	vsynctemp <= '0';
        else
        	Vsync <= '1';
        	vsynctemp <= '1';
        end if;
    end if;
end process;

VidToggle_proc : process(VDISP, HDISP, reset, posV, posH, clk25)
begin
    if (reset = '1') then
    	VidToggle <= '0';
    elsif (rising_edge(clk25)) then
    	if (posV <= VDISP and posH <= HDISP) then
        	VidToggle <= '1';
        else
        	VidToggle <= '0';
        end if;
    end if;
end process;


posH_counter : process(clk25, reset)
begin
	if (reset = '1') then
    	posH <= 0;
    elsif (rising_edge(clk25)) then
    	if (posH = (HDISP + HFPorch + HSyncPulse + HBPorch)) then
    		posH <= 0;
    	else 
    		posH <= posH + 1;
        end if;
    end if;
end process;

posV_counter : process(clk25, reset, posH)
begin
	if (reset = '1') then
    	posV <= 0;
    elsif (rising_edge(clk25)) then
    	if (posH = (HDISP + HFPorch + HSyncPulse + HBPorch)) then
          if (posV = (VDISP + VFPorch + VSyncPulse + VBPorch)) then
              posV <= 0;
          else 
              posV <= posV + 1;
          end if;
   		end if;
    end if;
end process;

blockaddressH <= std_logic_vector( to_unsigned(posH, 10));--address location for Horizontal Position
blockaddressV <= std_logic_vector( to_unsigned(posV, 9));--address location for Vertical Position
temp_address <= blockaddressH(9 downto 4) & blockaddressV(8 downto 4);--concatenate two address locations to create 16x16 bit blocks

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


color_project_proc: process(clk25, doutb)
begin
    if rising_edge(clk25) then
            case doutb is
                when "00" =>
                    RGB <= "000";
                when "11" =>
                    RGB <= "011";
                when "01" =>
                    RGB <= "111";
                when others =>
                    RGB <= "011";
            end case;
    end if;
        --if (data_r(RAMaddress) = '1') then
         --   MEMORY(temp_address)ip 
end process;

counterMix_proc: process(clk25, counterX, counterY, counter3, hsynctemp, vsynctemp)
    begin
    
        if rising_edge(clk25) then
            counter3 <= counter3 + 1;
            if (HSYNCtemp = '1' and VSYNCtemp = '1') then
                if (counter3 = "1111") then
                    counter3 <= "0000";
                end if;
                if (counter3 = "1111") then
                    counterX <= counterX + 1;
                    if (counterX = "100111") then
                        counterY <= counterY + 1;
                        counterX <= "000000";
                        if (counterY = "11101") then
                            counterY <= "00000";
                        end if;
                    end if;
                end if;
            end if;
        end if;
end process;
temp_mem_address <= std_logic_vector(counterX) & std_logic_vector(counterY);
end architecture;
