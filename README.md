# CTITcasus
--ITcasus (R script) uit Chang
1. CPIkwartaalmutatie(begindatum,einddatum,data) : R-functie die is gemaakt om de uitvoer te produceren die het vereiste dataframe bevat
- begindatume: het startjaar en kwartaal (bijv. "1996q1", jaar 1996 en kwartaal 1)
- einddatum: het eindjaar en kwartaal (bijv. "2005q3", jaar 2005 kwartaal 3)
- data: identifier "83131NED" met de CPI-gegevens (StatLine https://opendata.cbs.nl/statline/portal.html?_la=nl&_catalog=CBS&tableId=83131NED&_theme=380)
-- output: een dataframe met daarin drie variabelen: Perioden3 (character, jaar en kwartaal), Perioden2 (dates, jaar en kwartaal) en kwartaalmutatie (double, kwartaalmutatie tussen begindatum en einddatum) 
2. p is de figuur die is gemaakt
3. test.db is de aangemaakte database die het geselecteerde dataframe df1 en df2 bevat
