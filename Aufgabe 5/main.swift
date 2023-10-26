// 42. Bundeswettbewerb Informatik, Team Deutscher Qualitätscode
import Foundation

struct Tourpunkt: Equatable {
    let jahr: Int
    let ort: String
    let essenziell: Bool
    let abstandVomStart: Int
}

var urspruenglicheTour:     [Tourpunkt] = []

// Tour aus der externen Datei einlesen
let dateiNummer: String = CommandLine.arguments.last ?? "-"
let dateiNummerInt: Int = Int(dateiNummer) ?? 1
let pfad: URL = URL(fileURLWithPath: "../Daten/A5_Stadtfuehrung/tour\(dateiNummerInt).txt")
guard let text: String = try? String(contentsOf: pfad) else {
    print("Datei konnte nicht gefunden / ausgelesen werden")
    exit(EXIT_FAILURE)
}
var zeilen = text.split(whereSeparator: \.isNewline)
let ersteZeile = zeilen.removeFirst()

for zeile in zeilen {
    let parameter = zeile.split(separator: ",")
    guard parameter.count == 4 else { continue }
    guard let jahr = Int(parameter[1]), let abstand = Int(parameter[3]) else { continue }
    urspruenglicheTour.append(Tourpunkt(jahr: jahr, ort: String(parameter[0]), essenziell: parameter[2] == "X", abstandVomStart: abstand))
}

var neueTour:               [Tourpunkt] = urspruenglicheTour
print(zeilen)

guard let urspruenglicheLaenge = neueTour.last?.abstandVomStart else { exit(EXIT_FAILURE) }
var neueLaenge = urspruenglicheLaenge

// Damit der Index ermittelt werden kann, auch wenn Objekte gelöscht wurden
var entfernteObjekte =      0

for i in urspruenglicheTour.enumerated() {
    // Wenn der Tourpunkt überhaupt noch in der aktuellen Tour ist, also noch nicht entfernt wurde
    if neueTour.contains(i.element) {
        if let endIndex = tourHatIrrelevanteSchleife(ab: i.offset) {
            let letzterOrtSollEnferntWerden = !urspruenglicheTour[endIndex].essenziell
            guard (i.offset + 1) <= (letzterOrtSollEnferntWerden ? endIndex : endIndex - 1) else { continue }
            let abstand = urspruenglicheTour[endIndex].abstandVomStart - urspruenglicheTour[i.offset].abstandVomStart
            neueLaenge -= abstand
            for index in (i.offset + 1)...(letzterOrtSollEnferntWerden ? endIndex : endIndex - 1) {
                neueTour.remove(at: index - entfernteObjekte)
                entfernteObjekte += 1
            }
        }
    }
}

// Gibt zurück bis zu welchem Index die Schleife geht
func tourHatIrrelevanteSchleife(ab startIndex: Int) -> Int? {
    let startOrt = urspruenglicheTour[startIndex].ort
    var momentanerIndex = startIndex
    while true {
        momentanerIndex += 1
        guard momentanerIndex + 1 < urspruenglicheTour.count else { return nil }
        if startOrt == urspruenglicheTour[momentanerIndex].ort {
            print(momentanerIndex)
            return momentanerIndex
        }
        if urspruenglicheTour[momentanerIndex].essenziell { return nil }
    }
}

print("------")
print("Ausgangslage der Tour:")
for i in urspruenglicheTour {
    print(i.ort + " - " + i.jahr.description + " - " + (i.essenziell ? "Essenziell - " : "Nicht essenziell - ") + i.abstandVomStart.description + "m" )
}
print("------")
print("Neue Tour:")
for i in neueTour {
    print(i.ort + " - " + i.jahr.description + " - " + (i.essenziell ? "Essenziell - " : "Nicht essenziell - ") + i.abstandVomStart.description + "m" )
}

print("------")
print("Analyse:")
print("- Die Tour hat nach der Kürzung \(urspruenglicheTour.count - neueTour.count) weniger Tourpunkte.")
print("Ursprünglich waren es \(urspruenglicheTour.count), jetzt sind es \(neueTour.count).")
print("- Die Tour ist \(urspruenglicheLaenge - neueLaenge)m kürzer geworden.")
print("Ursprünglich waren es \(urspruenglicheLaenge)m, jetzt sind es \(neueLaenge)m.")