// 42. Bundeswettbewerb Informatik, Team Deutscher Qualitätscode
import Foundation

struct Tourpunkt: Equatable {
    let jahr: Int
    let ort: String
    let essenziell: Bool
    let abstandVomStart: Int
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

func reduziereAufKuerzesteTour(){
    var kuerzesteTour = (urspruenglicheTour, urspruenglicheLaenge)
    for i in neueTouren {
        if i.1 < kuerzesteTour.1 {
            kuerzesteTour = i
        }
    }
    neueTouren = [kuerzesteTour]
}

func loescheTourpunkteAusTour(von startIndex: Int, bis endIndex: Int, bei tour: ([Tourpunkt], Int)) -> ([Tourpunkt], Int) {
    var veraenderbareTour = tour
    if endIndex > startIndex {
        var schonGeloeschte = 0
        for i in startIndex...endIndex {
            // Löschen der Tourpunkte
            veraenderbareTour.0.remove(at: i - schonGeloeschte)
            schonGeloeschte += 1
            // Verändern der Länge
            if i != 0 {
                let streckeZuDiesemPunkt = tour.0[i].abstandVomStart - tour.0[i - 1].abstandVomStart
                veraenderbareTour.1 -= streckeZuDiesemPunkt
            }
        }
    } else {
        var schonGeloeschte = 0
        for i in startIndex...(tour.0.count - 1) {
            veraenderbareTour.0.remove(at: i - schonGeloeschte)
            schonGeloeschte += 1
            // Check das i ungleich 0 ist ist hier nicht nötig
            let streckeZuDiesemPunkt = tour.0[i].abstandVomStart - tour.0[i - 1].abstandVomStart
            veraenderbareTour.1 -= streckeZuDiesemPunkt
        }
        schonGeloeschte = 0
        for i in 0...endIndex {
            veraenderbareTour.0.remove(at: i - schonGeloeschte)
            schonGeloeschte += 1
            if i != 0 {
                let streckeZuDiesemPunkt = tour.0[i].abstandVomStart - tour.0[i - 1].abstandVomStart
                veraenderbareTour.1 -= streckeZuDiesemPunkt
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
            var untersuchterIndexInNeuerTour = (StartIndexInNeuerTour + 1) % neueTour.0.count
            while StartIndexInNeuerTour != untersuchterIndexInNeuerTour {
                let untersuchtesObjektNeueTour = neueTour.0[untersuchterIndexInNeuerTour]
                if untersuchtesObjektNeueTour.ort == untersuchtesObjekt.ort && !((StartIndexInNeuerTour == neueTour.0.count - 1) && (untersuchterIndexInNeuerTour == 0)) {
                    if untersuchtesObjekt.essenziell && untersuchtesObjektNeueTour.essenziell {
                        if !((StartIndexInNeuerTour + 1) % neueTour.0.count == untersuchterIndexInNeuerTour) {
                            let neueneueTour = loescheTourpunkteAusTour(von: (StartIndexInNeuerTour + 1) % neueTour.0.count, bis: (untersuchterIndexInNeuerTour - 1) % neueTour.0.count, bei: neueTour)
                            neueTouren.append(neueneueTour)
                            // Nur die Punkte zwischen den beiden gleichen Punkten löschen
                        }
                    } else if !untersuchtesObjekt.essenziell && untersuchtesObjektNeueTour.essenziell {
                        let neueneueTour = loescheTourpunkteAusTour(von: StartIndexInNeuerTour, bis: (untersuchterIndexInNeuerTour - 1) % neueTour.0.count, bei: neueTour)
                        neueTouren.append(neueneueTour)
                        // Forderen Tourpunkt und die dazwischen Löschen
                    } else {
                        let neueneueTour = loescheTourpunkteAusTour(von: (StartIndexInNeuerTour + 1) % neueTour.0.count, bis: untersuchterIndexInNeuerTour, bei: neueTour)
                        neueTouren.append(neueneueTour)
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

// ToDo: Nochmal untersuchen, ob vielleicht die unterteilung welche Indexe gelöscht werden müssen 
// geändert gehört, oder ob sich dadurch nicht optimal behandelte Fälle bilden könnten.

// Strecke wird noch nicht korrekt berechnet, weil es für die Funktion unklar ist welche Strecken alle gelöscht werden müssen