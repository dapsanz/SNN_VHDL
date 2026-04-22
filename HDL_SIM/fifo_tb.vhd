----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 05:38:31 PM
-- Design Name: 
-- Module Name: fifo_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity fifo_tb is
end fifo_tb;

architecture Behavioral of fifo_tb is

constant clk_period : time:= 10ns; 

signal clk: std_logic:= '0';
signal rst: std_logic:= '0'; 
signal din: std_logic_vector(9 downto 0):= (others => '0');
signal dout: std_logic_vector(9 downto 0);
signal full: std_logic;
signal empty: std_logic;
signal read: std_logic:='0';
signal write: std_logic:='0';

begin

    dut: entity work.fifo
        port map(
            clk => clk,
            rst => rst,
            din  => din,
            dout => dout,
            read => read,
            write => write,
            full => full,
            empty => empty
        );
        
    clk <= not(clk) after clk_period/2;
    
    stim: process
    begin
        wait until rising_edge(clk);
        rst <= '1';
        wait for clk_period*2;
        rst <= '0';
        write <= '1';
        for i in 0 to 127 loop
            din <= std_logic_vector(unsigned(din) + 1);
            wait for clk_period;
        end loop;
        write <= '0';
        wait for clk_period;
        read <= '1';
        wait for clk_period*128;
    end process;

end Behavioral;
