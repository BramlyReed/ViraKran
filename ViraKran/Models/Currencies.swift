//
//  Currencies.swift
//  ViraKran
//
//  Created by Stanislav on 26.05.2021.
//

import Foundation
import RealmSwift

struct RatesExample: Codable {
    var GBP: Double
    var USD: Double
    var EUR: Double
}

struct ParsedCurrencies: Codable {
    var rates: RatesExample
}

class Currencies: Object{
    let CurrenciesArray = List<Currency>()
}
class Currency: Object{
    @objc dynamic var name = ""
    @objc dynamic var value = ""
}
