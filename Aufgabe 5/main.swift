// 42. Bundeswettbewerb Informatik, Team Deutscher Qualitätscode
import Foundation

struct Tourpunkt: Equatable {
    let jahr: Int
    let ort: String
    let essenziell: Bool
    var abstandVomStart: Int

    static func == (_ lhs: Tourpunkt, _ rhs: Tourpunkt) -> Bool {
        lhs.jahr == rhs.jahr && lhs.ort == rhs.ort
    }
}

var urspruenglicheTour: [Tourpunkt] = []

// Tour aus der externen Datei einlesen
let dateiNummer: String = CommandLine.arguments.last ?? "-"
let dateiNummerInt: Int = Int(dateiNummer) ?? 1
let pfad: URL = URL(fileURLWithPath: "../Daten/A5_Stadtfuehrung/tour\(dateiNummerInt).txt")
guard let text: String = try? String(contentsOf: pfad) else {
    print("Datei konnte nicht gefunden / ausgelesen werden.")
    exit(EXIT_FAILURE)
}
var zeilen = text.split(whereSeparator: \.isNewline)
let ersteZeile = zeilen.removeFirst()

for zeile in zeilen {
    let parameter = zeile.split(separator: ",")
    guard parameter.count == 4, let jahr = Int(parameter[1].replacing(" ", with: "")), let abstand = Int(parameter[3].replacing(" ", with: "")) else {
        print("Die Zeile \"\(zeile)\" hat nicht das erwartete Format.")
        exit(EXIT_FAILURE)
    }
    let neuerTourpunkt = Tourpunkt(jahr: jahr, ort: String(parameter[0]), essenziell: parameter[2] == "X", abstandVomStart: abstand)
    urspruenglicheTour.append(neuerTourpunkt)
}

guard urspruenglicheTour.count > 2 else {
    print("Die Route muss mindestens 3 Tourpunkte enthalten, um möglicherweise optimiert werden zu können.")
    exit(EXIT_FAILURE)
}

// Force-Unwrap wird immer gelingen, da in Z.38 gesichert wurde, dass die Liste mindestens 3 Elemente hat.
let urspruenglicheLaenge = urspruenglicheTour.last!.abstandVomStart

// Eine Liste möglicher neue Touren, mit ihrer jeweiligen Länge
// TODO: Könnte zu einem Dictinary (Map) umgeformt werden
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
    var veraenderbareTour = tour // Veränderbare Kopie der Tour
    var schonGeloeschte = 0
    var entfernteStrecke = 0
    if endIndex > startIndex {
        for i in startIndex...endIndex {
            // Tourpunkt löschen
            veraenderbareTour.0.remove(at: i - schonGeloeschte)
            schonGeloeschte += 1
            // Länge anpassen
            if i != 0 && (i != startIndex || loescheErsteStrecke) {
                // Zu dem betrachteten Punkt hinführende Strecke löschen
                let streckeZuDiesemPunkt = tour.0[i].abstandVomStart - tour.0[i - 1].abstandVomStart
                entfernteStrecke += streckeZuDiesemPunkt
            }
            if i == endIndex && loescheLetzteStrecke && i != tour.0.count - 1 {
                // Von dem betrachteten Punkt wegführende Strecke löschen
                // Wird nur ausgeführt, wenn es der letzte zu Löschende Index ist, und _loescheLetzteStrecke_ wahr ist.
                let streckeAbDiesemPunkt = tour.0[i + 1].abstandVomStart - tour.0[i].abstandVomStart
                entfernteStrecke += streckeAbDiesemPunkt
            }
        }
    } else {
        print("x")
        // Zu löschende Tourpunkte gehen über das Ende der Tour hinaus
        // Lösche zunächst die Tourpunkte vom _startIndex_ bis zum Ende der Liste
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
        // _schonGeloeschte_ muss zurückgesetzt werden, da sonst das remove Statement in der
        // folgenden Schleife nicht die richtigen Tourpunkte löscht
        schonGeloeschte = 0
        // Verrechne die entfernte Strecke mit der ingesamten Streckenlänge und setzte sie anschließend zurück.
        // Begründung: Später wird die Entfernung zum Anfang der Tour für alle Punkte neu berechnet. Dabei darf nicht
        // ins Gewicht fallen, wie viel Strecke grade am Ende der Liste gelöscht wurde, sondern nur wieviel gleich
        // vom Anfang der Liste weggenommen wird.
        veraenderbareTour.1 -= entfernteStrecke
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
    }
    veraenderbareTour.1 -= entfernteStrecke
    if endIndex != veraenderbareTour.0.count - 1 {
        for tourpunkt in veraenderbareTour.0[(endIndex - schonGeloeschte) + 1 ..< veraenderbareTour.0.count].enumerated() {
            veraenderbareTour.0[tourpunkt.offset + (endIndex - schonGeloeschte) + 1].abstandVomStart -= entfernteStrecke
        }
    }
    return veraenderbareTour
}

