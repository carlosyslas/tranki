import XCTest
@testable import tranki

final class PlayerSettingsViewModelTests: XCTestCase {
    func test_onInit_setsTheDefaultSettingsAsADictionaryInTheVM() {
        let vm = makePlayerSettingsVM()
        
        let firstSound = Sound.allCases.first
        let settings: Dictionary<String, SoundSettings> = vm.soundSettings
        
        XCTAssertEqual(settings.count, Sound.allCases.count)
        settings.values.forEach { setting in
            XCTAssertEqual(setting.volume, 0.5)
            // Only the first sound is active by defualt
            if setting.sound == firstSound {
                XCTAssertTrue(setting.isActive)
            } else {
                XCTAssertFalse(setting.isActive)
            }
        }
    }
    
    func test_setVolume_setsASoundVolumeAndPersistIt() {
        let persistenceManager = FakePersistenceManager()
        let vm = makePlayerSettingsVM(persistenceManager: persistenceManager)
        let volumeLevel: Float = 0.73
        
        vm.setVolume(sound: .rain, volume: volumeLevel)
        guard let storedData = persistenceManager.currentData else {
            XCTFail("Stored data is nil")
            return
        }
        guard let storedSettings = jsonDecodeSettings(settingsJSONData: storedData) else {
            XCTFail("Could not decode VM's settings")
            return
        }
        
        XCTAssertEqual(vm.getVolume(sound: .rain), volumeLevel)
        XCTAssertEqual(vm.soundSettings.count, storedSettings.count)
        vm.soundSettings.forEach { name, setting in
            XCTAssertEqual(setting.volume, storedSettings[name]?.volume)
        }
    }
    
    func test_toggleActive_setsASoundIsActiveAndPersistIt() {
        let persistenceManager = FakePersistenceManager()
        let vm = makePlayerSettingsVM(persistenceManager: persistenceManager)
        
        vm.toggleActive(sound: .rain)
        guard let storedData = persistenceManager.currentData else {
            XCTFail("Stored data is nil")
            return
        }
        guard let storedSettings = jsonDecodeSettings(settingsJSONData: storedData) else {
            XCTFail("Could not decode VM's settings")
            return
        }
        
        XCTAssertEqual(vm.getIsActive(sound: .rain), false)
        XCTAssertEqual(vm.soundSettings.count, storedSettings.count)
        vm.soundSettings.forEach { name, setting in
            XCTAssertEqual(setting.isActive, storedSettings[name]?.isActive)
        }
    }
    
    func test_defaultDuration() {
        let persistenceManager = FakePersistenceManager()
        let vm = makePlayerSettingsVM(persistenceManager: persistenceManager)
        
        XCTAssertEqual(vm.duration, Duration.seconds(60 * 15))
    }
    
    func test_setDuration_storesTheNewDurationInSeconds() {
        let persistenceManager = FakePersistenceManager()
        let vm = makePlayerSettingsVM(persistenceManager: persistenceManager)
        
        vm.duration = .seconds(150)
        let storedDuration = Duration.seconds(persistenceManager.currentInt)
        
        XCTAssertEqual(vm.duration, storedDuration)
    }
    
    func test_notificationsAreSentWhenChangingSettings() {
        let vm = makePlayerSettingsVM()
        expectation(
            forNotification: .muteSound,
            object: nil) { notification in
                guard let sound = notification.userInfo?["sound"] as? Sound else {
                    return false
                }
                XCTAssertEqual(sound, Sound.rain)
                return true
            }
        expectation(
            forNotification: .unmuteSound,
            object: nil) { notification in
                guard let sound = notification.userInfo?["sound"] as? Sound else {
                    return false
                }
                XCTAssertEqual(sound, Sound.rain)
                return true
            }
        expectation(
            forNotification: .setSoundVolume,
            object: nil) { notification in
                guard let sound = notification.userInfo?["sound"] as? Sound else {
                    return false
                }
                guard let volume = notification.userInfo?["volume"] as? Float else {
                    return false
                }
                XCTAssertEqual(sound, Sound.rain)
                XCTAssertEqual(volume, 0.72)
                
                return true
            }
        expectation(
            forNotification: .setDuration,
            object: nil) { notification in
                guard let duration = notification.userInfo?["duration"] as? Duration else {
                    return false
                }
                
                XCTAssertEqual(duration, Duration.seconds(123))
                
                return true
            }
        
        vm.toggleActive(sound: .rain)
        vm.toggleActive(sound: .rain)
        vm.setVolume(sound: .rain, volume: 0.72)
        vm.duration = .seconds(123)
        
        waitForExpectations(timeout: 4)
    }

    func makePlayerSettingsVM() -> PlayerSettingsViewModel {
        return PlayerSettingsViewModel(
            persistenceManager: FakePersistenceManager()
        )
    }
    
    func makePlayerSettingsVM(persistenceManager: PersistenceManager) -> PlayerSettingsViewModel {
        return PlayerSettingsViewModel(
            persistenceManager: persistenceManager
        )
    }
    
    func jsonDecodeSettings(settingsJSONData: Data) -> [String: SoundSettings]? {
        do {
            return try JSONDecoder().decode([String: SoundSettings].self, from: settingsJSONData)
        } catch {
            return nil
        }
    }
}
