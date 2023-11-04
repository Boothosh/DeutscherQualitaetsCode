// 42. Bundeswettbewerb Informatik, Team Deutscher Qualitätscode
import Foundation

struct Tourpunkt: Equatable {
    let jahr: Int
    let ort: String
    let essenziell: Bool
    var abstandVomStart: Int

    static func == (_ lhs: Tourpunkt, _ rhs: Tourpunkt) -> Bool {
        lhs.jahr == rhs.jahr && lhs.ort == rhs.ort && lhs.essenziell == rhs.essenziell
    }
}

var urspruenglicheTour: [Tourpunkt] = []

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
    guard let jahr = Int(parameter[1].replacing(" ", with: "")), let abstand = Int(parameter[3].replacing(" ", with: "")) else { continue }
    urspruenglicheTour.append(Tourpunkt(jahr: jahr, ort: String(parameter[0]), essenziell: parameter[2] == "X", abstandVomStart: abstand))
}

guard let urspruenglicheLaenge = urspruenglicheTour.last?.abstandVomStart else { exit(EXIT_FAILURE) }

var neueTouren: [([Tourpunkt], Int)] = [(urspruenglicheTour, urspruenglicheLaenge)]

// Diese Funktion sucht von allen Routen-Varianten die aktuell kürzeste heraus,
// und löscht alle anderen.
func reduziereAufKuerzesteTour(){
    var kuerzesteTour = (urspruenglicheTour, urspruenglicheLaenge)
    for i in neueTouren {
        if i.1 < kuerzesteTour.1 {
            kuerzesteTour = i
        }
    }
    neueTouren = [kuerzesteTour]
}

func loescheTourpunkteAusTour(von startIndex: Int, bis endIndex: Int, bei tour: ([Tourpunkt], Int), loescheErsteStrecke: Bool = true, loescheLetzteStrecke: Bool = true) -> ([Tourpunkt], Int) {
    var veraenderbareTour = tour
    print(startIndex)
    print(endIndex)
    if endIndex > startIndex {
        var schonGeloeschte = 0
        var entfernteStrecke = 0
        for i in startIndex...endIndex {
            // Löschen der Tourpunkte
            veraenderbareTour.0.remove(at: i - schonGeloeschte)
            schonGeloeschte += 1
            // Verändern der Länge
            if i != 0 && (loescheErsteStrecke || i != startIndex) {
                let streckeZuDiesemPunkt = tour.0[i].abstandVomStart - tour.0[i - 1].abstandVomStart
                entfernteStrecke += streckeZuDiesemPunkt
            }
            if i == endIndex && loescheLetzteStrecke && i != tour.0.count - 1 {
                let streckeAbDiesemPunkt = tour.0[i + 1].abstandVomStart - tour.0[i].abstandVomStart
                entfernteStrecke += streckeAbDiesemPunkt
            }
        }
        veraenderbareTour.1 -= entfernteStrecke
        if endIndex != veraenderbareTour.0.count - 1 {
            for tourpunkt in veraenderbareTour.0[(endIndex - schonGeloeschte) + 1 ..< veraenderbareTour.0.count].enumerated() {
                veraenderbareTour.0[tourpunkt.offset + (endIndex - schonGeloeschte) + 1].abstandVomStart -= entfernteStrecke
            }
        }
    } else {
        var schonGeloeschte = 0
        var entfernteStrecke = 0
        for i in startIndex...(tour.0.count - 1) {
            veraenderbareTour.0.remove(at: i - schonGeloeschte)
            schonGeloeschte += 1
            // Verändern der Länge
            if i != 0 && (loescheErsteStrecke || i != startIndex) {
                let streckeZuDiesemPunkt = tour.0[i].abstandVomStart - tour.0[i - 1].abstandVomStart
                entfernteStrecke += streckeZuDiesemPunkt
            }
            if i == endIndex && loescheLetzteStrecke && i != tour.0.count - 1 {
                let streckeAbDiesemPunkt = tour.0[i + 1].abstandVomStart - tour.0[i].abstandVomStart
                entfernteStrecke += streckeAbDiesemPunkt
            }
        }
        veraenderbareTour.1 -= entfernteStrecke
        schonGeloeschte = 0
        entfernteStrecke = 0
        for i in 0...endIndex {
            veraenderbareTour.0.remove(at: i - schonGeloeschte)
            schonGeloeschte += 1
            // Verändern der Länge
            if i != 0 && (loescheErsteStrecke || i != startIndex) {
                let streckeZuDiesemPunkt = tour.0[i].abstandVomStart - tour.0[i - 1].abstandVomStart
                entfernteStrecke += streckeZuDiesemPunkt
            }
            if i == endIndex && loescheLetzteStrecke && i != tour.0.count - 1 {
                let streckeAbDiesemPunkt = tour.0[i + 1].abstandVomStart - tour.0[i].abstandVomStart
                entfernteStrecke += streckeAbDiesemPunkt
            }
        }
        if endIndex != veraenderbareTour.0.count - 1 {
            for tourpunkt in veraenderbareTour.0[(endIndex - schonGeloeschte) + 1 ..< veraenderbareTour.0.count].enumerated() {
                veraenderbareTour.0[tourpunkt.offset + (endIndex - schonGeloeschte) + 1].abstandVomStart -= entfernteStrecke
            }
        }
    }
    return veraenderbareTour
}

