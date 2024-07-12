import UIKit
import AVFoundation

struct SoundCredits {
    let authorName: String
    let authorUrl: String?
    let url: String
}

struct SoundProperties {
    let name: String
    let audioFileName: String
    let image: String
    let credits: SoundCredits?
}

enum Sound: String, CaseIterable, Codable {
    case rain
    case waves
    case brownNoise
    case birds
    case fireplace
    case clock
    case keyboard
    case purr
    case cricket
    case cafe
    
    var props: SoundProperties {
        switch self {
        case .rain:
            SoundProperties(
                name: "Rain",
                audioFileName: "rain.mp3",
                image: "cloud.rain",
                credits: SoundCredits(
                    authorName: "avion_mood",
                    authorUrl: "https://pixabay.com/users/avion_mood-39857343/",
                    url: "https://pixabay.com/sound-effects/rain-sound-188158/"
                )
            )
        case .waves:
            SoundProperties(
                name: "Sea waves",
                audioFileName: "sea-waves.mp3",
                image: "water.waves",
                credits: SoundCredits(
                    authorName: "monotraum",
                    authorUrl: nil,
                    url: "https://pixabay.com/sound-effects/sea-waves-atmo-6792/"
                )
            )
        case .brownNoise:
            SoundProperties(
                name: "Brown noise",
                audioFileName: "brown-noise.mp3",
                image: "waveform",
                credits: SoundCredits(
                    authorName: "DigitalSpa",
                    authorUrl: "https://pixabay.com/users/digitalspa-39892939/",
                    url: "https://pixabay.com/sound-effects/brown-noise-by-digitalspa-170337/"
                )
            )
        case .birds:
            SoundProperties(
                name: "Birds singing",
                audioFileName: "birds.mp3",
                image: "bird",
                credits: SoundCredits(
                    authorName: "JuliusH",
                    authorUrl: "https://pixabay.com/users/juliush-3921568/",
                    url: "https://pixabay.com/sound-effects/birds-singing-nature-sounds-8001/"
                )
            )
        case .fireplace:
            SoundProperties(
                name: "Crackling fireplace",
                audioFileName: "fireplace.mp3",
                image: "flame",
                credits: SoundCredits(
                    authorName: "JuliusH",
                    authorUrl: "https://pixabay.com/users/juliush-3921568/",
                    url: "https://pixabay.com/sound-effects/crackling-fireplace-nature-sounds-8012/"
                )
            )
        case .clock:
            SoundProperties(
                name: "Clock ticking",
                audioFileName: "clock.mp3",
                image: "clock",
                credits: SoundCredits(
                    authorName: "Sonoptic",
                    authorUrl: nil,
                    url: "https://pixabay.com/sound-effects/ticking-clock-1-27477/"
                )
            )
        case .keyboard:
            SoundProperties(
                name: "Keyboard typing",
                audioFileName: "keyboard.mp3",
                image: "keyboard",
                credits: SoundCredits(
                    authorName: "Dunimaci",
                    authorUrl: "https://pixabay.com/users/dunimaci-43211049/",
                    url: "https://pixabay.com/sound-effects/keyboard-sound-200501/"
                )
            )
        case .purr:
            SoundProperties(
                name: "Cat purring",
                audioFileName: "purr.mp3",
                image: "cat",
                credits: SoundCredits(
                    authorName: "ken788",
                    authorUrl: nil,
                    url: "https://pixabay.com/sound-effects/cat-purring-71109/"
                )
            )
        case .cricket:
            SoundProperties(
                name: "Cricket chirp",
                audioFileName: "cricket.mp3",
                image: "leaf",
                credits: SoundCredits(
                    authorName: "kmckinney7",
                    authorUrl: nil,
                    url: "https://pixabay.com/sound-effects/cricket-chirp-56209/"
                )
            )
        case .cafe:
            SoundProperties(
                name: "Cafe noise",
                audioFileName: "cafe.mp3",
                image: "waveform.and.person.filled",
                credits: SoundCredits(
                    authorName: "Frederic711",
                    authorUrl: nil,
                    url: "https://pixabay.com/sound-effects/cafe-noise-32940/"
                )
            )
        }
    }
}
