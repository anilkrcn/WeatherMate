import Foundation

struct WeatherModel{
    let conditionId: Int
    let name: String
    let temperature: Double
    
    var temperatureString: String{
        return String(format: "%.1f", temperature)
    }
    
    var conditionName: String{
        switch conditionId {
        case 200...232:
            return "bolt"
        case 300...321:
            return "drizzle"
        case 500...531:
            return "rainy"
        case 600...622:
            return "snow"
        case 701...781:
            return "fog"
        case 800:
            return "fog"
        case 801...804:
            return "sun"
        default:
            return "rainy"
        }
    }
}
