----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2026 10:07:03 PM
-- Design Name: 
-- Module Name: spikegen - Behavioral
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

entity spikegen is
    Port (
        clk    : in std_logic;
        rst    : in std_logic;

        p_val : in std_logic_vector(7 downto 0);
        go    : in std_logic;
        spike : out std_logic
        
     );
end spikegen;


architecture Behavioral of spikegen is

signal lfsr: std_logic_vector(15 downto 0) := x"FADE";
signal random_num : unsigned(7 downto 0);

begin
    
    random_num <= unsigned(lfsr(15 downto 8));
    process(clk)
        variable feedback : std_logic;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                lfsr <= x"FADE"; -- Reset to seed
            elsif go = '1' then
                -- Standard feedback taps for 16-bit LFSR
                feedback := lfsr(15) xor lfsr(14) xor lfsr(12) xor lfsr(3);
                lfsr <= lfsr(14 downto 0) & feedback;
            end if;
        end if;
    end process;

    -- Spike Generation Logic
    process(p_val, random_num, go)
    begin
        if go = '1' then
            if unsigned(p_val) > random_num then
                spike <= '1';
            else
                spike <= '0';
            end if;
        else
            spike <= '0';
        end if;
    end process;
end Behavioral;
