//
//  News.swift
//  ViraKran
//
//  Created by Stanislav on 08.02.2021.
//

import Foundation

protocol DocumentSerializable{
    init?(dictionary: [String: Any])
}
struct NewsModel{
    public var date: Date?
    //var image_links: [String: String?]
    public var text_string: String?
    public var title: String?

    public var dictionary: [String: Any?]{
        return [
        "date": date,
        //"imageLinks": image_links,
        "text_string": text_string,
        "title": title
        ]
    }
}
extension NewsModel: DocumentSerializable{
    init?(dictionary: [String: Any]){
        guard let date = dictionary["date"] as? Date,
              let title = dictionary["title"] as? String,
              let text_string = dictionary["text_string"] as? String
              //let image_links = dictionary["imageLinks"] as? [String: String]
        else {return nil}
        print(text_string)
        self.init(date: date, text_string: text_string, title: title)
    }
}

