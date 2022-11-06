//
//  Constellations.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/10/29.
//

// 星座資料及月份
import Foundation

final class ConstellationsClass {
    struct ConstellationsType {
        let id: Int
        let name: String
        let beginDate: String
        let endDate: String
    }
    enum ConstellationsEnum: String {
        case Aries = "牡羊座"
        case Taurus = "金牛座"
        case Gemini = "雙子座"
        case Cancer = "巨蟹座"
        case Leo = "獅子座"
        case Virgo = "處女座"
        case Libra = "天秤座"
        case Scorpio = "天蠍座"
        case Sagittarius = "射手座"
        case Capricorn = "摩羯座"
        case Aquarius = "水瓶座"
        case Pisces = "雙魚座"
    }
    let allConstellationsArray: [ConstellationsType] = [
        ConstellationsType(id: 1, name: ConstellationsEnum.Aries.rawValue, beginDate: "3/21", endDate: "4/20"),
        ConstellationsType(id: 2, name: ConstellationsEnum.Taurus.rawValue, beginDate: "4/21", endDate: "5/21"),
        ConstellationsType(id: 3, name: ConstellationsEnum.Gemini.rawValue, beginDate: "5/22", endDate: "6/21"),
        ConstellationsType(id: 4, name: ConstellationsEnum.Cancer.rawValue, beginDate: "6/22", endDate: "7/22"),
        ConstellationsType(id: 5, name: ConstellationsEnum.Leo.rawValue, beginDate: "7/23", endDate: "8/22"),
        ConstellationsType(id: 6, name: ConstellationsEnum.Virgo.rawValue, beginDate: "8/23", endDate: "9/22"),
        ConstellationsType(id: 7, name: ConstellationsEnum.Libra.rawValue, beginDate: "9/23", endDate: "10/23"),
        ConstellationsType(id: 8, name: ConstellationsEnum.Scorpio.rawValue, beginDate: "10/24", endDate: "11/22"),
        ConstellationsType(id: 9, name: ConstellationsEnum.Sagittarius.rawValue, beginDate: "11/23", endDate: "12/21"),
        ConstellationsType(id: 10, name: ConstellationsEnum.Capricorn.rawValue, beginDate: "12/22", endDate: "1/20"),
        ConstellationsType(id: 11, name: ConstellationsEnum.Aquarius.rawValue, beginDate: "1/21", endDate: "2/18"),
        ConstellationsType(id: 12, name: ConstellationsEnum.Pisces.rawValue, beginDate: "2/19", endDate: "3/20"),
    ]
    
    func turnStringToDate(input: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        
        guard let dateOne = dateFormatter.date(from: input) else {
            return nil
        }
        return dateOne
    }
    
    func checkPersonConstellation(birth: Date) -> String {
        let count = allConstellationsArray.count
        for i in 0..<count {
            if let beginDate = turnStringToDate(input: allConstellationsArray[i].beginDate),
               let endDate = turnStringToDate(input: allConstellationsArray[i].endDate) {
                if beginDate <= birth,
                   endDate >= birth {
                    return allConstellationsArray[i].name
                }
            }
        }
        return " -- "
    }
}
