//
//  ViewController.swift
//  MyWeather

import UIKit
import CoreLocation
import SDWebImage

class ViewController: UIViewController, CLLocationManagerDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var otherDetails: UILabel!
    @IBOutlet weak var imgWeatherIcon: UIImageView!
    var networkingService = NetworkingService()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
   
    override func viewDidLoad() {
        super.viewDidLoad()
//        searchBar.showsScopeBar = true
        if let country = UserDefaults.standard.value(forKey: "weatherCountry") as? String{
            getCountriesList(country:country)
        }
        searchBar.delegate = self
        view.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    func getCountriesList(country:String,lat:String = "",log:String = ""){
        networkingService.getWeatherAPI(country: country,leti: lat,log: log, completion: { result in

            switch result {
            case .success(let data):
                
                DispatchQueue.main.async {
                    
                    if !(self.searchBar.text ?? "").isEmpty{
                        UserDefaults.standard.set(self.searchBar.text ?? "",forKey: "weatherCountry")
                        UserDefaults.standard.synchronize()
                    }
                    
                    self.cityName.text = data.name ?? ""
                    self.weatherCondition.text = data.weather?.first?.description ?? ""
                    let temperature: Double = data.main?.temp ?? 0.0
                    self.weather.text = "\(kelvinTempToCelsius(k: temperature))°"
                    self.details.text = "H:\(kelvinTempToCelsius(k: data.main?.temp_max ?? 0.0))° L:\(kelvinTempToCelsius(k: data.main?.temp_min ?? 0.0))°"
                    
                    let imgName = data.weather?.first?.icon ?? ""
                    if !imgName.isEmpty{
                        let imageUrl = "https://openweathermap.org/img/wn/\(imgName)@2x.png"
                        let imageDownloader = SDWebImageDownloader.shared
                        imageDownloader.downloadImage(with: URL(string: imageUrl)) { image, _, errors, _ in
                            if let image = image {
                                self.imgWeatherIcon.image = image
                                SDImageCache.shared.store(image, forKey: imageUrl)
                            } else if errors != nil {
                            }
                        }
                    }
                    self.otherDetails.text = "Humidity: \(data.main?.humidity ?? 0)% \n\n Visibility: \((data.visibility ?? 0)/1000)km \n\n Wind Speed: \(data.wind?.speed ?? 0.0)meter/sec \n\n Pressure: \(data.main?.pressure ?? 00)hPa"
                    
                    
                }
            case .failure(let error):
                // Handle the error
                DispatchQueue.main.async {
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        })
    }
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    // Location
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar){
        
        if ((searchBar.text?.isEmpty) != nil){
            getCountriesList(country: searchBar.text ?? "")
        }
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil  {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            
            if let country = UserDefaults.standard.value(forKey: "weatherCountry") as? String{
                getCountriesList(country:country)
            }else{
                
                guard let currentLocation = currentLocation else {
                    return
                }
                let long = currentLocation.coordinate.longitude
                let lat = currentLocation.coordinate.latitude
                getCountriesList(country:"",lat:"\(lat)",log:"\(long)")
            }
        }
    }
}
//note: converted Defaul Kelvin to Caelsius
func kelvinTempToCelsius(k: Double) -> String {
    
    let celsiusTemp = k - 273.15
    return String(format: "%.0f", celsiusTemp)
}


