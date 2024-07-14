import AVFoundation

protocol SoundManager: AnyObject {
    func playAllSounds(soundSettings: [SoundSettings]) throws
    func updateSoundVolume(sound: Sound, volume: Float)
    func muteSound(sound: Sound)
    func unmuteSound(sound: Sound, previousVolume: Float)
    func stopAllSounds()
}


final class AVAudioSoundManager: SoundManager {
    static let shared = AVAudioSoundManager()
    
    private let engine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    private var audioPlayers = [Sound: AVAudioPlayerNode]()
    private var isPlaying = false
    
    init() {
        setupEngineAndMixer()
    }
    
    private func setupEngineAndMixer() {
        print("Setting up engine and mixer")
        engine.attach(mixer)
        engine.connect(mixer, to: engine.mainMixerNode, format: nil)
    }
    
    func playAllSounds(soundSettings: [SoundSettings]) throws {
        try engine.start()
        
        soundSettings.forEach { [weak self] settings in
            self?.playSound(soundSettings: settings)
        }
    }
    
    private func playSound(soundSettings: SoundSettings) {
        guard engine.isRunning == true else { return }
        isPlaying = true
        let sound = soundSettings.sound
        
        do {
            guard let fileUrl = Bundle.main.url(forResource: soundSettings.sound.props.audioFileName, withExtension: "mp3") else {
                print("Audio file not found: \(soundSettings.sound.props.audioFileName)")
                return
            }
            let audioFile = try AVAudioFile(forReading: fileUrl)
            
            let player = AVAudioPlayerNode()
            
            audioPlayers[sound] = player

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
        audioPlayers[sound]?.volume = volume
    }
    
    func muteSound(sound: Sound) {
        updateSoundVolume(sound: sound, volume: 0.0)
    }
    
    func unmuteSound(sound: Sound, previousVolume: Float) {
        updateSoundVolume(sound: sound, volume: previousVolume)
    }
    
    func stopAllSounds() {
        isPlaying = false
        audioPlayers.forEach { _, player in
            player.stop()
        }
        if engine.isRunning {
            engine.stop()
        }
    }
}
