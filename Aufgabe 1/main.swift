// 42. Bundeswettbewerb Informatik, Team Deutscher Qualitätscode
import Foundation

// Seitenlänge des Spielfeldes
let dateiNummer: String = CommandLine.arguments.last ?? "-"
let n: Int = Int(dateiNummer) ?? 5

guard n >= 4 else {
    print("N ist zu klein")
    exit(EXIT_FAILURE)
}

// Anzahl der Zahlen auf dem Feld
let k: Int = Int(ceil(Double(n)/2.0))

// Generiertes Spiel
var generiertesSpiel: String = "\(n)\n\(k)"

// Spielfeld, bei dem anfangs alle Werte auf 0 sind (es ist noch leer)
var spielfeld = [[Int]](repeating: [Int](repeating: 0, count: n), count: n)

// Es für den Algorithmus unlösbar machen
spielfeld[0][1] = 1
spielfeld[1][2] = 2
spielfeld[n-1][1] = 1
spielfeld[n-2][0] = 2

if k != 2 {
    // Die restlichen Zahlen in graden Linien von oben nach unten einarbeiten, damit die Mindestanzahl der Zahlen gegeben ist
    var restlicheZahlen = Array(3...k)
    restlicheZahlen.shuffle()
    for i in restlicheZahlen.enumerated() {
        spielfeld[0][i.offset+4] = i.element
        spielfeld[n-1][i.offset+4] = i.element
    }
}

// Generiertes Spiel drehen
var gedrehtesSpiel = spielfeld
for _ in 0...Int.random(in: 1..<4) {
    spielfeld = gedrehtesSpiel
    for i in 0...(n-1) {
        for j in 0...(n-1) {
            gedrehtesSpiel[i][j] = spielfeld[n - j - 1][i];
        }
    }
}

// Output ergänzen
for i in gedrehtesSpiel {
    var zeile = "\n"
    for ii in i.enumerated() {
        zeile.append((ii.offset != 0 ? " " : "") + String(ii.element))
    }
    generiertesSpiel.append(zeile)
}

// Output in Datei schreiben
if (FileManager.default.createFile(atPath: "./arukone\(n).txt", contents: generiertesSpiel.data(using: .utf8), attributes: nil)) {
    print("Erfolg")
} else {
    print("Datei konnte nicht beschrieben werden... :(")
}
