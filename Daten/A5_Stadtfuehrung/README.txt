Jede Datei beschreibt eine Tour und enthält
-in der ersten Zeile die Anzahl n an Tourpunkten
-und in den darauffolgenden n Zeilen jeweils die Informationen zu einem Tourpunkt: 

Ort, Zeitpunkt, Essentiell, kumulierter Abstand

An dritter Stelle steht entweder ein X (der Tourpunkt ist essentiell) oder ein Leerzeichen (der Tourpunkt ist nicht essentiell). Der kumulierte Abstand gibt an, wie weit man auf der Tour des Vaters von deren Startort zu diesem Tourpunkt laufen muss. Kumuliert bedeutet, dass die Abstände aufaddiert werden und zwischen den einzelnen Tourpunkten wie im folgenden kleinen Beispiel berechnet werden können:

Brauerei,1613,X,0
Karzer,	1665,X,80
Rathaus,1678,X,150
...	
 	 	 
Daraus ergeben sich folgende Distanzen:

Ort 1		Ort 2	Abstand
Brauerei	Karzer	80
Brauerei	Rathaus	150
Karzer		Rathaus	70
...	 	 