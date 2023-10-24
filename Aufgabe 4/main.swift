import Foundation

// 42. Bundeswettbewerb Informatik, Max Eckstein

protocol Baustein {
    var hoehenIndex: Int { get set }
    var breitenIndex: Int { get set }
    func linkesOutput (l linkesInput: Bool, r rechtesInput: Bool) -> Bool
    func rechtesOutput (l linkesInput: Bool, r rechtesInput: Bool) -> Bool
}

struct WeisserBaustein: Baustein {
    var hoehenIndex: Int
    var breitenIndex: Int
    func linkesOutput(l linkesInput: Bool, r rechtesInput: Bool) -> Bool {
        return !(linkesInput && rechtesInput)
    }
    func rechtesOutput(l linkesInput: Bool, r rechtesInput: Bool) -> Bool {
        return !(linkesInput && rechtesInput)
    }
}

struct RoterBaustein: Baustein {
    var hoehenIndex: Int
    var breitenIndex: Int
    var sensorIsLinks: Bool
    func linkesOutput(l linkesInput: Bool, r rechtesInput: Bool) -> Bool {
        return sensorIsLinks ? !linkesInput : !rechtesInput
    }
    func rechtesOutput(l linkesInput: Bool, r rechtesInput: Bool) -> Bool {
        return sensorIsLinks ? !linkesInput : !rechtesInput
    }
}

struct BlauerBaustein: Baustein {
    var hoehenIndex: Int
    var breitenIndex: Int
    func linkesOutput(l linkesInput: Bool, r rechtesInput: Bool) -> Bool {
        return linkesInput
    }
    func rechtesOutput(l linkesInput: Bool, r rechtesInput: Bool) -> Bool {
        return rechtesInput
    }
}

struct Lichtquelle {
    let hoehenIndex: Int
    let breitenIndex: Int
    var aktiv: Bool
    func aberMit(aktivitaetsStatus aktiv: Bool) -> Lichtquelle {
        return Lichtquelle(hoehenIndex: self.hoehenIndex, breitenIndex: self.breitenIndex, aktiv: aktiv)
    }
}

struct PruefLED {
    let hoehenIndex: Int
    let breitenIndex: Int
    var aktiv: Bool
}

var globalesOutput: [([Lichtquelle], [PruefLED])] = []

// Einlesen der externen Datei und befüllen der Baustein-Liste, Eintragen der Positionen der Prüf-LEDs und der Lichtquellen
let dateiNummer: String = CommandLine.arguments.last ?? "-"
let dateiNummerInt: Int = Int(dateiNummer) ?? 1
let pfad: URL = URL(fileURLWithPath: "../Daten/A4_Nandu/nandu\(dateiNummerInt).txt")
guard let text: String = try? String(contentsOf: pfad) else {
    print("Datei konnte nicht gefunden / ausgelesen werden")
    exit(-1)
}
var zeilen = text.split(whereSeparator: \.isNewline)
let ersteZeile = zeilen.removeFirst()

guard let breite = Int(ersteZeile.split(separator: " ")[0]), let hoehe = Int(ersteZeile.split(separator: " ")[1]) else {
    print("Breite und Hoehe konnten nicht ausgelesen werden")
    exit(-1)
}

// Befüllen der Variablen

var bausteine: [any Baustein] = []
var S_pruefLEDs: [PruefLED] = []
var S_lichtquellen: [Lichtquelle] = []

var hoehenIndex = -1
var breitenIndex = 0

var skippeDasNaechste = false

for zeile in zeilen {
    hoehenIndex += 1
    breitenIndex = 0
    for character in zeile {
        switch character {
            case "X":
                breitenIndex += 1
            case "W":
                if !skippeDasNaechste {
                    let neuerBaustein = WeisserBaustein(hoehenIndex: hoehenIndex, breitenIndex: breitenIndex)
                    bausteine.append(neuerBaustein)
                    breitenIndex += 2
                    skippeDasNaechste = true
                } else {
                    skippeDasNaechste = false
                }
            case "B":
                if !skippeDasNaechste {
                    let neuerBaustein = BlauerBaustein(hoehenIndex: hoehenIndex, breitenIndex: breitenIndex)
                    bausteine.append(neuerBaustein)
                    breitenIndex += 2
                    skippeDasNaechste = true
                } else {
                    skippeDasNaechste = false
                }
            case "R":
                if !skippeDasNaechste {
                    let neuerBaustein = RoterBaustein(hoehenIndex: hoehenIndex, breitenIndex: breitenIndex, sensorIsLinks: true)
                    bausteine.append(neuerBaustein)
                    breitenIndex += 2
                    skippeDasNaechste = true
                } else {
                    skippeDasNaechste = false
                }
            case "r":
                if !skippeDasNaechste {
                    let neuerBaustein = RoterBaustein(hoehenIndex: hoehenIndex, breitenIndex: breitenIndex, sensorIsLinks: false)
                    bausteine.append(neuerBaustein)
                    breitenIndex += 2
                    skippeDasNaechste = true
                } else {
                    skippeDasNaechste = false
                }
            case "Q":
                let neueLichtquelle = Lichtquelle(hoehenIndex: hoehenIndex, breitenIndex: breitenIndex, aktiv: false)
                S_lichtquellen.append(neueLichtquelle)
                breitenIndex += 1
            case "L":
                let neuePruefLED = PruefLED(hoehenIndex: hoehenIndex, breitenIndex: breitenIndex, aktiv: false)
                S_pruefLEDs.append(neuePruefLED)
                breitenIndex += 1
            default:
                continue
        }
    }
}

