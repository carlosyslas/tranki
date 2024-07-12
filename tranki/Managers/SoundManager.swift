import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private let engine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    private var audioPlayers = [AVAudioPlayerNode]()
    private var isPlaying = false
    
    init() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.setupEngineAndMixer()
        }
    }
    
    private func setupEngineAndMixer() {
        print("Setting up engine and mixer")
        engine.attach(mixer)
        engine.connect(mixer, to: engine.mainMixerNode, format: nil)
    }
    
    private func findSoundIndex(sound: Sound) -> Int? {
        return Sound.allCases.firstIndex(of: sound) // TODO: Use a dict instead
    }
    
    func playAllSounds(soundSettings: [SoundSettings]) {
        soundSettings.forEach { [weak self] settings in
            self?.playSound(soundSettings: settings)
        }
    }
    
    func playSound(soundSettings: SoundSettings) {
        isPlaying = true
        guard let index = findSoundIndex(sound: soundSettings.sound) else {
            return
        }
        
        do {
            try engine.start()
            
            let audioFile = try AVAudioFile(fileName: soundSettings.sound.props.audioFileName)
            
            if index < audioPlayers.count {
                engine.disconnectNodeOutput(audioPlayers[index])
                engine.detach(audioPlayers[index])
            }
            let player = AVAudioPlayerNode()
            if index < audioPlayers.count {
                audioPlayers[index] = player
            } else {
                audioPlayers.append(player)
            }
            engine.attach(player)
            engine.connect(player, to: mixer, format: audioFile.processingFormat)
            
            player.volume = soundSettings.isActive ? soundSettings.volume : 0.0
            player.scheduleFile(audioFile, at: nil) { [weak self] in
                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let isPlaying = self?.isPlaying else { return }
                    if isPlaying {
                        self?.playSound(soundSettings: soundSettings)
                    }
                }
            }
            player.play()
        } catch {
            print("Error playing sound: \(soundSettings.sound)")
            return
        }
    }
    
    func updateSoundVolume(sound: Sound, volume: Float) {
        guard let index = findSoundIndex(sound: sound) else { return }
        guard index < audioPlayers.count else { return }
        
        audioPlayers[index].volume = volume
    }
    
    func muteSound(sound: Sound) {
        updateSoundVolume(sound: sound, volume: 0.0)
    }
    
    func unmuteSound(sound: Sound, previousVolume: Float) {
        updateSoundVolume(sound: sound, volume: previousVolume)
    }
    
    func stopAllSounds() {
        isPlaying = false
        audioPlayers.forEach { player in
            player.stop()
        }
        engine.stop()
    }
}
