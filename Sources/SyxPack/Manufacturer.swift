import Foundation

public typealias ByteTriplet = (Byte, Byte, Byte)

public enum Manufacturer {
    case standard(Byte)
    case extended(ByteTriplet)
    case development

    public enum Group {
        case development
        case northAmerican
        case europeanAndOther
        case japanese
    }

    public var group: Group {
        switch self {
        case .development:
            return Group.development
        case .standard(let b):
            if (0x01..<0x40).contains(b) {
                return Group.northAmerican
            }
            else if (0x40..<0x60).contains(b) {
                return Group.japanese
            }
            else {
                return Group.europeanAndOther
            }
        case .extended(let bs):
            if bs.1 & (1 << 6) != 0 {  // 0x4x
                return Group.japanese
            }
            else if bs.1 & (1 << 5) != 0 { // 0x2x
                return Group.europeanAndOther
            }
            else {
                return Group.northAmerican
            }
        }
    }
    
    public static let kawai = Manufacturer.standard(0x40)
    public static let roland = Manufacturer.standard(0x41)
    public static let korg = Manufacturer.standard(0x42)
    public static let yamaha = Manufacturer.standard(0x43)
    public static let alesis = Manufacturer.extended((0x00, 0x00, 0x0E))
    
    public var name: String {
        switch self {
        case .development:
            return "Development / Non-commercial"
        case .standard(let b):
            let idString = String(format: "%02X", b)
            if let nameString = Manufacturer.allNames[idString] {
                return nameString
            }
        case .extended(let bs):
            let idString = String(format: "%02X%02X%02X", bs.0, bs.1, bs.2)
            if let nameString = Manufacturer.allNames[idString] {
                return nameString
            }
        }
        return "(unknown)"
    }
    
