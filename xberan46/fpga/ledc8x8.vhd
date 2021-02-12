-- Autor reseni: Tomas Beranek, xberan46

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port (
	RESET : in std_logic;
	SMCLK : in std_logic;
	ROW : out std_logic_vector(0 to 7);
	LED : out std_logic_vector(0 to 7);
);
end ledc8x8;

architecture main of ledc8x8 is

    -- Sem doplnte definice vnitrnich signalu.

	signal FIRST_TICK : std_logic := '0';
	signal SECOND_TICK : std_logic := '0';
	signal TIME_COUNT : integer; 			--minimalne frekvence (1s) muze byt i promenna
	signal CE_COUNT : std_logic_vector(7 downto 0);
	signal CE : std_logic := '0';
	signal ROW_TMP : std_logic_vector(0 to 7);
	signal LED_TMP : std_logic_vector(0 to 7) := "11111111";

begin

	timer: process (RESET, SMCLK)
	begin
		if RESET = '1' then
			FIRST_TICK <= '0';
			SECOND_TICK <= '0';
			TIME_COUNT <= 0;
			CE_COUNT <= (others => '0');
		elsif (SMCLK'event) and (SMCLK = '1') then
			CE_COUNT <= CE_COUNT + 1;
			if TIME_COUNT = 3686400 then				--frekvence/2
				FIRST_TICK <= '1';
				TIME_COUNT <= TIME_COUNT + 1;
			elsif TIME_COUNT = 7372800 then			--frekvence
				SECOND_TICK <= '1';
				TIME_COUNT <= TIME_COUNT + 1;
			elsif TIME_COUNT > 7372800 then
											--do nothing
			else
				TIME_COUNT <= TIME_COUNT + 1;
			end if;
		end if;
	end process timer;

	CE <= '1' when (CE_COUNT = "11111111") else '0';  --mozna CE_COUNT(0) -zkusit


	change_row: process (RESET, CE, SMCLK)
	begin
		if (RESET = '1') then
			ROW_TMP <= "10000000";
		elsif (SMCLK'event) and (SMCLK = '1') then
			if CE = '1' then
				ROW_TMP <= ROW_TMP(7) & ROW_TMP(0 to 6);
			end if;
		end if;
	end process change_row;

	ROW <= ROW_TMP;

	active_leds: process (ROW_TMP, SMCLK)
	begin
		if (SMCLK'event) and (SMCLK = '1') then
			if (FIRST_TICK = '1') and (SECOND_TICK = '0') then
				LED_TMP <= "11111111";
			else
				if ROW_TMP = "10000000" then
					LED_TMP <= "00000001";
				elsif ROW_TMP = "01000000" then
					LED_TMP <= "11010110";
				elsif ROW_TMP = "00100000" then
					LED_TMP <= "11010110";
				elsif ROW_TMP = "00010000" then
					LED_TMP <= "11010001";
				elsif ROW_TMP = "00001000" then
					LED_TMP <= "11010001";
				elsif ROW_TMP = "00000100" then
					LED_TMP <= "11010110";
				elsif ROW_TMP = "00000010" then
					LED_TMP <= "11010110";
				elsif ROW_TMP = "00000001" then
					LED_TMP <= "11010001";
				end if;
			end if;
		end if;
	end process active_leds;
	LED <= LED_TMP;
end main;

-- ISID: 75579
