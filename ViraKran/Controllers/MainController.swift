//
//  ViewController.swift
//  ViraKran
//
//  Created by Stanislav on 06.02.2021.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import RealmSwift

class MainController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var db: Firestore!
    var NewsArray = [NewsModel]()
    var isSlideMenuShown = false
    let realm = try! Realm()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leadingConstrForSlideMenu: NSLayoutConstraint!
    @IBOutlet weak var SlideMenu: UIView!
    @IBOutlet weak var backgroundForSlideMenu: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        db = Firestore.firestore()
        getFromRealmData()
        checkForUpdates()
        DatabaseManager.shared.checkForUpdatesOfRest()
        self.backgroundForSlideMenu.isHidden = true
        self.SlideMenu.isHidden = true
    }
    //MARK: Запрос данных из Realm (если нет соединения, то будут отображены сохраненные данные
    func getFromRealmData(){
        let objects = realm.objects(NewsModel.self)
        if objects.count != 0{
            self.NewsArray = []
            for item in objects{
                self.NewsArray.append(item)
            }
        }
    }
    
    //MARK: Добавление наблюдателя за коллекцией news, получение данных документов из коллекции
    func checkForUpdates(){
        db.collection("news").addSnapshotListener{(querySnapshot, error) in
            guard querySnapshot != nil else { return }
            self.NewsArray = []
            let object = self.realm.objects(NewsModel.self)
            try! self.realm.write {
                self.realm.delete(object)
            }
            for document in (querySnapshot!.documents){
                let documents_data = document.data()
                let title = documents_data["title"] as? String ?? "nil"
//MARK: Работа с timestamp из Firebase
                let FirebaseDate = documents_data["date"] as! Timestamp
                let text_string = documents_data["text_string"] as? String ?? "nil"
                let imageLinks: [String] = documents_data["imageLinks"] as? [String] ?? ["nil"]
                let epocTime = TimeInterval(FirebaseDate.seconds)
                let date = NSDate(timeIntervalSince1970: epocTime)
//MARK: Добавление объекта в Realm
                DatabaseManager.shared.insertNewsModel(date: date as Date, imageStorage: imageLinks, text_string: text_string, title: title)
                }
            self.getFromRealmData()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.NewsArray.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell
        let tmp = NewsArray[indexPath.item]
        let tmpImage = tmp.image_links[0].link
        cell?.setContent(title: tmp.title, text: tmp.text_string, imageLink: tmpImage, dateLabel: tmp.date)
        return cell!
    }
    //MARK: здесь будет переход на экран с выбранной новостью
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User touched on \(indexPath.item) row")
    }
    //MARK: боковое меню
    @IBAction func showSlideMenu(_ sender: Any) {
        if (isSlideMenuShown == false){
            UIView.animate(withDuration: 0.25) {
                self.leadingConstrForSlideMenu.constant = 0
                self.view.layoutIfNeeded()
            }
            self.SlideMenu.isHidden = false
            self.backgroundForSlideMenu.isHidden = false
            self.backgroundForSlideMenu.alpha = 0.35
            self.isSlideMenuShown = true
        }
    }
    @IBAction func hideSlideMenu(_ sender: Any) {
        print(isSlideMenuShown)
    if (isSlideMenuShown == true){
        print("true")
        isSlideMenuShown = false
        self.backgroundForSlideMenu.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.leadingConstrForSlideMenu.constant = -240
            self.view.layoutIfNeeded()
        }
        self.backgroundForSlideMenu.isHidden = true
        self.isSlideMenuShown = false
        }
    }
    //MARK: открыть экран с регистрацией/авторизацией
    @IBAction func didTapRegistration(_ sender: Any) {
        print("TAP")
        let userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        if userLogin != "Guest"{
            print("UserLogin")
            showAlert(message: "Вы уже авторизовались в системе")
        }
        
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    //MARK: открытие бокового меню и чатов по свайпам
    @IBAction func swipeToShowSlideMenu(_ sender: Any) {
        showSlideMenu((Any).self)
    }
    
    @IBAction func swipeToShowConversations(_ sender: Any) {
        print("SWIPE")
        let userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        print(userLogin)
        if userLogin == "admin@gmail.com"{
            let vc = ConversationsViewController()
            vc.title = "Чаты"
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav,animated:true)
        }
        else{
            let vc = ChatViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav,animated:true)
        }
    }
}
