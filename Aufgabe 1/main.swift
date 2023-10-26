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

// Spielfeld
var spielfeld = [[Int]]()

// Alles auf 0 setzen, also das leere Spielfeld füllen
for _ in 0 ..< n {
    var zeile = [Int]()
    for _ in 0 ..< n {
        zeile.append(0)
    }
    spielfeld.append(zeile)
}

// Es für den Algorithmus unlösbar machen
spielfeld[0][1] = 1
spielfeld[1][2] = 2
spielfeld[n-1][1] = 1
spielfeld[n-2][0] = 2

if k != 2 {
    // Die restlichen Zahlen in graden Linien von oben nach unten einarbeiten, damit die Mindestanzahl der Zahlen gegeben ist
    for i in 3...k {
        spielfeld[0][i+1] = i
        spielfeld[n-1][i+1] = i
    }
}

// Output ergänzen
for i in spielfeld {
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