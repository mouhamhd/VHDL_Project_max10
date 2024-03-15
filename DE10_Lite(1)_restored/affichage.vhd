library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
use work.son.all;

ENTITY affichage IS
	PORT (clk           :  IN      STD_LOGIC; -- clock à 25 Mhz
		response_data    :  IN std_logic_vector(NbitCAN-1 downto 0) ;  --valeur issue de l'ADC
		dataDAC          :  IN Std_Logic_Vector ( NbitCNA-1 downto 0); -- valeur envoyée vers le DAC
		response_channel :  IN std_logic_vector(4 downto 0) ; -- numéro de canal converti
		response_valid :    IN std_logic ;
		BP0              :  IN      STD_LOGIC;   --active low reset sur BP0
	   HEX0				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX1				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX2				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX3				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX4				 : OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX5				 : OUT STD_LOGIC_VECTOR(7 downto 0)
		
	 ); 
END affichage;

ARCHITECTURE comportementale OF affichage IS

component dec7seg IS
	PORT (
	valeur : IN std_logic_vector(3 downto 0);
	HEX : out std_logic_vector(6 downto 0) 
	);
END component dec7seg;

SIGNAL adc_sample_data : std_logic_vector(NbitCAN-1 downto 0) ;
SIGNAL cur_adc_chanel : std_logic_vector(4 downto 0);
SIGNAL volt : integer range 0 to 4095 ; -- range 0 to 5000 ; -- tension en millivolt
SIGNAL Uvolt : std_logic_vector(3 downto 0) ;
SIGNAL Dvolt : std_logic_vector(3 downto 0)  ;
SIGNAL Cvolt : std_logic_vector(3 downto 0)  ;
SIGNAL Mvolt : std_logic_vector(3 downto 0)  ;

BEGIN
 
process ( clk)
	  begin
		IF rising_edge(clk) THEN
		 IF response_valid ='1' THEN
			 volt <= (conv_integer(dataDAC) *2*2500 )/4096 ; -- *2 car etage d'entree divise la tension par 2 
			 adc_sample_data <= response_data ;
			 cur_adc_chanel <= response_channel ;
		 END IF;	 
		END IF;  
	end process; 
	
	PROCESS (volt)
	BEGIN
	Uvolt <= CONV_STD_LOGIC_VECTOR(volt /1000,4);
	Dvolt <= CONV_STD_LOGIC_VECTOR(volt /100 - (volt/1000)*8 - (volt/1000)*2,4) ;
	-- Dvolt <= CONV_STD_LOGIC_VECTOR(volt /100 - (volt/1000)*10,4) ;
	Cvolt <= CONV_STD_LOGIC_VECTOR(volt /10 - (volt/100)*10,4) ;
	Mvolt <= CONV_STD_LOGIC_VECTOR(volt- (volt/10)*10,4) ;
	
	END PROCESS;
	
	-- gestion du point des afficheurs 7 segments
	 HEX5(7) <='1';
	 HEX4(7) <='1';
	 HEX3(7) <='0'; -- seul point allume
	 HEX2(7) <='1';
	 HEX1(7) <='1';
	 HEX0(7) <='1';
	 
	-- afficheur 4 eteint
	 HEX4 (6 downto 0) <= "1111111"; 
	 
	
	 Affichecanal : component dec7seg 
			port map (
			valeur => cur_adc_chanel(3 downto 0) , -- affichage du numéro de canal converti
			HEX => HEX5(6 downto 0)    -- sur l'afficheur le plus à gauche
			); 
	Afficheunite : component dec7seg 
		  port map (
			valeur => Uvolt , -- affichage des unites de la valeur ADC 
			HEX => HEX3(6 downto 0)         -- sur l'afficheur à gauche du point
			); 
	Affichedizieme : component dec7seg 
		  port map (
			valeur => Dvolt , -- affichage des diziemes  de la valeur ADC 
			HEX => HEX2(6 downto 0)         -- sur l'afficheur à droite du point
			); 
	Affichecentieme : component dec7seg 
		  port map (
			valeur => Cvolt , -- affichage des centiemes de la valeur ADC 
			HEX => HEX1(6 downto 0)         -- sur l'afficheur suivant
			); 
	Affichemillieme : component dec7seg 
		  port map (
			valeur => Mvolt , -- affichage des milliemes de la valeur ADC 
			HEX => HEX0(6 downto 0)         -- sur l'afficheur suivant
			); 		
END comportementale; 		
			
