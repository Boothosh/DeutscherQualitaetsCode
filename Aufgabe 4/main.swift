// 42. Bundeswettbewerb Informatik, Team Deutscher Qualitätscode
import Foundation

protocol Baustein {
    var hoehenIndex: Int { get }
    var breitenIndex: Int { get }
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
    var aktiv: Bool = false
    func angeschaltet() -> Lichtquelle {
        return Lichtquelle(hoehenIndex: self.hoehenIndex, breitenIndex: self.breitenIndex, aktiv: true)
    }
}

struct PruefLED {
    let hoehenIndex: Int
    let breitenIndex: Int
    var aktiv: Bool = false
}

// Einlesen der externen Datei und befüllen der Baustein-Liste, Eintragen der Positionen der Prüf-LEDs und der Lichtquellen
let dateiNummer: String = CommandLine.arguments.last ?? "-"
let dateiNummerInt: Int = Int(dateiNummer) ?? 1
let pfad: URL = URL(fileURLWithPath: "../Daten/A4_Nandu/nandu\(dateiNummerInt).txt")
guard let text: String = try? String(contentsOf: pfad) else {
    print("Datei konnte nicht gefunden / ausgelesen werden")
    exit(EXIT_FAILURE)
}
var zeilen = text.split(whereSeparator: \.isNewline)
let ersteZeile = zeilen.removeFirst()

guard let breite = Int(ersteZeile.split(separator: " ")[0]), let hoehe = Int(ersteZeile.split(separator: " ")[1]) else {
    print("Breite und Hoehe konnten nicht ausgelesen werden")
    exit(EXIT_FAILURE)
}

// Befüllen der Variablen

var bausteine: [any Baustein] = []
var S_pruefLEDs: [PruefLED] = []
var S_lichtquellen: [Lichtquelle] = []

var hoehenIndex = 0
var breitenIndex = 0

var skippeDasNaechste = false

for zeile in zeilen {
    for zeichen in zeile {
        switch zeichen {
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
                let neueLichtquelle = Lichtquelle(hoehenIndex: hoehenIndex, breitenIndex: breitenIndex)
                S_lichtquellen.append(neueLichtquelle)
                breitenIndex += 1
            case "L":
                let neuePruefLED = PruefLED(hoehenIndex: hoehenIndex, breitenIndex: breitenIndex)
                S_pruefLEDs.append(neuePruefLED)
                breitenIndex += 1
            default:
                continue
        }
    }
    hoehenIndex += 1
    breitenIndex = 0
}

guard !S_lichtquellen.isEmpty && !S_pruefLEDs.isEmpty else {
    print("Es gibt keine Lichtquellen und/oder keine Prüf-LED's.")
    exit(EXIT_FAILURE)
}

var output: [([Lichtquelle], [PruefLED])] = []

var lichtkarte: [[Bool]] = []

func befuelleLichtkarte(lichtquellen: [Lichtquelle]) {

    // Lichtkarte zurücksetzen
    lichtkarte = [[Bool]](repeating: [Bool](repeating: false, count: breite), count: hoehe)

    // Lichkarte erhellen, an den Stellen an denen aktive Lichtquellen sind
    for lichtquelle in lichtquellen {
        lichtkarte[lichtquelle.hoehenIndex][lichtquelle.breitenIndex] = lichtquelle.aktiv
    }

    // Alle Bausteine das Licht weiterleiten lassen
    for baustein in bausteine {

        // Sicherstellen, dass der Baustein nicht ganz am oberen Rand ist
        guard baustein.hoehenIndex != 0 else { continue }
        
        let linkesInput = lichtkarte[baustein.hoehenIndex - 1][baustein.breitenIndex]
        let rechtesInput = lichtkarte[baustein.hoehenIndex - 1][baustein.breitenIndex + 1]
        
        lichtkarte[baustein.hoehenIndex][baustein.breitenIndex] = baustein.linkesOutput(l: linkesInput, r: rechtesInput)
        lichtkarte[baustein.hoehenIndex][baustein.breitenIndex + 1] = baustein.rechtesOutput(l: linkesInput, r: rechtesInput)
    }

    let pruefLEDs: [PruefLED] = S_pruefLEDs.map({
        var neueLED = $0
        neueLED.aktiv = lichtkarte[$0.hoehenIndex - 1][$0.breitenIndex]
        return neueLED
    })

    output.append((lichtquellen, pruefLEDs))
}

func testeFall(_ lichtquellen: [Lichtquelle], eigenerIndex: Int){
    let esGibtNochEinenWeiteren = eigenerIndex + 1 < S_lichtquellen.count
    if esGibtNochEinenWeiteren {
        testeFall(lichtquellen, eigenerIndex: eigenerIndex + 1)
        var neueLichtquellenKonfig = lichtquellen
        neueLichtquellenKonfig[eigenerIndex] = lichtquellen[eigenerIndex].angeschaltet()
        testeFall(neueLichtquellenKonfig, eigenerIndex: eigenerIndex + 1)
    } else {
        befuelleLichtkarte(lichtquellen: lichtquellen)
        var neueLichtquellenKonfig = lichtquellen
        neueLichtquellenKonfig[eigenerIndex] = lichtquellen[eigenerIndex].angeschaltet()
        befuelleLichtkarte(lichtquellen: neueLichtquellenKonfig)
    }
}

testeFall(S_lichtquellen, eigenerIndex: 0)

for i in output {
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