//
//  DatabaseManager.swift
//  ViraKran
//
//  Created by Stanislav on 13.03.2021.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseDatabase

final class DatabaseManager{
    static let shared = DatabaseManager()
    let database = Firestore.firestore()
    var ref: DocumentReference? = nil
    
    public func insertUser(with user: UserModel) {
        self.database.collection("users").document(user.email).setData([
            "name": "\(user.name)",
            "surname": "\(user.surname)",
            "email": "\(user.email)"
        ])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                let dateString = Date.init()
                self.database.collection("users/\(user.email)/conversations").document("1").setData([
                    "date": dateString,
                    "textMessage": "Здравствуйте! Я представитель компании Вира Кран, и, в этом чате, я готов ответить на все ваши вопросы",
                    "user_email": "admin@gmail.com"
                ])
            }
        }
    }
}
