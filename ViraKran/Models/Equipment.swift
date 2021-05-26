//
//  Equipment.swift
//  ViraKran
//
//  Created by Stanislav on 12.05.2021.
//

import Foundation
import UIKit
import RealmSwift

class Equipment: Object{
    @objc dynamic var eqId: String = ""
    @objc dynamic var catId: String = ""
    @objc dynamic var cost: String = ""
    let eqCharacteristic = List<eqChar>()
    let image_links = List<imageLinksClass>()
    @objc dynamic var textInfo = ""
    @objc dynamic var title = ""
    @objc dynamic var year: String = ""
    @objc dynamic var location: String = ""
}

class eqChar: Object {
    @objc dynamic var stringKey = ""
    @objc dynamic var stringValue = ""
}

class FavoriteEquipment: Object{
    @objc dynamic var eqId: String = ""
    @objc dynamic var catId: String = ""
}