    private static let allNames: [String : String] = [
        "01": "Sequential Circuits",
        "02": "IDP",
        "03": "Voyetra Turtle Beach, Inc.",
        "04": "Moog Music",
        "05": "Passport Designs",
        "06": "Lexicon Inc.",
        "07": "Kurzweil / Young Chang",
        "08": "Fender",
        "09": "MIDI9",
        "0A": "AKG Acoustics",
        "0B": "Voyce Music",
        "0C": "WaveFrame (Timeline)",
        "0D": "ADA Signal Processors, Inc.",
        "0E": "Garfield Electronics",
        "0F": "Ensoniq",
        "10": "Oberheim / Gibson Labs",
        "11": "Apple",
        "12": "Grey Matter Response",
        "13": "Digidesign Inc.",
        "14": "Palmtree Instruments",
        "15": "JLCooper Electronics",
        "16": "Lowrey Organ Company",
        "17": "Adams-Smith",
        "18": "E-mu",
        "19": "Harmony Systems",
        "1A": "ART",
        "1B": "Baldwin",
        "1C": "Eventide",
        "1D": "Inventronics",
        "1E": "Key Concepts",
        "1F": "Clarity",
        "20": "Passac",
        "21": "Proel Labs (SIEL)",
        "22": "Synthaxe (UK)",
        "23": "Stepp",
        "24": "Hohner",
        "25": "Twister",
        "26": "Ketron s.r.l.",
        "27": "Jellinghaus MS",
        "28": "Southworth Music Systems",
        "29": "PPG (Germany)",
        "2A": "JEN",
        "2B": "Solid State Logic Organ Systems",
        "2C": "Audio Veritrieb-P. Struven",
        "2D": "Neve",
        "2E": "Soundtracs Ltd.",
        "2F": "Elka",
        "30": "Dynacord",
        "31": "Viscount International Spa (Intercontinental Electronics)",
        "32": "Drawmer",
        "33": "Clavia Digital Instruments",
        "34": "Audio Architecture",
        "35": "Generalmusic Corp SpA",
        "36": "Cheetah Marketing",
        "37": "C.T.M.",
        "38": "Simmons UK",
        "39": "Soundcraft Electronics",
        "3A": "Steinberg Media Technologies GmbH",
        "3B": "Wersi Gmbh",
        "3C": "AVAB Niethammer AB",
        "3D": "Digigram",
        "3E": "Waldorf Electronics GmbH",
        "3F": "Quasimidi",

        "000001": "Time/Warner Interactive",
        "000002": "Advanced Gravis Comp. Tech Ltd.",
        "000003": "Media Vision",
        "000004": "Dornes Research Group",
        "000005": "K-Muse",
        "000006": "Stypher",
        "000007": "Digital Music Corp.",
        "000008": "IOTA Systems",
        "000009": "New England Digital",
        "00000A": "Artisyn",
        "00000B": "IVL Technologies Ltd.",
        "00000C": "Southern Music Systems",
        "00000D": "Lake Butler Sound Company",
        "00000E": "Alesis Studio Electronics",
        "00000F": "Sound Creation",
        "000010": "DOD Electronics Corp.",
        "000011": "Studer-Editech",
        "000012": "Sonus",
        "000013": "Temporal Acuity Products",
        "000014": "Perfect Fretworks",
        "000015": "KAT Inc.",

        // European & Other Group
        "002000": "Dream SAS",
        "002001": "Strand Lighting",
        "002002": "Amek Div of Harman Industries",
        "002003": "Casa Di Risparmio Di Loreto",
        "002004": "Böhm electronic GmbH",
        "002005": "Syntec Digital Audio",
        "002006": "Trident Audio Developments",
        "002007": "Real World Studio",
        "002008": "Evolution Synthesis, Ltd",
        "002009": "Yes Technology",
        "00200A": "Audiomatica",
        "00200B": "Bontempi SpA (Sigma)",
        "00200C": "F.B.T. Elettronica SpA",

        "002029": "Focusrite/Novation",

        "40": "Kawai Musical Instruments MFG. CO. Ltd",
        "41": "Roland Corporation",
        "42": "Korg Inc.",
        "43": "Yamaha",
        "44": "Casio Computer Co. Ltd",
        // 0x45 is not assigned
        "46": "Kamiya Studio Co. Ltd",
        "47": "Akai Electric Co. Ltd.",
        "48": "Victor Company of Japan, Ltd.",
        "4B": "Fujitsu Limited",
        "4C": "Sony Corporation",
        "4E": "Teac Corporation",
        "50": "Matsushita Electric Industrial Co. , Ltd",
        "51": "Fostex Corporation",
        "52": "Zoom Corporation",
        "54": "Matsushita Communication Industrial Co., Ltd.",
        "55": "Suzuki Musical Instruments MFG. Co., Ltd.",
        "56": "Fuji Sound Corporation Ltd.",
        "57": "Acoustic Technical Laboratory, Inc.",
        // 58h is not assigned
        "59": "Faith, Inc.",
        "5A": "Internet Corporation",
        // 5Bh is not assigned
        "5C": "Seekers Co. Ltd.",
        // 5Dh and 5Eh are not assigned
        "5F": "SD Card Association",

        "004000": "Crimson Technology Inc.",
        "004001": "Softbank Mobile Corp",
        "004003": "D&M Holdings Inc.",
        "004004": "Xing Inc.",
        "004005": "Alpha Theta Corporation",
        "004006": "Pioneer Corporation",
        "004007": "Slik Corporation",
    ]
}

// MARK: - Equatable

extension Manufacturer: Equatable { }
extension Manufacturer.Group: Equatable { }

// Explicitly implementing the equals operator for Manufacturer
// because the some of its variants have associated values.
public func ==(lhs: Manufacturer, rhs: Manufacturer) -> Bool {
    switch (lhs, rhs) {
    case (let .standard(lhsByte), let .standard(rhsByte)):
        return lhsByte == rhsByte
    case (let .extended(lhsByteTriplet), let .extended(rhsByteTriplet)):
        return lhsByteTriplet.0 == rhsByteTriplet.0 &&
               lhsByteTriplet.1 == rhsByteTriplet.1 &&
               lhsByteTriplet.2 == rhsByteTriplet.2
    case (.development, .development):
        return true
    default:
        return false
    }
}

extension Manufacturer.Group: CustomStringConvertible {
    public var description: String {
        switch self {
        case .northAmerican:
            return "North American"
        case .japanese:
            return "Japanese"
        case .europeanAndOther:
            return "European & Other"
        case .development:
            return ""
        }
    }
}

extension Manufacturer: CustomStringConvertible {
    public var description: String {
        var result = self.name + " ("
        
        switch self {
        case .standard(let b):
            result += String(format: "%02X", b)
        case .extended(let bs):
            result += String(format: "%02X %02X %02X", bs.0, bs.1, bs.2)
        case .development:
            return "7D"
        }

        result += ")"
        
        return result
    }
}
