----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2026 02:59:44 PM
-- Design Name: 
-- Module Name: REG - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity REG is
    Generic(
           w : integer := 32
    );
    Port ( D : in std_logic_vector(w-1 downto 0);
           Q : out std_logic_vector (w-1 downto 0);
           clk : in std_logic;
           rst : in std_logic;
           en : in std_logic);
end REG;

architecture Behavioral of REG is

signal data: std_logic_vector(w-1 downto 0);

begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            if (rst = '1') then
                data <= (others => '0');
            elsif(en ='1') then
                data <= D;
            end if;
        end if;
    end process;
    
    Q <= data;
    
end Behavioral;
