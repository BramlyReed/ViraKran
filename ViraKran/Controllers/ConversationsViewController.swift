//
//  ConversationsViewController.swift
//  ViraKran
//
//  Created by Stanislav on 01.03.2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ConversationsViewController: UIViewController {
    
    let db = Firestore.firestore()
    var usersNameBD: [String] = []
    var latestMessages: [LatestMessage] = []
    let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(openSearchConversationViewController))
        tableView.delegate = self
        tableView.dataSource = self
        getAllChatsByAdmin()
        tableView.isHidden = false
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    @objc func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: открыть поисковой экран
    @objc private func openSearchConversationViewController() {
        let vc = SearchConversationViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    //MARK: добавление наблюдателя за коллекцией users, чтобы получить список пользователей
    func getAllChatsByAdmin() {
        db.collection("users").addSnapshotListener{(querySnapshot, error) in guard querySnapshot != nil else { return }
            self.usersNameBD = []
            for document in (querySnapshot!.documents){
                let userLogin = String(document.documentID)
                if userLogin != "admin@gmail.com"{
                    self.usersNameBD.append(userLogin)
                }
            }
            self.updateConversations()
        }
    }
    //MARK: обновить ячейки с чатами. Добавление наблюдателей за коллекцией conversation для каждого пользователя из массива с именами пользователей
    func updateConversations() {
        if self.usersNameBD.count != 0{
            for userName in self.usersNameBD {
            db.collection("users/\(userName)/conversations").addSnapshotListener{(querySnapshot, error) in guard querySnapshot != nil else { return }
                for document in (querySnapshot!.documents){
                    let documentName = String(document.documentID)
                    if documentName == "lastMessage"{
    //MARK: данные из найденного документа lastMessage с последним сообщением из чата отправляется на добавление в массив с последними сообщениями из чатов
                        let documents_data = document.data()
                        let FirebaseDate = documents_data["date"] as! Timestamp
                        let message = documents_data["message"] as? String ?? "nil"
                        let epocTime = TimeInterval(FirebaseDate.seconds)
                        let date = NSDate(timeIntervalSince1970: epocTime)
                        let tmpObject = LatestMessage(date: date as Date, message: message, conversationNameOwner: userName)
                        self.updateArray(model: tmpObject)
                    }
                }
            }
        }
    }
    }
    func updateArray(model: LatestMessage){
        if self.latestMessages.count == 0{
            self.latestMessages.append(model)
        }
        else{
            var i: Int = 0
            var flag: Bool = false
            for message in self.latestMessages{
    //MARK: перезапись нового последнего сообщения в массив с последними сообщениями от пользователя, чье сообщение уже было записано раньше, сравнение происходит по дате
                if message.conversationNameOwner == model.conversationNameOwner{
                    flag = true
                    break
                }
                i = i + 1
                
            }
            if flag == true{
                if self.latestMessages[i].date != model.date{
                    self.latestMessages[i] = model
                }
            }
            else{
                self.latestMessages.append(model)
            }
        }
        self.latestMessages = self.latestMessages.sorted(by: { $0.date > $1.date })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.latestMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        if self.latestMessages.count != 0{
            cell.configure(with: self.latestMessages[indexPath.item])
        }
        return cell
    }
    //MARK: открытие чата с выбранным пользователем
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController()
        let tmpValue = latestMessages[indexPath.item].conversationNameOwner
        UserDefaults.standard.set(tmpValue, forKey: "chosenUser")
        vc.title = tmpValue
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
