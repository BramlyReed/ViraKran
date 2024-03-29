//
//  ViewController.swift
//  ViraKran
//
//  Created by Stanislav on 06.02.2021.
//

import UIKit
import Firebase
import FirebaseFirestore
import RealmSwift

class MainController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var db: Firestore!
    var NewsArray = [NewsModel]()
    var isSlideMenuShown = false
    let realm = try! Realm()
    var listener: ListenerRegistration?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leadingConstrForSlideMenu: NSLayoutConstraint!
    @IBOutlet weak var SlideMenu: UIView!
    @IBOutlet weak var backgroundForSlideMenu: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        tableView.dataSource = self
        tableView.delegate = self
        db = Firestore.firestore()
        getFromRealmData()
        DatabaseManager.shared.checkForUpdatesOfRest(i: 0)
        DatabaseManager.shared.removeListener()
        DatabaseManager.shared.checkForUpdatesOfRest(i: 1)
        DatabaseManager.shared.removeListener()
        DatabaseManager.shared.checkForUpdatesOfRest(i: 2)
        DatabaseManager.shared.removeListener()
        DatabaseManager.shared.checkForUpdatesOfRest(i: 3)
        DatabaseManager.shared.removeListener()
        DatabaseManager.shared.getInfoAboutCurrencies()
        self.backgroundForSlideMenu.isHidden = true
        self.SlideMenu.isHidden = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGesture)
    }
    //MARK: Запрос данных из Realm (если нет соединения, то будут отображены сохраненные данные
    func getFromRealmData(){
        let objects = realm.objects(NewsModel.self)
        if objects.count != 0{
            self.NewsArray.removeAll()
            for item in objects{
                self.NewsArray.append(item)
            }
            self.NewsArray = self.NewsArray.sorted(by: { $0.date > $1.date })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForUpdates()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    func setupNavigationBar(){
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    
    //MARK: Добавление наблюдателя за коллекцией news, получение данных документов из коллекции
    func checkForUpdates(){
        listener = db.collection("news").addSnapshotListener{[weak self] (querySnapshot, error) in
            guard querySnapshot != nil else { return }
            self!.NewsArray.removeAll()
            let object = self!.realm.objects(NewsModel.self)
            try! self!.realm.write {
                self!.realm.delete(object)
            }
            for document in (querySnapshot!.documents){
                let documents_data = document.data()
                let id = document.documentID
                let title = documents_data["title"] as? String ?? "nil"
//MARK: Работа с timestamp из Firebase
                let FirebaseDate = documents_data["date"] as! Timestamp
                let text_string = documents_data["text_string"] as? String ?? "nil"
                let imageLinks: [String] = documents_data["imageLinks"] as? [String] ?? ["nil"]
                let epocTime = TimeInterval(FirebaseDate.seconds)
                let date = NSDate(timeIntervalSince1970: epocTime)
                
//MARK: Добавление объекта в Realm
                DatabaseManager.shared.insertNewsModel(id: id, date: date as Date, imageStorage: imageLinks, text_string: text_string, title: title)
                }
            self!.getFromRealmData()
            DispatchQueue.main.async {
                self!.tableView.reloadData()
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
        UserDefaults.standard.set("\(NewsArray[indexPath.item].id)", forKey: "chosenNewsId")
        let mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "NewsPageViewController") as! NewsPageViewController
        let navigationController = UINavigationController(rootViewController: newViewcontroller)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
    }
    //MARK: боковое меню
    @IBAction func showSlideMenu(_ sender: Any) {
        if (isSlideMenuShown == false){
            UIView.animate(withDuration: 0.25) {
                self.leadingConstrForSlideMenu.constant = 0
                self.view.layoutIfNeeded()
            }
            self.navigationItem.titleView?.isHidden = true
            self.SlideMenu.isHidden = false
            self.backgroundForSlideMenu.isHidden = false
            self.backgroundForSlideMenu.alpha = 0.35
            self.isSlideMenuShown = true
        }
        else{
            hideSlideMenu((Any).self)
        }
    }
    @IBAction func hideSlideMenu(_ sender: Any) {
    if (isSlideMenuShown == true){
        self.backgroundForSlideMenu.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.leadingConstrForSlideMenu.constant = -240
            self.view.layoutIfNeeded()
        }
        isSlideMenuShown = false
        self.navigationItem.titleView?.isHidden = false
        self.backgroundForSlideMenu.isHidden = true
        self.isSlideMenuShown = false
        }
    }
    //MARK: открыть экран с регистрацией/авторизацией
    @IBAction func didTapRegistration(_ sender: Any) {
        let userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        if userLogin != "Guest"{
            showAlert(message: "Вы уже авторизовались в системе")
        }
        
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    //MARK: открытие бокового меню и чатов по свайпам
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed{
            let translation = sender.translation(in: self.view).x
            if translation > 0 { //swipe right
                if leadingConstrForSlideMenu.constant < 20 {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.leadingConstrForSlideMenu.constant += translation / 10
                        self.view.layoutIfNeeded()
                    })
                    self.navigationItem.titleView?.isHidden = true
                    self.SlideMenu.isHidden = false
                    self.backgroundForSlideMenu.isHidden = false
                    self.backgroundForSlideMenu.alpha = 0.35
                    self.isSlideMenuShown = true
                }
            }
            else{//swipe left
                if leadingConstrForSlideMenu.constant > -240 {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.leadingConstrForSlideMenu.constant += translation / 10
                        self.view.layoutIfNeeded()
                    })
                    isSlideMenuShown = false
                    self.navigationItem.titleView?.isHidden = false
                    self.backgroundForSlideMenu.isHidden = true
                    self.isSlideMenuShown = false
                }
            }
        }
        else if sender.state == .ended{
            if leadingConstrForSlideMenu.constant < -150 {
                UIView.animate(withDuration: 0.1, animations: {
                    self.leadingConstrForSlideMenu.constant = -240
                    self.view.layoutIfNeeded()
                })
                
                isSlideMenuShown = false
                                self.navigationItem.titleView?.isHidden = false
                                self.backgroundForSlideMenu.isHidden = true
                                self.isSlideMenuShown = false
                
            }
            else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.leadingConstrForSlideMenu.constant = 0
                    self.view.layoutIfNeeded()
                })
                self.navigationItem.titleView?.isHidden = true
                                self.SlideMenu.isHidden = false
                                self.backgroundForSlideMenu.isHidden = false
                                self.backgroundForSlideMenu.alpha = 0.35
                                self.isSlideMenuShown = true
            }
        }
    }
}