// Ersten essenziellen Punkt in der Route finden
if let indexVomErstenEssenziellenPunkt = urspruenglicheTour.firstIndex(where: {$0.essenziell}) {

    var untersuchterIndex = indexVomErstenEssenziellenPunkt

    for _ in 0..<urspruenglicheTour.count {
        let untersuchtesObjekt = urspruenglicheTour[untersuchterIndex]
        if untersuchtesObjekt.essenziell {
            // Bei essenziellen Punkten kann der bisher schnellste Weg als generell schnellster Weg deklariert werden
            reduziereAufKuerzesteTour()
        }
        // Alle verschiedenen neuen Touren absuchen
        for neueTour in neueTouren {
            guard let StartIndexInNeuerTour = neueTour.0.firstIndex(of: untersuchtesObjekt) else { continue }
            print(untersuchtesObjekt)
            print(StartIndexInNeuerTour)
            var untersuchterIndexInNeuerTour = (StartIndexInNeuerTour + 1) % neueTour.0.count
            while StartIndexInNeuerTour != untersuchterIndexInNeuerTour {
                let untersuchtesObjektNeueTour = neueTour.0[untersuchterIndexInNeuerTour]
                let willStartEndPaarEntfernen = (StartIndexInNeuerTour == neueTour.0.count - 1) && (untersuchterIndexInNeuerTour == 0)
                if untersuchtesObjektNeueTour.ort == untersuchtesObjekt.ort && !willStartEndPaarEntfernen {
                    print(untersuchtesObjektNeueTour)
                    print(untersuchtesObjekt)
                    let keinOrtDazwischen = (StartIndexInNeuerTour + 1) % neueTour.0.count == untersuchterIndexInNeuerTour
                    if untersuchtesObjekt.essenziell && untersuchtesObjektNeueTour.essenziell && !keinOrtDazwischen {
                        let neueneueTour = loescheTourpunkteAusTour(von: (StartIndexInNeuerTour + 1) % neueTour.0.count, bis: (untersuchterIndexInNeuerTour - 1) % neueTour.0.count, bei: neueTour)
                        neueTouren.append(neueneueTour)
                        // Lösche alle Strecken dazwischen
                    } else if !untersuchtesObjekt.essenziell && untersuchtesObjektNeueTour.essenziell {
                        if untersuchterIndexInNeuerTour == 0 {
                            let neueneueTour = loescheTourpunkteAusTour(von: StartIndexInNeuerTour + 1, bis: (untersuchterIndexInNeuerTour - 1) % neueTour.0.count, bei: neueTour, loescheErsteStrecke: false)
                            neueTouren.append(neueneueTour)
                        } else {
                            let neueneueTour = loescheTourpunkteAusTour(von: StartIndexInNeuerTour, bis: (untersuchterIndexInNeuerTour - 1) % neueTour.0.count, bei: neueTour, loescheErsteStrecke: false)
                            neueTouren.append(neueneueTour)
                        }
                        // Forderen Tourpunkt und die dazwischen Löschen
                    } else {
                        if untersuchterIndexInNeuerTour == 0 {
                            if neueTour.0.count - 1 != (StartIndexInNeuerTour + 1) % neueTour.0.count {
                                let neueneueTour = loescheTourpunkteAusTour(von: (StartIndexInNeuerTour + 1) % neueTour.0.count, bis: neueTour.0.count - 1, bei: neueTour, loescheLetzteStrecke: false)
                                neueTouren.append(neueneueTour)
                            }
                        } else {
                            let neueneueTour = loescheTourpunkteAusTour(von: (StartIndexInNeuerTour + 1) % neueTour.0.count, bis: untersuchterIndexInNeuerTour, bei: neueTour, loescheLetzteStrecke: false)
                            neueTouren.append(neueneueTour)
                        }
                        // Tourpunkte dazwischen und den hinteren Untersuchten löschen
                    }
                }
                if untersuchtesObjektNeueTour.essenziell {
                    break
                } else {
                    untersuchterIndexInNeuerTour = (untersuchterIndexInNeuerTour + 1) % neueTour.0.count
                }
            }
        }
        // Erhöhe den untersuchten Index. Wenn der Index schon das Ende der Liste war, fang wieder von vorne an.
        untersuchterIndex = (untersuchterIndex + 1) % urspruenglicheTour.count
    }
    reduziereAufKuerzesteTour()
} else {
    // Die Tour enthält keinen einzigen essenziellen Punkt, kann also auf Start- und Endpunkt reduziert werden.
    neueTouren = [([urspruenglicheTour[0], urspruenglicheTour.last!], 0)]
}

print("------\nUrsprüngliche Tour:")
for tour in urspruenglicheTour {
    print(tour.ort + " - " + tour.jahr.description + " - " + (tour.essenziell ? "Essenziell - " : "Nicht essenziell - ") + tour.abstandVomStart.description + "m" )
}

print("------\nNeue Tour:")
for tour in neueTouren[0].0 {
    print(tour.ort + " - " + tour.jahr.description + " - " + (tour.essenziell ? "Essenziell - " : "Nicht essenziell - ") + tour.abstandVomStart.description + "m" )
}

print("------\nAnalyse:")
print("- Die Tour hat nach der Kürzung \(urspruenglicheTour.count - neueTouren[0].0.count) weniger Tourpunkte.")
print("Ursprünglich waren es \(urspruenglicheTour.count), jetzt sind es \(neueTouren[0].0.count).")
print("- Die Tour ist \(urspruenglicheLaenge - neueTouren[0].1)m kürzer geworden.")
print("Ursprünglich waren es \(urspruenglicheLaenge)m, jetzt sind es \(neueTouren[0].1)m.")

// Bei einem Szenario wird der Startpunkt möglicherweise noch wegoptimiert