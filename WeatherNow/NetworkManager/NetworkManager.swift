import Foundation

class NetworkManager {
    
    private init() {}
    
    static let shared = NetworkManager()
    
    func getWeather(city: String, complition: @escaping ((OfferModel?) -> ())) {
        
        var component: URL? {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "api.openweathermap.org"
            urlComponents.path = "/data/2.5/forecast"
            urlComponents.queryItems = [
                URLQueryItem(name: "q", value: city),
                URLQueryItem(name: "units", value: "metric"),
                URLQueryItem(name: "lang", value: "ru"),
                URLQueryItem(name: "appid", value: "d75aad10904284a3cb0b66f6eb729728")
            ]
            return urlComponents.url
        }
        
        if let url = component {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil, let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print()
                            let object = try JSONDecoder().decode(OfferModel.self, from: data)
                            //                            print(object)
                            complition(object)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            task.resume()
        }
    }
    
    func getWeatherLocation(lat: String, lon: String, complition: @escaping ((OfferModel?) -> ())) {
        
        var component: URL? {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "api.openweathermap.org"
            urlComponents.path = "/data/2.5/forecast"
            urlComponents.queryItems = [
                URLQueryItem(name: "lat", value: lat),
                URLQueryItem(name: "lon", value: lon),
                URLQueryItem(name: "units", value: "metric"),
                URLQueryItem(name: "lang", value: "ru"),
                URLQueryItem(name: "appid", value: "d75aad10904284a3cb0b66f6eb729728")
            ]
            return urlComponents.url
        }
        
        if let url = component {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil, let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print()
                            let object = try JSONDecoder().decode(OfferModel.self, from: data)
                            //                            print(object)
                            complition(object)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            task.resume()
        }
    }
}
