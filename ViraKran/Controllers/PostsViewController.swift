//
//  PostsViewController.swift
//  ViraKran
//
//  Created by Stanislav on 22.05.2021.
//

import UIKit
import JJFloatingActionButton
import FirebaseFirestore
import SDWebImage

class PostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var db: Firestore!
    var actionButton = JJFloatingActionButton()
    var comments: [Comment] = []
    let userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
    var pictures: [URL] = []
    var pictureDictionary: [String:URL] = [:]
    let products = ["avtokran", "bashkran", "bustrokran", "podkran"]
    let tableview: UITableView = {
        let table = UITableView()
        table.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        return table
    }()
    let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.checkComments()
        let item1 = actionButton.addItem()
        item1.titleLabel.text = "Отправить"
//        item1.imageView.image = UIImage(named: "phone")
        item1.action = { item in
            self.openNewCommentViewController()
        }
        view.addSubview(tableview)
        tableview.dataSource = self
        tableview.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeController))
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tmpName = self.comments[indexPath.item].userName
        let cell = tableview.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        if (self.pictureDictionary[tmpName] != nil) {
            let cellIndex = comments[indexPath.item].userName
            cell.configure(img: pictureDictionary[cellIndex]!, usrN: comments[indexPath.item].userName, date: "\(comments[indexPath.item].dateSent)", com: comments[indexPath.item].comment)
        }
        else{
            cell.configure(img: comments[indexPath.item].profileImage!, usrN: comments[indexPath.item].userName, date: "\(comments[indexPath.item].dateSent)", com: comments[indexPath.item].comment)
        }
        return cell
    }
    
    @objc func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: открыть контролер с добавлением нового комментария
    func openNewCommentViewController() {
        if userLogin != "Guest"{
        let mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "NewCommentViewController") as! NewCommentViewController
            let navigationController = UINavigationController(rootViewController: newViewcontroller)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
        }
    }
    //MARK: добавление наблюдателя за коллекцией с комментариями пользователей к технике
    func checkComments(){
        let chcatId = products[Int(chosenCatId)! - 1]
        let choseneqId = UserDefaults.standard.string(forKey: "eqId") ?? "Guest1"
        db.collection("equipment/\(chcatId)/items/\(choseneqId)/comments").addSnapshotListener{(querySnapshot, error) in
            guard querySnapshot != nil else {
                print("Error")
                return
            }
            self.comments = []
            self.pictureDictionary = [:]
            for document in (querySnapshot!.documents){
                let documents_data = document.data()
                let username = documents_data["useremail"] as? String ?? "nil"
                let FirebaseDate = documents_data["date"] as! Timestamp
                let comment = documents_data["comment"] as? String ?? "nil"
                let epocTime = TimeInterval(FirebaseDate.seconds)
                let date = NSDate(timeIntervalSince1970: epocTime)
                let imageName = URL(string: "nil")
                self.comments.append(Comment(profileImage: imageName, userName: username, dateSent: date as Date, comment: comment))
//MARK: скачивание ссылки на изображение профиля пользователя, добавление данных в словарь
                StorageManager.shared.downloadURL(for: username, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.pictureDictionary["\(username)"] = url
                        DispatchQueue.main.async {
                            self!.tableview.reloadData()
                        }
                    case .failure(let error):
                        print("The Error: \(error)")
                    }
                })
            }
            //self.comments = self.comments.sorted(by: { $0.dateSent > $1.dateSent })
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
    }
}

}
