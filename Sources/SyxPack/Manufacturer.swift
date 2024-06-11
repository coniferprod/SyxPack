import ByteKit

/// Represents a MIDI equipment manufacturer.
public enum Manufacturer {
    case standard(Byte)
    case extended(Byte, Byte)  // first byte of three is always zero

    /// Identifier byte for development/non-commercial
    public static let developmentIdentifierByte: Byte = 0x7D
    
    /// First byte of extended manufacturer identifier triplet
    public static let extendedIdentifierFirstByte: Byte = 0x00

    /// Predefined manufacturer identifier for Kawai.
    public static let kawai = Manufacturer.standard(0x40)
    
    /// Predefined manufacturer identifier for Roland.
    public static let roland = Manufacturer.standard(0x41)

    /// Predefined manufacturer identifier for KORG.
    public static let korg = Manufacturer.standard(0x42)

    /// Predefined manufacturer identifier for Yamaha.
    public static let yamaha = Manufacturer.standard(0x43)

    /// Predefined manufacturer identifier for Alesis.
    public static let alesis = Manufacturer.extended(0x00, 0x0E)
    
    /// Gets the bytes of the manufacturer identifier.
    public var identifier: ByteArray {
        switch self {
        case .standard(let b):
            return [b]
        case .extended(let b1, let b2):
            return [0x00, b1, b2]
        }
    }

    /// Gets the manufacturer name.
    public var name: String {
        switch self {
        case .standard(let b):
            let idString = String(format: "%02X", b)
            if let nameString = Manufacturer.allNames[idString] {
                return nameString
            }
        case .extended(let b1, let b2):
            let idString = String(format: "%02X%02X%02X", 0x00, b1, b2)
            if let nameString = Manufacturer.allNames[idString] {
                return nameString
            }
        }
        return "(unknown)"
    }
    
    /// Returns the count of manufacturers currently known to SyxPack.
    /// Does not reflect the actual number of registered manufacturers.
    public static var count: Int {
        return Manufacturer.allNames.keys.count
    }
    
