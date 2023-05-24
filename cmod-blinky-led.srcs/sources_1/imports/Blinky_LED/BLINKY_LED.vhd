-------------------------------------------------------------------------------
-- COMPANY: 	 FEDEVEL
--
-- ENGINEER:	 Jordan Christman
--
-- MODULE NAME:  BLINKY_LED
--
-- DESCRIPTION:  Uses a counter that will blink all LEDs on / off at regular 
--				 intervals. The blink rate is changeable through the generic 
--				 of the design. There is an active low reset that when
--				 asserted low will cause the count to reset and turn the
--				 leds off.
--
-- REVISION:	 1.0 - 11/20/2017 File Created.
--
-- COMMENTS:	 All the LEDs will turn on and off simultaneously. In order
--				 to change this, the initial value set in the 'led_reg' 
--				 register will need to be changed.
-------------------------------------------------------------------------------

-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;

-- Entity
entity BLINKY_LED is
	Generic (
		NUM_LEDS		: integer := 4;			-- 8 LEDs default
		CLK_RATE		: integer := 12000000; -- 50 MHz default
		BLINK_RATE 	: integer := 2);			-- 2 Hz default
	Port (
		Led_Out			: out std_logic_vector(NUM_LEDS - 1 downto 0);
		Clk				: in std_logic;
		Reset				: in std_logic);		-- Active Low
end BLINKY_LED;

-- Architecture
architecture behavior of BLINKY_LED is

-- Calculate count value to achieve 'BLINK_RATE' from generic
constant MAX_VAL		: integer := CLK_RATE / BLINK_RATE;

-- Calculate number of bits required to count to 'MAX_VAL'
constant BIT_DEPTH 	: integer := integer(ceil(log2(real(MAX_VAL))));

-- Register to hold the current count value
signal count_reg   	: unsigned(BIT_DEPTH - 1 downto 0) := (others => '0');

-- Register to hold the value of output LEDs
signal led_reg	   	: std_logic_vector(NUM_LEDS - 1 downto 0) := "1010";
	
	begin
		-- Assign output LED values
		Led_Out <= led_reg;
	
		-- Process that increments the counter every rising clock edge
		count_proc: process(Clk)
		begin
			if rising_edge(Clk) then
				if((reset = '0') or (count_reg = MAX_VAL)) then
					count_reg <= (others => '0');
				else
					count_reg <= count_reg + 1;
				end if;
			end if;
		end process;

		-- Process that will toggle the LED output every time the counter
		-- reaches the calculated 'MAX_VAL'
		output_proc: process(Clk)
		begin
		  if rising_edge(Clk) then
			if (count_reg = MAX_VAL) then
				led_reg <= NOT led_reg;
			end if;
		end if;
	end process;
end behavior;