// ENDE

var lichtkarte: [[Bool]] = []

func setzeLichtkarteZurueck() {
    lichtkarte = []
    for _ in 0...(hoehe - 1) {
        var lichtArray = [Bool]()
        for _ in 0...(breite - 1) {
            lichtArray.append(false)
        }        
        lichtkarte.append(lichtArray)
    }
}

func befuelleLichtkarte(lichtquellen: [Lichtquelle]) {
    setzeLichtkarteZurueck()
    for lichtquelle in lichtquellen {
        lichtkarte[lichtquelle.hoehenIndex][lichtquelle.breitenIndex] = lichtquelle.aktiv
    }
    for baustein in bausteine {
        // Sicherstellen, dass der Baustein nicht ganz am oberen Rand ist
        guard baustein.hoehenIndex != 0 else { continue }
        
        let linkesInput = lichtkarte[baustein.hoehenIndex - 1][baustein.breitenIndex]
        let rechtesInput = lichtkarte[baustein.hoehenIndex - 1][baustein.breitenIndex + 1]
        
        // Linkes Output in die Lichtkarte schreiben
        lichtkarte[baustein.hoehenIndex][baustein.breitenIndex] = baustein.linkesOutput(l: linkesInput, r: rechtesInput)
        lichtkarte[baustein.hoehenIndex][baustein.breitenIndex + 1] = baustein.rechtesOutput(l: linkesInput, r: rechtesInput)
    }
    // Output-Sensoren
    var pruefLEDs: [PruefLED] = []

    for i in S_pruefLEDs {
        pruefLEDs.append(PruefLED(hoehenIndex: i.hoehenIndex, breitenIndex: i.breitenIndex, aktiv: lichtkarte[i.hoehenIndex - 1][i.breitenIndex]))
    }
    globalesOutput.append((lichtquellen, pruefLEDs))
}

guard S_lichtquellen.count != 0 else { exit(-1) }

func rekursiveDingsFunktion(_ lichtquellen: [Lichtquelle], eigenerIndex: Int){
    let esGibtNochEinenWeiteren = eigenerIndex + 1 < S_lichtquellen.count
    if esGibtNochEinenWeiteren {
        rekursiveDingsFunktion(lichtquellen, eigenerIndex: eigenerIndex + 1)
        var neueLichtquellenKonfig = lichtquellen
        neueLichtquellenKonfig[eigenerIndex] = lichtquellen[eigenerIndex].aberMit(aktivitaetsStatus: true)
        rekursiveDingsFunktion(neueLichtquellenKonfig, eigenerIndex: eigenerIndex + 1)
    } else {
        befuelleLichtkarte(lichtquellen: lichtquellen)
        var neueLichtquellenKonfig = lichtquellen
        neueLichtquellenKonfig[eigenerIndex] = lichtquellen[eigenerIndex].aberMit(aktivitaetsStatus: true)
        befuelleLichtkarte(lichtquellen: neueLichtquellenKonfig)
    }
}

rekursiveDingsFunktion(S_lichtquellen, eigenerIndex: 0)

for i in globalesOutput {
    print("Für Konfiguration:")
    for i in i.0.enumerated() {
        print("Q\(i.offset + 1) ist \(i.element.aktiv ? "aktiv" : "inaktiv")")
    }
    print("Kommt bei den Sensoren am Ende an:")
    for i in i.1.enumerated() {
        print("L\(i.offset + 1) ist \(i.element.aktiv ? "aktiv" : "inaktiv")")
    }
    print("---")
}