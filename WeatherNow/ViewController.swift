import UIKit
import CoreLocation
import Lottie

class ViewController: UIViewController, UISearchResultsUpdating, CLLocationManagerDelegate{
    
    //MARK: - outlets
    @IBOutlet private weak var cityView: UIView!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var tempLabel: UILabel!
    @IBOutlet private weak var descriptionlabel: UILabel!
    @IBOutlet private weak var menuImageView: UIImageView!
    @IBOutlet private weak var timeView: UIView!
    @IBOutlet private weak var blurTimeView: UIVisualEffectView!
    @IBOutlet private weak var blurDayView: UIVisualEffectView!
    @IBOutlet private weak var dayView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var blurView: UIVisualEffectView!
    
    @IBOutlet private weak var time1Label: UILabel!
    @IBOutlet private weak var time2Label: UILabel!
    @IBOutlet private weak var time3Label: UILabel!
    @IBOutlet private weak var time4Label: UILabel!
    @IBOutlet private weak var time5Label: UILabel!
    
    @IBOutlet private weak var image1View: UIImageView!
    @IBOutlet private weak var image2View: UIImageView!
    @IBOutlet private weak var image3View: UIImageView!
    @IBOutlet private weak var image4View: UIImageView!
    @IBOutlet private weak var image5View: UIImageView!
    
    @IBOutlet private weak var dataDay1Label: UILabel!
    @IBOutlet private weak var dataDay2Label: UILabel!
    @IBOutlet private weak var dataDay3Label: UILabel!
    @IBOutlet private weak var dataDay4Label: UILabel!
    @IBOutlet private weak var dataDay5Label: UILabel!
    
    @IBOutlet private weak var day1ImageView: UIImageView!
    @IBOutlet private weak var day2ImageView: UIImageView!
    @IBOutlet private weak var day3ImageView: UIImageView!
    @IBOutlet private weak var day4ImageView: UIImageView!
    @IBOutlet private weak var day5ImageView: UIImageView!
    
    @IBOutlet private weak var tempDay1Label: UILabel!
    @IBOutlet private weak var tempDay2Label: UILabel!
    @IBOutlet private weak var tempDay3Label: UILabel!
    @IBOutlet private weak var tempDay4Label: UILabel!
    @IBOutlet private weak var tempDay5Label: UILabel!
    
    @IBOutlet private weak var temp1Label: UILabel!
    @IBOutlet private weak var temp2Label: UILabel!
    @IBOutlet private weak var temp3Label: UILabel!
    @IBOutlet private weak var temp4Label: UILabel!
    @IBOutlet private weak var temp5Label: UILabel!
    
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var humidityNameLabel: UILabel!
    @IBOutlet private weak var windLabel: UILabel!
    @IBOutlet private weak var windNameLabel: UILabel!
    @IBOutlet private weak var pressureLabel: UILabel!
    @IBOutlet private weak var pressureNameLabel: UILabel!
    @IBOutlet private weak var fellLabel: UILabel!
    @IBOutlet private weak var fellNameLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    //MARK: - let
    private let locationManager = CLLocationManager()
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - var
    var offerModel: OfferModel?
    var timer = Timer()
    var animationView = AnimationView()
    var autoComletePossibilities = [String]()
    var autoComlete = [String]()
    
