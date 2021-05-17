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

class MainController: UIViewController, UITableViewDataSource {
    var db: Firestore!
    var NewsArray = [NewsModel]()
    var isSlideMenuShown = false
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leadingConstrForSlideMenu: NSLayoutConstraint!
    @IBOutlet weak var SlideMenu: UIView!
    @IBOutlet weak var backgroundForSlideMenu: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        db = Firestore.firestore()
        checkForUpdates()
        self.backgroundForSlideMenu.isHidden = true
        //self.backgroundForSlideMenu.alpha = 0.0
        self.SlideMenu.isHidden = true
    }

    func checkForUpdates(){
        db.collection("news").addSnapshotListener{(querySnapshot, error) in
            guard querySnapshot != nil else { return }
                self.NewsArray = []
                for document in (querySnapshot!.documents){
                    let documents_data = document.data()
                    let title = documents_data["title"] as? String ?? "nil"
                    let date = documents_data["date"] as? Date ?? Date()
                    let text_string = documents_data["text_string"] as? String ?? "nil"
                    let imageLinks: [String:String] = documents_data["imageLinks"] as? [String:String] ?? ["0":"nil"]
                    self.NewsArray.append(NewsModel(date: date, image_links: imageLinks, text_string: text_string, title: title))
                    print(self.NewsArray.count)
                }
            DispatchQueue.main.async {    //обновлять данные скролл вью в будущем
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.NewsArray.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell
        let tmpcell = self.NewsArray[indexPath.item]
        cell?.setContent(title: (tmpcell.title)!, text: (tmpcell.text_string)!, imageLink: (tmpcell.image_links["1"]) as! String, dateLabel: (tmpcell.date)!)
        
        return cell!
    }
    
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