// Ersten essenziellen Punkt in der Route finden
if let indexVomErstenEssenziellenPunkt = urspruenglicheTour.firstIndex(where: {$0.essenziell}) {

    // Die Suche startet beim ersten essenziellen Punkt, damit keine Schleifen übersehen werden können.
    // TODO: Diese Entscheidung in der Dokumentation ausführlicher erklären
    var untersuchterIndex = indexVomErstenEssenziellenPunkt

    for _ in 0..<urspruenglicheTour.count {
        let untersuchtesObjekt = urspruenglicheTour[untersuchterIndex]
        if untersuchtesObjekt.essenziell {
            // Bei essenziellen Punkten kann der bisher schnellste Weg als generell schnellster Weg deklariert werden
            reduziereAufKuerzesteTour()
        }
        // Alle verschiedenen neuen Touren absuchen
        for neueTour in neueTouren {
            // Index des untersuchten Tourpunktes in der betrachteten neuen Tour.
            // Muss nicht mit _untersuchterIndex_ übereinstimmen, da bei der neuenTour ja Elemente fehlen können.
            // Wenn der Tourpunkt nicht in der neuen Tour ist, wird zur nächsten neuen Tour geskippt.
            guard let StartIndexInNeuerTour = neueTour.0.firstIndex(of: untersuchtesObjekt) else {continue }
            // Durchlaufender Index, mit welchem nun nach Schleifen, die von _StartIndexInNeuerTour_ ausgehen, gesucht wird.
            var untersuchterIndexInNeuerTour = (StartIndexInNeuerTour + 1) % neueTour.0.count
            // Breche den Loop ab, wenn er die ganze Liste einmal durchgesucht hat.
            while StartIndexInNeuerTour != untersuchterIndexInNeuerTour {
                let untersuchtesObjektNeueTour = neueTour.0[untersuchterIndexInNeuerTour]
                let willStartEndPaarEntfernen = (StartIndexInNeuerTour == neueTour.0.count - 1) && (untersuchterIndexInNeuerTour == 0)
                if untersuchtesObjektNeueTour.ort == untersuchtesObjekt.ort && !willStartEndPaarEntfernen {
                    let keinOrtDazwischen = (StartIndexInNeuerTour + 1) % neueTour.0.count == untersuchterIndexInNeuerTour
                    if untersuchtesObjekt.essenziell && untersuchtesObjektNeueTour.essenziell && !keinOrtDazwischen {
                        let neueneueTour = loescheTourpunkteAusTour(von: (StartIndexInNeuerTour + 1) % neueTour.0.count, bis: (untersuchterIndexInNeuerTour - 1) % neueTour.0.count, bei: neueTour)
                        neueTouren.append(neueneueTour)
                        // Lösche alle Strecken dazwischen
                    } else if !untersuchtesObjekt.essenziell && untersuchtesObjektNeueTour.essenziell {
                        if untersuchterIndexInNeuerTour < StartIndexInNeuerTour {
                            let keinOrtDazwischen = (StartIndexInNeuerTour + 1) % neueTour.0.count == (untersuchterIndexInNeuerTour - 1) % neueTour.0.count
                            if !keinOrtDazwischen {
                                let neueneueTour = loescheTourpunkteAusTour(von: (StartIndexInNeuerTour + 1) % neueTour.0.count, bis: (untersuchterIndexInNeuerTour - 1) % neueTour.0.count, bei: neueTour)
                                neueTouren.append(neueneueTour)
                            }
                        } else {
                            let neueneueTour = loescheTourpunkteAusTour(von: StartIndexInNeuerTour, bis: (untersuchterIndexInNeuerTour - 1) % neueTour.0.count, bei: neueTour, loescheErsteStrecke: false)
                            neueTouren.append(neueneueTour)
                        }
                        // Forderen Tourpunkt und die dazwischen Löschen
                    } else {
                        if untersuchterIndexInNeuerTour < StartIndexInNeuerTour  {
                            let keinOrtDazwischen = (StartIndexInNeuerTour + 1) % neueTour.0.count == (untersuchterIndexInNeuerTour - 1) % neueTour.0.count
                            if !keinOrtDazwischen {
                                let neueneueTour = loescheTourpunkteAusTour(von: (StartIndexInNeuerTour + 1) % neueTour.0.count, bis: (untersuchterIndexInNeuerTour - 1) % neueTour.0.count, bei: neueTour)
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
                    // Breche den Suchvorgang ab wenn du auf einen essenziellen Punkt gestoßen bist.
                    // Loop wird allerdings erst hier unten (nach dem Suchvorgang) abgebrochen, damit Schleifen zwischen
                    // essenziellen Punkten gefunden werden können.
                    break
                } else {
                    // Erhöhe den Index, und fang von vorne an wenn du am Ende der Liste bist
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

// Ausgabe
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