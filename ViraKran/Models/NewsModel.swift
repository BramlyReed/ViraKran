//
//  News.swift
//  ViraKran
//
//  Created by Stanislav on 08.02.2021.
//

import Foundation
import RealmSwift

class NewsModel: Object{
    @objc dynamic var id = ""
    @objc dynamic var date = Date()
    let image_links = List<imageLinksClass>()
    @objc dynamic var text_string = ""
    @objc dynamic var title = ""
}

class imageLinksClass: Object {
    @objc dynamic var link = ""
}

