import Foundation
@testable import tranki

class FakePersistenceManager: PersistenceManager {
    var currentData: Data? = nil
    var currentInt = 0
    
    func getData(for key: String) -> Data? {
        currentData
    }
    
    func getInt(for key: String) -> Int {
        currentInt
    }
    
    func setData(for key: String, data: Data) {
        currentData = data
    }
    
    func setInt(for key: String, n: Int) {
        currentInt = n
    }
}