    //MARK: - life cycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.jsonAutoParts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.menuImage()
        self.blurTimeView.radius()
        self.blurDayView.radius()
        self.timeView.radius()
        self.dayView.radius()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animationLottie(name: "61302-weather-icon", mode: .scaleAspectFill, frame: self.cityView.bounds, view: self.cityView)
    }
    
    //MARK: - IBActions
    @IBAction func geoLacationButtonPressed(_ sender: UIButton) {
        self.stopAnimationLottie()
        self.animationLottie(name: "sunny",
                             mode: .scaleAspectFit,
                             frame: self.timeView.bounds,
                             view: self.timeView)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - flow funcs
    private func menuImage() {
        let image = UIImage(named: "menu")
        self.menuImageView.image = image
    }
    
    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        //        print("locations = \(location.latitude) \(location.longitude)")
        locationManager.stopUpdatingLocation()
        
        NetworkManager.shared.getWeatherLocation(lat: String(location.latitude), lon: String(location.longitude)) { (model) in
            if model != nil {
                self.offerModel = model
            }
            DispatchQueue.main.async {
                self.stopAnimationLottie()
                self.weatherToday()
                self.weatherTime()
                self.weatherByDay()
                self.hiddenView()
            }
        }
    }
    
    private func setupNavigationBar() {
        self.navigationItem.title = "Weather Now"
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let city = searchController.searchBar.text {
            timer.invalidate()
            self.stopAnimationLottie()
            if city.count > 0 {
                timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (timer) in
                    self.animationLottie(name: "sunny", mode: .scaleAspectFit, frame: self.timeView.bounds, view: self.timeView)
                    NetworkManager.shared.getWeather(city: city) { (model) in
                        if model != nil {
                            self.offerModel = model
                        }
                        DispatchQueue.main.async {
                            searchController.searchBar.resignFirstResponder()
                            searchController.searchBar.text = ""
                            self.tableView.isHidden = true
                            self.blurView.alpha = 0
                            self.stopAnimationLottie()
                            self.weatherToday()
                            self.weatherTime()
                            self.weatherByDay()
                            self.hiddenView()
                        }
                    }
                })
            }
        } else {
            timer.invalidate()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
        searchController.searchBar.text = ""
        self.tableView.isHidden = true
        self.blurView.alpha = 0
    }
    
    private func animationLottie (name: String, mode: UIView.ContentMode, frame: CGRect,  view: UIView) {
        animationView = AnimationView(name: name)
        animationView.contentMode = mode
        animationView.frame = frame
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
    }
    
    private func stopAnimationLottie() {
        self.animationView.stop()
        self.animationView.removeFromSuperview()
    }
    
    private func searchAutocomleteEntriesWithSubstring(_ substring: String) {
        autoComlete.removeAll(keepingCapacity: false)
        for key in autoComletePossibilities {
            let myString:NSString = key as NSString
            let substringRange:NSRange = myString.range(of: substring)
            if (substringRange.location == 0) {
                autoComlete.append(key)
            }
        }
        tableView.reloadData()
    }
    
    private func jsonAutoParts() {
        guard let path = Bundle.main.path(forResource: "cities", ofType: "json") else {
            return }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let object = try JSONDecoder().decode(Cities.self, from: data)
            print(object)
            for city in object.city {
                autoComletePossibilities.append(city.name)
            }
        } catch {
            print("Data err")
        }
    }
    
    private func weatherToday() {
        self.cityLabel.text = self.offerModel?.city?.name
        self.tempLabel.text = String(Int(round((self.offerModel?.list?[0].main?.temp ?? Double())))) + "°"
        self.descriptionlabel.text = self.offerModel?.list?[0].weather?[0].description
        self.imageView.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[0].weather?[0].icon ?? String()))@4x.png")
        self.humidityLabel.text = String((self.offerModel?.list?[0].main?.humidity ?? Int())) + " %"
        self.windLabel.text = String(Int(round((self.offerModel?.list?[0].wind?.speed ?? Double())))) + " m/s"
        self.pressureLabel.text = String((self.offerModel?.list?[0].main?.pressure ?? Int())) + " mm"
        self.fellLabel.text = String(Int(round((self.offerModel?.list?[0].main?.feels_like ?? Double())))) + "°"
    }
    
    private func weatherTime() {
        self.time1Label.formatterDate((self.offerModel?.list?[0].dt_txt ?? String()), (self.offerModel?.city?.timezone ?? Int()))
        self.time2Label.formatterDate((self.offerModel?.list?[1].dt_txt ?? String()), (self.offerModel?.city?.timezone ?? Int()))
        self.time3Label.formatterDate((self.offerModel?.list?[2].dt_txt ?? String()), (self.offerModel?.city?.timezone ?? Int()))
        self.time4Label.formatterDate((self.offerModel?.list?[3].dt_txt ?? String()), (self.offerModel?.city?.timezone ?? Int()))
        self.time5Label.formatterDate((self.offerModel?.list?[4].dt_txt ?? String()), (self.offerModel?.city?.timezone ?? Int()))
        
        self.image1View.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[0].weather?[0].icon ?? String()))@4x.png")
        self.image2View.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[1].weather?[0].icon ?? String()))@4x.png")
        self.image3View.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[2].weather?[0].icon ?? String()))@4x.png")
        self.image4View.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[3].weather?[0].icon ?? String()))@4x.png")
        self.image5View.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[4].weather?[0].icon ?? String()))@4x.png")
        
        self.temp1Label.text = String(Int(round((self.offerModel?.list?[0].main?.temp ?? Double())))) + "°"
        self.temp2Label.text = String(Int(round((self.offerModel?.list?[1].main?.temp ?? Double())))) + "°"
        self.temp3Label.text = String(Int(round((self.offerModel?.list?[2].main?.temp ?? Double())))) + "°"
        self.temp4Label.text = String(Int(round((self.offerModel?.list?[3].main?.temp ?? Double())))) + "°"
        self.temp5Label.text = String(Int(round((self.offerModel?.list?[4].main?.temp ?? Double())))) + "°"
    }
    
    private func weatherByDay() {
        self.dataDay1Label.formatterDateDay((self.offerModel?.list?[0].dt_txt ?? String()), (self.offerModel?.city?.timezone ?? Int()))
        self.dataDay2Label.formatterDateDay((self.offerModel?.list?[8].dt_txt ?? String()), (self.offerModel?.city?.timezone ?? Int()))
        self.dataDay3Label.formatterDateDay((self.offerModel?.list?[16].dt_txt ?? String()), (self.offerModel?.city?.timezone ?? Int()))
        self.dataDay4Label.formatterDateDay((self.offerModel?.list?[24].dt_txt ?? String()), (self.offerModel?.city?.timezone ?? Int()))
        self.dataDay5Label.formatterDateDay((self.offerModel?.list?[32].dt_txt ?? String()), (self.offerModel?.city?.timezone ?? Int()))
        
        self.day1ImageView.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[0].weather?[0].icon ?? String()))@4x.png")
        self.day2ImageView.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[8].weather?[0].icon ?? String()))@4x.png")
        self.day3ImageView.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[16].weather?[0].icon ?? String()))@4x.png")
        self.day4ImageView.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[24].weather?[0].icon ?? String()))@4x.png")
        self.day5ImageView.downloaded(from: "https://openweathermap.org/img/wn/\((self.offerModel?.list?[32].weather?[0].icon ?? String()))@4x.png")
        
        self.tempDay1Label.text = String(Int(round((self.offerModel?.list?[0].main?.temp ?? Double())))) + "°"
        self.tempDay2Label.text = String(Int(round((self.offerModel?.list?[8].main?.temp ?? Double())))) + "°"
        self.tempDay3Label.text = String(Int(round((self.offerModel?.list?[16].main?.temp ?? Double())))) + "°"
        self.tempDay4Label.text = String(Int(round((self.offerModel?.list?[24].main?.temp ?? Double())))) + "°"
        self.tempDay5Label.text = String(Int(round((self.offerModel?.list?[32].main?.temp ?? Double())))) + "°"
    }
    
    private func hiddenView() {
        self.cityLabel.isHidden = false
        self.tempLabel.isHidden = false
        self.descriptionlabel.isHidden = false
        self.time1Label.isHidden = false
        self.time2Label.isHidden = false
        self.time3Label.isHidden = false
        self.time4Label.isHidden = false
        self.time5Label.isHidden = false
        
        self.imageView.isHidden = false
        self.image1View.isHidden = false
        self.image2View.isHidden = false
        self.image3View.isHidden = false
        self.image4View.isHidden = false
        self.image5View.isHidden = false
        
        self.temp1Label.isHidden = false
        self.temp2Label.isHidden = false
        self.temp3Label.isHidden = false
        self.temp4Label.isHidden = false
        self.temp5Label.isHidden = false
        
        self.dataDay1Label.isHidden = false
        self.dataDay2Label.isHidden = false
        self.dataDay3Label.isHidden = false
        self.dataDay4Label.isHidden = false
        self.dataDay5Label.isHidden = false
        
        self.day1ImageView.isHidden = false
        self.day2ImageView.isHidden = false
        self.day3ImageView.isHidden = false
        self.day4ImageView.isHidden = false
        self.day5ImageView.isHidden = false
        
        self.tempDay1Label.isHidden = false
        self.tempDay2Label.isHidden = false
        self.tempDay3Label.isHidden = false
        self.tempDay4Label.isHidden = false
        self.tempDay5Label.isHidden = false
        
        self.humidityLabel.isHidden = false
        self.windLabel.isHidden = false
        self.pressureLabel.isHidden = false
        self.fellLabel.isHidden = false
        
        self.humidityNameLabel.isHidden = false
        self.windNameLabel.isHidden = false
        self.pressureNameLabel.isHidden = false
        self.fellNameLabel.isHidden = false
        
        self.blurDayView.isHidden = false
        self.blurTimeView.isHidden = false
    }
}

