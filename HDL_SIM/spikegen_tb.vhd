----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 05:39:56 PM
-- Design Name: 
-- Module Name: spikegen_tb - Behavioral
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


entity spikegen_tb is
end spikegen_tb;

architecture Behavioral of spikegen_tb is

constant clk_period : time:= 10ns; 
constant steps : integer:=  16; 

signal clk: std_logic:= '0';
signal rst: std_logic:= '0'; 
signal p_val: std_logic_vector(7 downto 0);
signal go: std_logic := '0';
signal spike: std_logic;

begin

    dut: entity work.spikegen
        port map(
            clk => clk,
            rst => rst,
            go  => go,
            p_val => p_val,
            spike => spike
        );
        
    clk <= not(clk) after clk_period/2;
    
    stim: process
    begin
        rst <= '1';
        wait for clk_period*2;
        rst <= '0';
        go  <= '1';
        p_val <= b"0011_1111";
        wait for clk_period * steps;
        p_val <= b"0111_1111";
        wait for clk_period * steps;
        go <= '0';
        p_val <= b"1111_1111";
        wait;
    end process;

end Behavioral;
