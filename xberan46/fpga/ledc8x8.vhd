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

begin

	timer: procces(RESET, SMCLK)
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

	CE <= '1' when (CE_COUNT = "11111111") else '0';


	change_row: procces(RESET, CE)
	begin
		if (RESET = '1') then
			ROW <= "10000000"
		elsif (CE'event) and (CE = '1') then
			ROW <= ROW(7) & ROW(0 to 6);
		end if;
	end process active_row;
	

	active_leds: procces (ROW)
	begin
		if (FIRST_TICK = '1') and (SECOND_TICK = '0') then
			LED <= "00000000";
		else
			with ROW select
				LED <= "11111110" when "10000000",
				  	"00101001" when "01000000",
				  	"00101001" when "00100000",
				  	"00101110" when "00010000",
				  	"00101110" when "00001000",
				  	"00101001" when "00000100",
				  	"00101001" when "00000010",
				  	"00101110" when "00000001";
		end if;
	end process active_leds;	




    -- Sem doplnte popis obvodu. Doporuceni: pouzivejte zakladni obvodove prvky
    -- (multiplexory, registry, dekodery,...), jejich funkce popisujte pomoci
    -- procesu VHDL a propojeni techto prvku, tj. komunikaci mezi procesy,
    -- realizujte pomoci vnitrnich signalu deklarovanych vyse.

    -- DODRZUJTE ZASADY PSANI SYNTETIZOVATELNEHO VHDL KODU OBVODOVYCH PRVKU,
    -- JEZ JSOU PROBIRANY ZEJMENA NA UVODNICH CVICENI INP A SHRNUTY NA WEBU:
    -- http://merlin.fit.vutbr.cz/FITkit/docs/navody/synth_templates.html.

    -- Nezapomente take doplnit mapovani signalu rozhrani na piny FPGA
    -- v souboru ledc8x8.ucf.

end main;




-- ISID: 75579
