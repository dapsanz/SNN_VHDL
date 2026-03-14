----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Diego Perez Sanchez
-- 
-- Create Date: 02/27/2026 12:35:27 PM
-- Design Name: 
-- Module Name: neuron - Behavioral
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

entity neuron is
  Port ( 
        I_in  : in std_logic_vector(7 downto 0);   -- Weight
        V_in  : in std_logic_vector(15 downto 0);  -- Current Potential
        leak  : in std_logic;                     -- Control: '0' = Integrate, '1' = Leak/Fire
        V_out : out std_logic_vector(15 downto 0);
        spike : out std_logic
  );
end neuron;
   
architecture Behavioral of neuron is

    constant THRESHOLD : signed(15 downto 0) := to_signed(175, 16);

    signal v_s      : signed(15 downto 0);
    signal v_leaked : signed(15 downto 0);
    signal v_next   : signed(15 downto 0);

begin

    v_s <= signed(V_in);


    v_leaked <= v_s - shift_right(v_s, 1) when leak = '1' else v_s;
    v_next   <= v_leaked + resize(signed(I_in), 16) when leak = '0' else v_leaked;


    spike <= '1' when (leak = '1' and v_leaked >= THRESHOLD) else '0';
    V_out <= (others => '0') when (leak = '1' and v_leaked >= THRESHOLD) else 
             std_logic_vector(v_next);
end behavioral;