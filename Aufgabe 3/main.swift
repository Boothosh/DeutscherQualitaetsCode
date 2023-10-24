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
guard let stockwerkLaengeAlsString = zeilen.removeFirst().split(separator: " ").first, let langeEinsesStockwerks = Int(stockwerkLaengeAlsString) else {
    print("Länge eines Stockwerks konnte nicht ermittelt werden.")
    exit(-1)
}

let stockwerke: [[Character]] = zeilen.map { zeile in
    return zeile.map({$0})
}

// X, Y, Z- Koordinate (in dieser Reihenfolge)
var start: Punkt?
var ziel: Punkt?

var hoehenIndex = 0

for zeile in stockwerke {
    for char in zeile.enumerated() {
        if char.element == "A" {
            start = Punkt(x1: char.offset, x2: hoehenIndex, x3: hoehenIndex < langeEinsesStockwerks ? 0 : 1)
        }
        if char.element == "B" {
            ziel = Punkt(x1: char.offset, x2: hoehenIndex, x3: hoehenIndex < langeEinsesStockwerks ? 0 : 1)
        }
    }
    hoehenIndex += 1
}

hoehenIndex = 0

guard let start, let ziel else {
    print("Es konnte kein Start- und/oder Endpunkt gefunden werden.")
    exit(-1)
}

// MARK: Algorithmus

// Heuristische Funktion (schätzt noch zu brauchende Zeit)
func h(_ punkt: Punkt) -> Int {
    return abs(ziel.x1 - punkt.x1) + abs(ziel.x2 - punkt.x2) + abs(ziel.x3 - punkt.x3) * 3
}

func reconstruct_path(_ cameFrom: [Punkt: Punkt], _ current: Punkt) -> [Punkt] {
    var total_path = [current]
    var aktuellerPunkt = current
    while let neuerPunkt = cameFrom[aktuellerPunkt] {
        aktuellerPunkt = neuerPunkt
        total_path.insert(neuerPunkt, at: 0)
    }
    return total_path
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
        if stockwerke[neueX2 + neueX3*langeEinsesStockwerks][neueX1] != "#" {
            let neuerPunkt = Punkt(x1: neueX1, x2: neueX2, x3: neueX3)
            gefundeneVerbindungen.append((neuerPunkt, i.2 != 0 ? 1 : 3))
        }
    }
    return gefundeneVerbindungen
}

func aStarPfad(von start: Punkt, zum ziel: Punkt) -> [Punkt]? {

    var openSet = [start]

    var cameFrom = [Punkt: Punkt]()

    var gScore = [start: 0]

    var fScore = [start: h(start)]

    while !openSet.isEmpty {
        // This operation can occur in O(Log(N)) time if openSet is a min-heap or a priority queue
        guard let current = openSet.sorted(by: {fScore[$0]! < fScore[$1]!}).first else { return nil }
        if current == ziel {
            return reconstruct_path(cameFrom, current)
        }
            
        guard let index = openSet.firstIndex(of: current) else { continue }
        openSet.remove(at: index)
        
        for bindung in sucheNachVerbindungen(fuerPunkt: current) {
            // d(current,neighbor) is the weight of the edge from current to neighbor
            // tentative_gScore is the distance from start to the neighbor through current
            let tentative_gScore = gScore[current]! + bindung.1
            if tentative_gScore < gScore[bindung.0] ?? 9999999999999999 {
                // This path to neighbor is better than any previous one. Record it!
                cameFrom[bindung.0] = current
                gScore[bindung.0] = tentative_gScore
                fScore[bindung.0] = tentative_gScore + h(bindung.0)
                if !openSet.contains(bindung.0) {
                    openSet.append(bindung.0)
                }
            }
        }
    }

    return nil
}

let weg = aStarPfad(von: start, zum: ziel)