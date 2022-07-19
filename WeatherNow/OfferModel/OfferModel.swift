import Foundation

class OfferModel: Decodable {
    
    var cod: String?
    var message: Double?
    var cnt: Double
    var list: [ListOfferModel]?
    var city: CityModel?
}
