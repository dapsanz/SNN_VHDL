----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 11:07:03 PM
-- Design Name: 
-- Module Name: randgen - Behavioral
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

entity randgen is
    Port (
        rst    : in std_logic;
        clk    : in std_logic;
        random_val: out std_logic_vector(7 downto 0)
     );
end randgen;


architecture Behavioral of randgen is

signal lfsr: std_logic_vector(15 downto 0) := x"FADE";

begin
    
    random_val <= (lfsr(15 downto 8));
    process(clk)
        variable feedback : std_logic;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                lfsr <= x"FADE"; 
            else
                feedback := lfsr(15) xor lfsr(14) xor lfsr(12) xor lfsr(3);
                lfsr <= lfsr(14 downto 0) & feedback;
            end if;
        end if;
    end process;

end Behavioral;
