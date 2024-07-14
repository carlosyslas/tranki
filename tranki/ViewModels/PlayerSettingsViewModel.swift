import Foundation

protocol PlayerSettingsViewModelDelegate {
    func playerSettingsViewModelDurationUpdated(duration: Duration)
}

final class PlayerSettingsViewModel: ObservableObject {
    private static let soundSettingsKey = "soundSettings"
    private static let durationKey = "duration"
    private let persistenceManager: PersistenceManager
    var delegate: PlayerSettingsViewModelDelegate?

    var duration: Duration {
        didSet {
            delegate?.playerSettingsViewModelDurationUpdated(duration: duration)
            publishSetDurationEvent(duration: duration)
            storeDuration(durationInSeconds: Int(duration.components.seconds))
        }
    }
    var soundSettings = [String: SoundSettings]()

    init(persistenceManager: PersistenceManager) {
        duration = .zero
        
        self.persistenceManager = persistenceManager
        duration = .seconds(loadDurationInSeconds())
        soundSettings = loadSettings()
    }

    func toggleActive(sound: Sound) {
        guard let currentSettings = soundSettings[sound.rawValue] else { return }
        soundSettings[sound.rawValue] = SoundSettings(
            isActive: !currentSettings.isActive,
            sound: sound,
            volume: currentSettings.volume
        )
 
        storeSettings(soundSettings: soundSettings)
        if currentSettings.isActive {
            publishMuteEvent(sound)
        } else {
            publishUnmuteEvent(sound)
        }
    }
    
    func setVolume(sound: Sound, volume: Float) {
        guard let currentSettings = soundSettings[sound.rawValue] else { return }
        guard currentSettings.isActive else { return }
        soundSettings[sound.rawValue] = SoundSettings(
            isActive: currentSettings.isActive,
            sound: sound,
            volume: volume
        )
        
        storeSettings(soundSettings: soundSettings)
        publishSetVoulumeEvent(sound, volume: volume)
    }
    
    func getVolume(sound: Sound) -> Float {
        soundSettings[sound.rawValue]?.volume ?? 0.0
    }
    
    func getIsActive(sound: Sound) -> Bool {
        soundSettings[sound.rawValue]?.isActive ?? false
    }

    private func publishMuteEvent(_ sound: Sound) {
        NotificationCenter.default.post(name: .muteSound, object: nil, userInfo: ["sound": sound])
    }
    
    private func publishUnmuteEvent(_ sound: Sound) {
        NotificationCenter.default.post(name: .unmuteSound, object: nil, userInfo: ["sound": sound])
    }
    
    private func publishSetVoulumeEvent(_ sound: Sound, volume: Float) {
        NotificationCenter.default.post(
            name: .setSoundVolume,
            object: nil,
            userInfo: ["sound": sound, "volume": volume]
        )
    }
    
    private func publishSetDurationEvent(duration: Duration) {
        NotificationCenter.default.post(name: .setDuration, object: nil, userInfo: ["duration": duration])
    }

    private func loadSettings() -> [String: SoundSettings] {
        var settingsMap = [String: SoundSettings]()
        Sound.allCases.enumerated().map({ index, sound in
            SoundSettings(
                isActive: index == 0,
                sound: sound,
                volume: 0.5
            )
        }).forEach{ currentSetting in
            settingsMap[currentSetting.sound.rawValue] = currentSetting
        }

        guard let settingsJson = persistenceManager.getData(for: PlayerSettingsViewModel.soundSettingsKey) else {
            return settingsMap
        }
        let decoder = JSONDecoder()
        var storedSettings = [String: SoundSettings]()
        if let decodedSettings = try? decoder.decode([String: SoundSettings].self, from: settingsJson) {
            decodedSettings.forEach { (name, settings) in
                storedSettings[name] = settings
            }
        }
        
        settingsMap.forEach { (name, settings) in
            if let previousSettings = storedSettings[settings.sound.rawValue] {
                settingsMap[name] = SoundSettings(
                    isActive: previousSettings.isActive,
                    sound: settings.sound,
                    volume: previousSettings.volume
                )
            }
        }
        
        return settingsMap
    }
    
    private func storeSettings(soundSettings: [String: SoundSettings]) {
        let encoder = JSONEncoder()
        if let settingsJson = try? encoder.encode(soundSettings) {
            persistenceManager.setData(
                for: PlayerSettingsViewModel.soundSettingsKey,
                data: settingsJson
            )
        }
    }
    
    private func loadDurationInSeconds() -> Int {
        let duration = persistenceManager.getInt(
            for: PlayerSettingsViewModel.durationKey
        )
        guard duration > 0 else {
            return 60 * 15
        }
        
        return duration
    }
    
    private func storeDuration(durationInSeconds: Int) {
        persistenceManager.setInt(
            for: PlayerSettingsViewModel.durationKey,
            n: durationInSeconds
        )
    }
}
