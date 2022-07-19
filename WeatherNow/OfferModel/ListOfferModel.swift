import Foundation

class ListOfferModel: Decodable {
    
    var dt: Int?
    var main: MainOfferModel?
    var weather: [WeatherOfferModel]?
    var wind: WindOfferModel?
    var dt_txt: String?
   
}