//MARK: - extension
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        let index = indexPath.row as Int
        cell.textLabel?.text = autoComlete[index]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.autoComlete.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath) else {
            return
        }
        searchController.searchBar.text = selectedCell.textLabel?.text
        tableView.isHidden = true
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        tableView.isHidden = false
        if let substring = (searchController.searchBar.text as? NSString)?.replacingCharacters(in: range, with: text) {
            searchAutocomleteEntriesWithSubstring(substring)
            self.blurView.alpha = 1
        }
        return true
    }
}

extension UILabel {
    func formatterDate( _ dateString: String, _ timeZone: Int) {
        let dateString = dateString
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: timeZone)
        
        if let date = formatter.date(from: dateString) {
            
            let format = DateFormatter()
            format.dateFormat = "HH:mm"
            self.text = format.string(from: date)
        }
    }
    
    func formatterDateDay( _ dateString: String, _ timeZone: Int) {
        let dateString = dateString
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: timeZone)
        
        if let date = formatter.date(from: dateString) {
            
            let format = DateFormatter()
            format.locale = Locale(identifier: "ru_RU")
            format.dateFormat = "EEEE, d"
            self.text = format.string(from: date)
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension UIView {
    func radius (_ radius: Int = 20) {
        self.layer.cornerRadius = CGFloat(radius)
    }
}




