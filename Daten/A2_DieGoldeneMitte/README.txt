Jede Datei beschreibt ein Rätsel und enthält
-in der ersten Zeile die inneren Kantenlängen der würfelförmigen Kiste: x y z,
-in der zweiten Zeile die Anzahl n an zur Verfügung stehenden Würfeln und Quadern
-und in den folgenden n Zeilen jeweils die Kantenlängen a b c der zur Verfügung stehenden Würfel und Quader.

Hinweis: Der goldene Würfel ist in den Beispieldateien nicht mit aufgeführt und ist bei jedem Rätsel standardmäßig mit dabei.

Die Datei raetsel5.txt entspricht dem Beispiel aus der Aufgabenstellung.
Als Ausgabeformat bietet es sich an das zusammengesetzte Rätsel Ebenen-weise darzustellen. So kann die Lösung für dieses Rätsel:

3 3 3
6
1 3 3
1 3 3
1 1 3
1 1 2
1 1 2
1 1 1

so dargestellt werden:

Ebene 0				Ebene 1				Ebene 2
1	2	3	 	1	4	3	 	1	4	3	 
1	2	3	 	1	G	3	 	1	6	3	 
1	2	3	 	1	5	3	 	1	5	3	 
 

In diesem Beispiel stehen die Zahlen für einen Würfel oder Quader an dieser Position. Die ‚1‘ und die ‚3‘ stellen zum Beispiel die ersten beiden Quader in der Liste dar.
Alternativ kann natürlich auch ein Bild ausgegeben werden.