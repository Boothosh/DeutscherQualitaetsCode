import Foundation

// 42. Bundeswettbewerb Informatik, Max Eckstein

struct Punkt: Hashable {
    let x1: Int
    let x2: Int
    let x3: Int
}

// Einlesen der externen Datei
let dateiNummer: String = CommandLine.arguments.last ?? "-"
let dateiNummerInt: Int = Int(dateiNummer) ?? 0
let pfad: URL = URL(fileURLWithPath: "../Daten/A3_Zauberschule/zauberschule\(dateiNummerInt).txt")
guard let text: String = try? String(contentsOf: pfad) else {
    print("Datei konnte nicht gefunden / ausgelesen werden")
    exit(-1)
}
var zeilen = text.split(whereSeparator: \.isNewline)
guard let hoeheEinesStockwerksString = zeilen.removeFirst().split(separator: " ").first, let hoeheEinesStockwerks = Int(hoeheEinesStockwerksString) else {
    print("Höhe eines Stockwerks konnte nicht ermittelt werden.")
    exit(-1)
}

let stockwerkZeilen: [[Character]] = zeilen.map { zeile in
    return zeile.map({$0})
}

var start: Punkt?
var ziel: Punkt?

var hoehenIndex = 0

for zeile in stockwerkZeilen {
    for char in zeile.enumerated() {
        let x1 = char.offset
        let x2 = (hoehenIndex < hoeheEinesStockwerks) ? hoehenIndex : (hoehenIndex - hoeheEinesStockwerks)
        let x3 = (hoehenIndex < hoeheEinesStockwerks) ? 0 : 1
        if char.element == "A" {
            start = Punkt(x1: x1, x2: x2, x3: x3)
        } else if char.element == "B" {
            ziel = Punkt(x1: x1, x2: x2, x3: x3)
        }
    }
    hoehenIndex += 1
}

guard let start, let ziel else {
    print("Es konnte kein Start- und/oder Endpunkt gefunden werden.")
    exit(-1)
}

// MARK: A* Algorithmus

// Heuristische Funktion (schätzt noch zu brauchende Zeit)
func h(_ punkt: Punkt) -> Int {
    return abs(ziel.x1 - punkt.x1) + abs(ziel.x2 - punkt.x2) + abs(ziel.x3 - punkt.x3) * 3
}

func rekonstruiereWeg(_ kommtVon: [Punkt: Punkt], _ endPunkt: Punkt) -> [Punkt] {
    var pfad = [endPunkt]
    var aktuellerPunkt = endPunkt
    while let neuerPunkt = kommtVon[aktuellerPunkt] {
        aktuellerPunkt = neuerPunkt
        pfad.insert(neuerPunkt, at: 0)
    }
    return pfad
}

func sucheNachVerbindungen(fuerPunkt punkt: Punkt) -> [(Punkt, Int)] {
    let moeglicheOffsets = [
        (1, 0, 0),
        (-1, 0, 0),
        (0, 1, 0),
        (0, -1, 0),
        (0, 0, punkt.x3 == 0 ? 1 : -1)
    ]
    var gefundeneVerbindungen = [(Punkt, Int)]()
    for i in moeglicheOffsets {
        let neueX1 = punkt.x1 + i.0
        let neueX2 = punkt.x2 + i.1
        let neueX3 = punkt.x3 + i.2
        if stockwerkZeilen[neueX2 + neueX3*hoeheEinesStockwerks][neueX1] != "#" {
            let neuerPunkt = Punkt(x1: neueX1, x2: neueX2, x3: neueX3)
            gefundeneVerbindungen.append((neuerPunkt, (i.2 != 0) ? 3 : 1))
        }
    }
    return gefundeneVerbindungen
}

func aStarPfad(von start: Punkt, zum ziel: Punkt) -> ([Punkt], Int)? {

    var zuPruefendeKnoten = [start]

    var kommtVon = [Punkt: Punkt]()

    var weglaengeZuPunkten = [start: 0]

    var zuErwartendeDauerVonPunkten = [start: h(start)]

    while !zuPruefendeKnoten.isEmpty {
        guard let current = zuPruefendeKnoten.sorted(by: {zuErwartendeDauerVonPunkten[$0]! < zuErwartendeDauerVonPunkten[$1]!}).first else { return nil }
        if current == ziel {
            return (rekonstruiereWeg(kommtVon, current), weglaengeZuPunkten[current]!)
        }
            
        guard let index = zuPruefendeKnoten.firstIndex(of: current) else { continue }
        zuPruefendeKnoten.remove(at: index)
        
        for bindung in sucheNachVerbindungen(fuerPunkt: current) {
            let weglaengeZuPunkt = weglaengeZuPunkten[current]! + bindung.1
            if weglaengeZuPunkt < weglaengeZuPunkten[bindung.0] ?? 9999999999999999 {
                kommtVon[bindung.0] = current
                weglaengeZuPunkten[bindung.0] = weglaengeZuPunkt
                zuErwartendeDauerVonPunkten[bindung.0] = weglaengeZuPunkt + h(bindung.0)
                if !zuPruefendeKnoten.contains(bindung.0) {
                    zuPruefendeKnoten.append(bindung.0)
                }
            }
        }
    }

    return nil
}

guard let weg = aStarPfad(von: start, zum: ziel) else {
    print("Es wurde kein Weg von A nach B gefunden.")
    exit(-1)
}

print("\nBerechnung des Weges erfolgreich!")
print("Der Kürzeste Weg geht über folgende Punkte:")
for i in weg.0 {
    print("Punkt(\(i.x1 + 1)|\(i.x2 + 1)) auf dem \(i.x3 == 0 ? "ersten" : "zweiten") Stockwerk")
}
print("Der Weg ist \(weg.1) Sekunden lang.")