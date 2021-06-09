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
    var listener: ListenerRegistration?
    var listener1: ListenerRegistration?
    var listener2: ListenerRegistration?
    var listener3: ListenerRegistration?
    var usersNameBD: [String] = []
    let names = ["avtokran", "bashkran", "bustrokran", "podkran"]

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
                let firstMessage = "Здравствуйте! Я представитель компании Вира Кран, и, в этом чате, я готов ответить на все ваши вопросы"
                self.database.collection("users/\(user.email)/conversations").document("1").setData([
                    "date": dateString,
                    "message": firstMessage,
                    "user_email": "vira-kran74@mail.ru",
                    "type": "text"
                ])
                self.database.collection("users/\(user.email)/conversations").document("lastMessage").setData([
                    "date": dateString,
                    "message": firstMessage
                ])
            }
        }
    }
    //MARK: добавление наблюдателя за каталогом техники
    func checkForUpdatesOfRest(i:Int){
        listener = db.collection("equipment/\(names[i])/items").addSnapshotListener{ [weak self] (querySnapshot, error) in
            guard querySnapshot != nil else { return }
            self?.deleteDataWithCatId(i: i)
            for document in (querySnapshot!.documents){
                let documents_data = document.data()
                let eqId = document.documentID as String
                self?.serializationDataOfEquipment(documents_data: documents_data, eqId: eqId)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateCategoryList"), object: nil)
            }
        }
    }
    func checkForUpdatesOfRestOptional1(i:Int){
        listener1 = db.collection("equipment/\(names[i])/items").addSnapshotListener{ [weak self] (querySnapshot, error) in
            guard querySnapshot != nil else { return }
            self?.deleteDataWithCatId(i: i)
            for document in (querySnapshot!.documents){
                let documents_data = document.data()
                let eqId = document.documentID as String
                self?.serializationDataOfEquipment(documents_data: documents_data, eqId: eqId)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateCategoryList"), object: nil)
            }
        }
    }
    func checkForUpdatesOfRestOptional2(i:Int){
        listener2 = db.collection("equipment/\(names[i])/items").addSnapshotListener{ [weak self] (querySnapshot, error) in
            guard querySnapshot != nil else { return }
            self?.deleteDataWithCatId(i: i)
            for document in (querySnapshot!.documents){
                let documents_data = document.data()
                let eqId = document.documentID as String
                self?.serializationDataOfEquipment(documents_data: documents_data, eqId: eqId)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateCategoryList"), object: nil)
            }
        }
    }
    func checkForUpdatesOfRestOptional3(i:Int){
        listener3 = db.collection("equipment/\(names[i])/items").addSnapshotListener{ [weak self] (querySnapshot, error) in
            guard querySnapshot != nil else { return }
            self?.deleteDataWithCatId(i: i)
            for document in (querySnapshot!.documents){
                let documents_data = document.data()
                let eqId = document.documentID as String
                self?.serializationDataOfEquipment(documents_data: documents_data, eqId: eqId)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateCategoryList"), object: nil)
            }
        }
    }
    //MARK: удаление данных из каталога по категориям
    func deleteDataWithCatId(i:Int){
        var tmpCatId = "0"
        if self.names[i] == "avtokran"{
            tmpCatId = "1"
        }
        else if self.names[i] == "bashkran"{
            tmpCatId = "2"
        }
        else if self.names[i] == "bustrokran"{
            tmpCatId = "3"
        }
        else if self.names[i] == "podkran"{
            tmpCatId = "4"
        }
        let object = self.realm.objects(Equipment.self).filter("catId == %@", tmpCatId)
        if object.count != 0{
            try! self.realm.write {
                self.realm.delete(object)
            }
        }
    }
    //MARK: обработка полученных данных
    func serializationDataOfEquipment(documents_data: [String: Any], eqId: String){
        let catId = documents_data["catId"] as? Int ?? 0
        let cost = documents_data["cost"] as? Double ?? 0
        let eqCharacteristic: [String:String] = documents_data["eqChar"] as? [String:String] ?? ["nil":"nil"]
        let imageLinks: [String] = documents_data["imageLinks"] as? [String] ?? ["nil"]
        let textInfo = documents_data["textInfo"] as? String ?? "nil"
        let title = documents_data["title"] as? String ?? "nil"
        let year = documents_data["year"] as? Int ?? 0
        let location = documents_data["location"] as? String ?? "nil"
        self.insertEquipment(eqid: eqId, catid: catId, imageStorage: imageLinks, textInfo: textInfo, title: title, cost: cost, year: year, eq_char: eqCharacteristic, location: location)
    
    }
    
    //MARK: запись новости в БД
    func insertNewsModel(id: String, date: Date, imageStorage: [String], text_string: String, title: String){
        let tmpObject = NewsModel()
        tmpObject.id = id
        tmpObject.date = date
        tmpObject.text_string = text_string
        tmpObject.title = title
        if imageStorage.count != 0{
            for i in imageStorage{
                let tmplink = imageLinksClass()
                tmplink.link = i
                tmpObject.image_links.append(tmplink)
            }
        }
        try! realm.write{
            realm.add(tmpObject)
        }
    }
    
    //MARK: запись техники в БД
    func insertEquipment(eqid: String, catid: Int, imageStorage: [String], textInfo: String, title: String, cost: Double, year: Int, eq_char: [String:String], location: String){
        let tmpObject = Equipment()
        tmpObject.eqId = String(eqid)
        tmpObject.catId = String(catid)
        tmpObject.textInfo = textInfo
        tmpObject.title = title
        tmpObject.cost = String(cost)
        tmpObject.year = String(year)
        tmpObject.location = String(location)
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
        }
    }
    
    //MARK: Получение данных о пользователе
    func getDataOfUser(useremail: String) -> UserModel{
        var tmpUser = UserModel(name: "", surname: "", email: "")
        
        let docRef = db.collection("users").document(useremail)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let documents_data = document.data()
                tmpUser.name = documents_data!["name"] as? String ?? ""
                tmpUser.email = documents_data!["surname"] as? String ?? ""
                tmpUser.surname = documents_data!["email"] as? String ?? ""
            } else {
                print("Document does not exist")
            }
        }
        return tmpUser
    }
    
    //MARK: Получение информации о валютах
    func getInfoAboutCurrencies(){
        guard let url = URL(string: "https://www.cbr-xml-daily.ru/latest.js") else { return}
        var currenciesRatesArray = RatesExample(GBP: 0, USD: 0, EUR: 0)
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if
                let data = data,
                let parsedCurrencies = try? JSONDecoder().decode(ParsedCurrencies.self, from: data){
                currenciesRatesArray = parsedCurrencies.rates
                let realm = try! Realm()
                let object = realm.objects(Currencies.self)
                if object.count != 0{
                    try! realm.write {
                        realm.delete(object)
                    }
                }
                let tmpObject = Currencies()
                let tmpEuro = Currency()
                let tmpUSD = Currency()
                let tmpGBP = Currency()
                tmpEuro.name = "EUR"
                tmpEuro.value = "\(currenciesRatesArray.EUR)"
                tmpObject.CurrenciesArray.append(tmpEuro)
                tmpUSD.name = "USD"
                tmpUSD.value = "\(currenciesRatesArray.USD)"
                tmpObject.CurrenciesArray.append(tmpUSD)
                tmpGBP.name = "GBP"
                tmpGBP.value = "\(currenciesRatesArray.GBP)"
                tmpObject.CurrenciesArray.append(tmpGBP)
                try! realm.write{
                    realm.add(tmpObject)
                }
                }
            else{
                print("Can't get rates")
            }
        }.resume()
    }
    
    func getActual(rates: String) -> Double{
        let object = realm.objects(Currencies.self)
        if object.count != 0{
            if rates == "EUR"{
                let tmp = Double(object.last?.CurrenciesArray[0].value ?? "0") ?? 0.0
                return tmp
            }
            else if rates == "USD"{
                let tmp = Double(object.last?.CurrenciesArray[1].value ?? "0") ?? 0.0
                return tmp
            }
            else{
                let tmp = Double(object.last?.CurrenciesArray[2].value ?? "0") ?? 0.0
                return tmp
            }
        }
        return 0.0
    }

    func removeListener() {
        listener?.remove()
        listener1?.remove()
        listener2?.remove()
        listener3?.remove()
    }
}
