//
//  News.swift
//  ViraKran
//
//  Created by Stanislav on 08.02.2021.
//

import Foundation

protocol DocumentSerializable{
    init?(date: Date, image_links: [String:String],text_string: String, title: String)
}
struct NewsModel{
    var date: Date?
    var image_links: [String: String?]
    var text_string: String?
    var title: String?

}
extension NewsModel: DocumentSerializable { 
    init?(date: Date, image_links: [String:String], text_string: String, title: String){
        guard let date =  date as? Date,
              let title = title as? String,
              let text_string = text_string as? String,
              let image_links = image_links as? [String: String]
        else {
            print("Doesn't work!")
            return nil
        }
        self.init(date: date, image_links: image_links, text_string: text_string, title: title)
    }
}

