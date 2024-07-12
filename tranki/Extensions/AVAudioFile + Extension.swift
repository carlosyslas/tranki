import AVFoundation

extension AVAudioFile {
    convenience init(fileName: String) throws {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            throw AudioPlayerError.unableToLoadFile
        }
        let url = URL(fileURLWithPath: path)
        try self.init(forReading: url)
    }
}
