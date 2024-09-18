//
//  NetworkService.swift
//  CountryDemo
//

import Foundation

class NetworkingService {
    
    // Note: use openweathermap API key
    let APIkey = ""
    
    func getWeatherAPI(country:String,leti:String = "",log:String = "",completion: @escaping (Result<WeatherBase, Error>) -> Void) {
        
        var getUrl = "https://api.openweathermap.org/data/2.5/weather?q=\(country)&appid=\(APIkey)"
        if !leti.isEmpty{
            getUrl = "https://api.openweathermap.org/data/2.5/weather?lat=\(leti)&lon=\(log)&appid=\(APIkey)"
        }else{
            getUrl = "https://api.openweathermap.org/data/2.5/weather?q=\(country)&appid=\(APIkey)"
        }
        
        guard let url = URL(string:getUrl ) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }

            do {
                let Countries = try JSONDecoder().decode(WeatherBase.self, from: data)
                completion(.success(Countries))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
