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
import FirebaseStorage
import RealmSwift

final class DatabaseManager{
    static let shared = DatabaseManager()
    let database = Firestore.firestore()
    let storage = Storage.storage().reference()
    var ref: DocumentReference? = nil
    let realm = try! Realm()
    let db = Firestore.firestore()
    var usersNameBD: [String] = []

    //MARK: запись данных пользователя в Firebase и отправка приветственного сообщения
    func insertUser(with user: UserModel) {
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
                    "message": "Здравствуйте! Я представитель компании Вира Кран, и, в этом чате, я готов ответить на все ваши вопросы",
                    "user_email": "admin@gmail.com",
                    "type": "text"
                ])
            }
        }
    }
    //MARK: добавление наблюдателя за каталогом техники
    func checkForUpdatesOfRest(){
//        let names = ["avtokran", "bashkran", "bustrokran", "podkran"]
        let names = ["avtokran", "bashkran"]
        
        for i in names{
        db.collection("equipment/\(i)/items").addSnapshotListener{(querySnapshot, error) in
            guard querySnapshot != nil else { return }
            var tmpCatId = "0"
            if i == "avtokran"{
                tmpCatId = "1"
            }
            else if i == "bashkran"{
                tmpCatId = "2"
            }
            else if i == "bustrokran"{
                tmpCatId = "3"
            }
            else if i == "podkran"{
                tmpCatId = "4"
            }
            let object = self.realm.objects(Equipment.self).filter("catId == %@", tmpCatId)
            if object.count != 0{
                try! self.realm.write {
                    self.realm.delete(object)
                }
            }
            for document in (querySnapshot!.documents){
                let documents_data = document.data()
                let eqId = documents_data["eqId"] as? Int ?? 0
                let catId = documents_data["catId"] as? Int ?? 0
                let cost = documents_data["cost"] as? Double ?? 0
                let eqCharacteristic: [String:String] = documents_data["eqChar"] as? [String:String] ?? ["nil":"nil"]
                let imageLinks: [String] = documents_data["imageLinks"] as? [String] ?? ["nil"]
                let textInfo = documents_data["textInfo"] as? String ?? "nil"
                let title = documents_data["title"] as? String ?? "nil"
                let year = documents_data["year"] as? Int ?? 0
                self.insertEquipment(eqid: eqId, catid: catId, imageStorage: imageLinks, textInfo: textInfo, title: title, cost: cost, year: year, eq_char: eqCharacteristic)
                }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateCategoryList"), object: nil)
            print("Sent Notification")
            }
        }

    }
    //MARK: запись новости в БД
    func insertNewsModel(date: Date, imageStorage: [String], text_string: String, title: String){
        let tmpObject = NewsModel()
        tmpObject.date = date
        tmpObject.text_string = text_string
        tmpObject.title = title
        //print("Image Storage")
        //print(imageStorage)
        if imageStorage.count != 0{
            for i in imageStorage{
                let tmplink = imageLinksClass()
                tmplink.link = i
                tmpObject.image_links.append(tmplink)
            }
        }
        try! realm.write{
            realm.add(tmpObject)
            print("Success")
        }
    }
    //MARK: запись техники в БД

    func insertEquipment(eqid: Int, catid: Int, imageStorage: [String], textInfo: String, title: String, cost: Double, year: Int, eq_char: [String:String]){
        let tmpObject = Equipment()
        tmpObject.eqId = String(eqid)
        tmpObject.catId = String(catid)
        tmpObject.textInfo = textInfo
        tmpObject.title = title
        tmpObject.cost = String(cost)
        tmpObject.year = String(year)
        for i in imageStorage{
            let tmplink = imageLinksClass()
            tmplink.link = i
            tmpObject.image_links.append(tmplink)
        }
        for i in eq_char{
            let tmpchar = eqChar()
            tmpchar.stringKey = i.key
            tmpchar.stringValue = i.value
            tmpObject.eqCharacteristic.append(tmpchar)
        }
        try! realm.write{
            realm.add(tmpObject)
            print("Zuccess")
        }
    }
    
}
