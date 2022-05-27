
import Foundation

class CityManager {
    
    static let shared = CityManager()
    private init () {}

    func getCity(compelition: @escaping ([CityObject]) -> ()) {
        
        guard let path = Bundle.main.path(forResource: "city", ofType: "json") else { return }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let object = try JSONDecoder().decode([CityObject].self, from: data)
            DispatchQueue.main.async {
                compelition(object)
            }  
        } catch {
            print("Can't parse cities \(error.localizedDescription)")
        }
    }
}
