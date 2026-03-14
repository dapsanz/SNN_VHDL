----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2026 12:14:25 AM
-- Design Name: 
-- Module Name: FIFO - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FIFO is
  Generic(
        w     : integer := 10;
        depth : integer:= 7 --  bits of depth
  );
  Port( 
        clk   : in  std_logic;
        rst   : in  std_logic;
        din   : in  std_logic_vector(w-1 downto 0);           
        read  : in  std_logic;
        write : in  std_logic;
        full  : out std_logic;
        empty : out std_logic;
        dout  : out std_logic_vector(w-1 downto 0)
  );
end FIFO;



architecture Behavioral of FIFO is

signal addr      : std_logic_vector(depth-1 downto 0);
signal pop_addr  : unsigned(depth-1 downto 0) := (others => '0'); 
signal push_addr : unsigned(depth-1 downto 0) := (others => '0');
signal count     : unsigned(depth downto 0) := (others => '0');

constant FIFO_FULL : unsigned(depth-1 downto 0):= (others => '1');
begin
    u_ram_fifo : entity work.BRAM
    generic map (
        k => depth,
        w => w
    )
    port map(
        clk => clk,
        we => write,
        addr => addr,
        din  => din,
        dout => dout        
    );
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if rst = '1' then
                    push_addr <= (others => '0');
                    pop_addr  <= (others => '0');
                    count     <= (others => '0');
            else 
                if (write = '1' and read = '0') then
                    push_addr <= push_addr + 1;
                    count     <= count + 1;
                elsif (write = '0' and read = '1') then
                    pop_addr  <= pop_addr + 1;
                    count     <= count - 1;
                elsif (write = '1' and read = '1') then
                    push_addr <= push_addr + 1;
                    pop_addr  <= pop_addr + 1;
                end if;
            end if;
        end if;
    end process;
    
    addr <= std_logic_vector(push_addr) when write = '1' else std_logic_vector(pop_addr);
    empty <= '1' when (count = 0) else '0';
    full  <= '1' when (count = 2**depth) else '0';
    
end Behavioral;
