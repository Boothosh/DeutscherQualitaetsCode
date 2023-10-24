Jede Datei beschreibt den Plan einer Zauberschule und enthält
-in der ersten Zeile die Dimensionen n m jedes Stockwerkes.
-In den darauffolgenden n Zeilen ist das erste Stockwerk dargestellt und gefolgt von
-einer Leerzeile
-in weiteren n Zeilen das zweite Stockwerk.

Dabei steht das ‚A‘ immer für die Startpostion von Ron und das ‚B‘ immer für die Zielposition. Eine Wand wird durch eine ‚#‘ dargestellt und ein freies Feld durch einen ‚.‘.  Bis inklusive zauberschule3.txt müssen die Pfade in der Dokumentation mit angegeben werden. Für zauberschule4.txt und zauberschule5.txt reicht es aus die Länge des schnellsten Weges anzugeben und den Pfad als externe Datei mit einzureichen.

Die Datei zauberschule0.txt entspricht dem Beispiel aus der Aufgabenstellung. Hinweis: Weil in der Darstellung mit Textzeichen die Wände der Zauberschule ein Zeichen "dick" sind, sind auch die Wege länger, als wenn man die Stockwerke wie in der Aufgabenstellung zeichnen würde. Im Beispiel aus der Aufgabenstellung braucht Ron deswegen 8 Sekunden statt 7.

Der Pfad selbst kann zum Beispiel mit ‚<, >, ^, v‘ für dich Richtungen und ‚!‘ für den Wechsel beschrieben werden. So sieht der Pfad für eine Eingabe:

#############
#...........#
#######B###.#
#....A#...#.#
#.#########.#
#...........#
#############

#############
#.....#.....#
#.#.#######.#
#...#.......#
#.#.#.#.###.#
#.#...#...#.#
#############

wie folgt aus:

#############
#....>>v....#
#######B###.#
#..!<<#...#.#
#.#########.#
#...........#
#############

#############
#..>>!#.....#
#.#^#######.#
#..^#.......#
#.#.#.#.###.#
#.#...#...#.#
#############