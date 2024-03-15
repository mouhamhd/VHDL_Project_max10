library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
use work.son.all;

ENTITY numerique IS
	PORT (clk       :  IN      STD_LOGIC; -- clock a 25 MHz 
		measure_done      : IN std_logic ;  --indique si la conversion ADC est finie
		start_trait       : out std_logic ;  --pour observation
		fin_trait         : out std_logic ;  --pour observation
		BP0,BP1,BP2,BP3               :  IN      STD_LOGIC;   --active low reset sur BP0
	   validson : OUT std_logic; -- pour maitrise de la frequence d'echantillonage DAC
		dataADC    :  IN Std_Logic_Vector(NbitCAN-1 downto 0); -- signal d'entrée converti
		dataDAC    :  OUT Std_Logic_Vector ( NbitCNA-1 downto 0) -- sortie à convertir 
	 ); 
END numerique;

ARCHITECTURE comportementale OF numerique IS

SIGNAL sdataDAC_1Mhz    :  Std_Logic_Vector ( NbitCNA-1 downto 0); -- entrée à convertir
SIGNAL cpt : std_logic_vector(7 downto 0); -- compteur servant à sous-échantillonner la valeur du ADC (1MHz) => 10 khz si 12 bits car on part de MAX10_CLK1_50 
SIGNAL sechant : std_logic;
SIGNAL sdataDAC    :  Std_Logic_Vector ( NbitCNA-1 downto 0); -- signal vers DAC à 10Khz


BEGIN

	-- simple registre de connexion pour concerver la valeur convertie entre les conversions.  
	process (clk, BP0)
	begin
		if (BP0='0') then sdataDAC_1Mhz <= (others => '0');
			elsif ( rising_edge(clk) ) then
			  if ((measure_done='1') ) then 
				  sdataDAC_1Mhz <= dataADC;
			  end if;
	  end if;
	
	end process;
	
	-- pour sous-échantilloner la sortie du ADC qui est à 1MHz, et retomber a 10khz
	process (clk)
	begin
		if (BP0='0') then sdataDAC <= (others => '0');
			elsif ( rising_edge(clk) ) then
				
			  if (sechant ='1') then 
				 
				  sdataDAC <= sdataDAC_1Mhz;
									  
			  end if;
			 
	  end if;
	 
	end process;

process(clk,measure_done,BP0,cpt)
begin
  if (BP0='0') then cpt<= (others =>'0');
  elsif ( rising_edge(clk) ) then
     if (measure_done='1') then 
	    if (cpt= Nsousech-1) then  cpt <=(others =>'0'); else cpt<=cpt+1;end if; 
	  end if;
	  if ((cpt= Nsousech-1) and (measure_done='1') and (sechant='0')) then sechant<= '1' ; else sechant<= '0';end if; -- sechant ne doit durer qu'une periode 
  end if;	 
end process;



-- connexion aux sorties du bloc	
	dataDAC <= sdataDAC;
	validson <='1'; -- pas de synchro avec la partie DAC pour l'instant
	start_trait <=sechant;
	fin_trait <='0';
	
END comportementale;
	
