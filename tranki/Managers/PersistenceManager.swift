import Foundation

protocol PersistenceManager {
    func getData(for key: String) -> Data?
    func getInt(for key: String) -> Int
    func setData(for key: String, data: Data)
    func setInt(for key: String, n: Int)
}

final class UserDefaultsPersistenceManager: PersistenceManager {
    func getData(for key: String) -> Data? {
        UserDefaults.standard.data(forKey: key)
    }
    
    func getInt(for key: String) -> Int {
        UserDefaults.standard.integer(forKey: key)
    }
    
    func setData(for key: String, data: Data) {
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func setInt(for key: String, n: Int) {
        UserDefaults.standard.set(n, forKey: key)
    }
}
