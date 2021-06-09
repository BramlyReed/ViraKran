//
//  Currencies.swift
//  ViraKran
//
//  Created by Stanislav on 26.05.2021.
//

import Foundation
import RealmSwift

struct Rates: Codable {
    var GBP: Double
    var USD: Double
    var EUR: Double
}

struct ParsedCurrencies: Codable {
    var rates: Rates
}