    // From https://midi.org/sysexidtable
    private static let allNames: [String: String] = [
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
        "000016": "Opcode Systems",
        "000017": "Rane Corporation",
        "000018": "Anadi Electronique",
        "000019": "KMX",
        "00001A": "Allen & Heath Brenell",
        "00001B": "Peavey Electronics",
        "00001C": "360 Systems",
        "00001D": "Spectrum Design and Development",
        "00001E": "Marquis Music",
        "00001F": "Zeta Systems",
        "000020": "Axxes (Brian Parsonett)",
        "000021": "Orban",
        "000022": "Indian Valley Mfg.",
        "000023": "Triton",
        "000024": "KTI",
        "000025": "Breakway Technologies",
        "000026": "Leprecon / CAE Inc.",
        "000027": "Harrison Systems Inc.",
        "000028": "Future Lab/Mark Kuo",
        "000029": "Rocktron Corporation",
        "00002A": "PianoDisc",
        "00002B": "Cannon Research Group",
        "00002C": "Reserved",
        "00002D": "Rodgers Instrument LLC",
        "00002E": "Blue Sky Logic",
        "00002F": "Encore Electronics",
        "000030": "Uptown",
        "000031": "Voce",
        "000032": "CTI Audio, Inc. (Musically Intel. Devs.)",
        "000033": "S3 Incorporated",
        "000034": "Broderbund / Red Orb",
        "000035": "Allen Organ Co.",
        "000036": "Reserved",
        "000037": "Music Quest",
        "000038": "Aphex",
        "000039": "Gallien Krueger",
        "00003A": "IBM",
        "00003B": "Mark Of The Unicorn",
        "00003C": "Hotz Corporation",
        "00003D": "ETA Lighting",
        "00003E": "NSI Corporation",
        "00003F": "Ad Lib, Inc.",
        "000040": "Richmond Sound Design",
        "000041": "Microsoft",
        "000042": "Mindscape (Software Toolworks)",
        "000043": "Russ Jones Marketing / Niche",
        "000044": "Intone",
        "000045": "Advanced Remote Technologies",
        "000046": "White Instruments",
        "000047": "GT Electronics/Groove Tubes",
        "000048": "Pacific Research & Engineering",
        "000049": "Timeline Vista, Inc.",
        "00004A": "Mesa Boogie Ltd.",
        "00004B": "FSLI",
        "00004C": "Sequoia Development Group",
        "00004D": "Studio Electronics",
        "00004E": "Euphonix, Inc",
        "00004F": "InterMIDI, Inc.",
        "000050": "MIDI Solutions Inc.",
        "000051": "3DO Company",
        "000052": "Lightwave Research / High End Systems",
        "000053": "Micro-W Corporation",
        "000054": "Spectral Synthesis, Inc.",
        "000055": "Lone Wolf",
        "000056": "Studio Technologies Inc.",
        "000057": "Peterson Electro-Musical Product, Inc.",
        "000058": "Atari Corporation",
        "000059": "Marion Systems Corporation",
        "00005A": "Design Event",
        "00005B": "Winjammer Software Ltd.",
        "00005C": "AT&T Bell Laboratories",
        "00005D": "Reserved",
        "00005E": "Symetrix",
        "00005F": "MIDI the World",
        "000060": "Spatializer",
        "000061": "Micros ‘N MIDI",
        "000062": "Accordians International",
        "000063": "EuPhonics (now 3Com)",
        "000064": "Musonix",
        "000065": "Turtle Beach Systems (Voyetra)",
        "000066": "Loud Technologies / Mackie",
        "000067": "Compuserve",
        "000068": "BEC Technologies",
        "000069": "QRS Music Inc",
        "00006A": "P.G. Music",
        "00006B": "Sierra Semiconductor",
        "00006C": "EpiGraf",
        "00006D": "Electronics Diversified Inc",
        "00006E": "Tune 1000",
        "00006F": "Advanced Micro Devices",
        "000070": "Mediamation",
        "000071": "Sabine Musical Mfg. Co. Inc.",
        "000072": "Woog Labs",
        "000073": "Micropolis Corp",
        "000074": "Ta Horng Musical Instrument",
        "000075": "e-Tek Labs (Forte Tech)",
        "000076": "Electro-Voice",
        "000077": "Midisoft Corporation",
        "000078": "QSound Labs",
        "000079": "Westrex",
        "00007A": "Nvidia",
        "00007B": "ESS Technology",
        "00007C": "Media Trix Peripherals",
        "00007D": "Brooktree Corp",
        "00007E": "Otari Corp",
        "00007F": "Key Electronics, Inc.",
        "000100": "Shure Incorporated",
        "000101": "AuraSound",
        "000102": "Crystal Semiconductor",
        "000103": "Conexant (Rockwell)",
        "000104": "Silicon Graphics",
        "000105": "M-Audio (Midiman)",
        "000106": "PreSonus",
        "000108": "Topaz Enterprises",
        "000109": "Cast Lighting",
        "00010A": "Microsoft Consumer Division",
        "00010B": "Sonic Foundry",
        "00010C": "Line 6 (Fast Forward) (Yamaha)",
        "00010D": "Beatnik Inc",
        "00010E": "Van Koevering Company",
        "00010F": "Altech Systems",
        "000110": "S & S Research",
        "000111": "VLSI Technology",
        "000112": "Chromatic Research",
        "000113": "Sapphire",
        "000114": "IDRC",
        "000115": "Justonic Tuning",
        "000116": "TorComp Research Inc.",
        "000117": "Newtek Inc.",
        "000118": "Sound Sculpture",
        "000119": "Walker Technical",
        "00011A": "Digital Harmony (PAVO)",
        "00011B": "InVision Interactive",
        "00011C": "T-Square Design",
        "00011D": "Nemesys Music Technology",
        "00011E": "DBX Professional (Harman Intl)",
        "00011F": "Syndyne Corporation",
        
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
        "00200D": "MidiTemp GmbH",
        "00200E": "LA Audio (Larking Audio)",
        "00200F": "Zero 88 Lighting Limited",
        "002010": "Micon Audio Electronics GmbH",
        "002011": "Forefront Technology",
        "002012": "Studio Audio and Video Ltd.",
        "002013": "Kenton Electronics",

        "00201F": "TC Electronics",
        "002020": "Doepfer Musikelektronik GmbH",
        "002021": "Creative ATC / E-mu",

        "002029": "Focusrite/Novation",

        "002032": "Behringer GmbH",
        "002033": "Access Music Electronics",

        "00203A": "Propellerhead Software",

        "00206B": "Arturia",
        "002076": "Teenage Engineering",

        "002103": "PreSonus Software Ltd",

        "002109": "Native Instruments",

        "002110": "ROLI Ltd",

        "00211A": "IK Multimedia",

        "00211D": "Ableton",

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
        
        "7D": "Development / Non-Commercial"
    ]
}

extension Manufacturer {
    /// Parses the manufacturer from MIDI System Exclusive bytes.
    public static func parse(from data: ByteArray) -> Result<Manufacturer, ParseError> {
        let firstByte = data.first!
        switch firstByte {
        case extendedIdentifierFirstByte:
            return .success(.extended(data[1], data[2]))
        case 0x01...developmentIdentifierByte:
            return .success(.standard(firstByte))
        default:
            return .failure(.invalidManufacturer([firstByte]))
        }
    }
}

// MARK: - Equatable

extension Manufacturer: Equatable { }

/// Explicit implementation of the equals operator for Manufacturer.
/// Needed because the some of its variants have associated values.
public func ==(lhs: Manufacturer, rhs: Manufacturer) -> Bool {
    switch (lhs, rhs) {
    case (let .standard(lhsByte), let .standard(rhsByte)):
        return lhsByte == rhsByte
    case (let .extended(lhsb1, lhsb2), let .extended(rhsb1, rhsb2)):
        return lhsb1 == rhsb1 && lhsb2 == rhsb2
    default:
        return false
    }
}

extension Manufacturer: CustomStringConvertible {
    /// Gets a printable string representation of the manufacturer, including the identifier in hexadecimal numbers.
    public var description: String {
        var result = self.name + " ("
        
        switch self {
        case .standard(let b):
            result += String(format: "%02X", b)
        case .extended(let b1, let b2):
            result += String(format: "%02X %02X %02X", 0x00, b1, b2)
        }

        result += ")"
        
        return result
    }
}

// MARK: - SystemExclusiveData implementation

extension Manufacturer: SystemExclusiveData {
    /// Gets the manufacturer data as bytes.
    public func asData() -> ByteArray {
        self.identifier
    }
    
    /// Gets the length of the manufacturer data as bytes.
    public var dataLength: Int {
        self.identifier.count
    }
}
