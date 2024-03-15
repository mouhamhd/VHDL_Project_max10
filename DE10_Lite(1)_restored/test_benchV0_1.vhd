
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.son.all;

ENTITY TEST_BENCH_V0_1 IS
END TEST_BENCH_V0_1;

ARCHITECTURE test OF TEST_BENCH_V0_1 IS

COMPONENT numerique IS
	PORT (clk       :  IN      STD_LOGIC;
		measure_done      : IN std_logic ;  --indique si la conversion AD est finie
		start_trait       : out std_logic ;  --pour observation
		fin_trait         : out std_logic ;  --pour observation
		BP0,BP1,BP2,BP3               :  IN      STD_LOGIC;   --active low reset sur BP0
	   validson : OUT std_logic; -- pour maitrise de la frequence d'echantillonage DAC
		dataADC    :  IN Std_Logic_Vector(NbitCAN-1 downto 0); -- signal d'entrée converti par l ADC
		dataDAC    :  OUT Std_Logic_Vector ( NbitCNA-1 downto 0) -- sortie vers le DAC à convertir 
	 ); 
END COMPONENT;

-- déclaration des signaux pour connecter le compôsant aux process
SIGNAL sclk,smeasure_done,sBP0,sBP1,sBP2,sBP3 : STD_LOGIC;
SIGNAL sstart_trait,sfin_trait,svalidson : STD_LOGIC;
SIGNAL sdataADC, sdataDAC : STD_LOGIC_VECTOR(11 downto 0) ;

BEGIN
-- placement du composant et connexion aux signaux d entree et de sortie
instance_numerique : numerique PORT MAP (sclk,smeasure_done,sstart_trait,sfin_trait,sBP0,sBP1,sBP2,sBP3,svalidson,sdataADC, sdataDAC);

horloge : PROCESS -- horloge à 25 MHZ => 40 ns
	BEGIN
		sclk<='0';
		wait for 20 ns;
		sclk <='1';
		wait for 20 ns;
		-- génere sans arrêt une horloge
		
	END PROCESS horloge;
	
reset: PROCESS -- remise a zero au debut	
	BEGIN
		sBP0 <= '0' ;
		wait for 30 ns ;
		sBP0 <= '1';
		wait;
	
	END PROCESS reset;
	
valid_reponse : PROCESS -- pour simuler les signaux venant de l ADC , 1 echantillon toutes les 1000 ns (1Mhz)
		BEGIN
			smeasure_done <='0';
			sdataADC <= "000000000000" ;
			wait for 40 ns ;                    -- 40 ns
			smeasure_done <='1';
			sdataADC <= "000000000001" ;
			wait for 40 ns ;                    -- 80 ns
			smeasure_done <='0';
			wait for 960 ns ;                   -- 1040 ns
			smeasure_done <='1';
			sdataADC <= "000000000010" ;
			wait for 40 ns ;                    -- 1080 ns
			smeasure_done <='0';
			wait for 960 ns ; 
		   
			
		
		END PROCESS valid_reponse;


	
END test;
