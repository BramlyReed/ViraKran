//
//  SearchConversationViewController.swift
//  ViraKran
//
//  Created by Stanislav on 01.03.2021.
//

import UIKit
import JGProgressHUD
import FirebaseFirestore
import SDWebImage

class SearchConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var usersNameBD: [String:String] = [:]
    var filteredData: [String] = []
    var latestMessages: [LatestMessage] = []
    let db = Firestore.firestore()

    let spinner = JGProgressHUD(style: .dark)
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Введите login пользователя"
        return searchBar
    }()
    let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "Ничего не найдено"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.latestMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        if self.latestMessages.count != 0{
            cell.configure(userLogin: self.latestMessages[indexPath.item].conversationNameOwner, message: self.latestMessages[indexPath.item].message)
        }
        return cell
    }
    //MARK: открытие чата с выбранным пользователем
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userName = UserDefaults.standard.string(forKey: "fullname") ?? "Guest"
        print(userName)
        let vc = ChatViewController()
        let tmpValue = latestMessages[indexPath.item].conversationNameOwner
        print(tmpValue)
        UserDefaults.standard.set(tmpValue, forKey: "chosenUser")
        vc.title = tmpValue
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func updateUI(){
        if latestMessages.count == 0 {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
        self.spinner.dismiss()
    }
}
extension SearchConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        spinner.show(in: view)
        searchUsers(query: text.lowercased())
    }
    
    //MARK: получение имен всех пользователей
    func searchUsers(query: String) {
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.usersNameBD.removeAll()
                self.filteredData.removeAll()
                for document in querySnapshot!.documents {
                    let uid = String(document.documentID)
                    let docdata = document.data()
                    let userLogin = docdata["email"] as? String ?? "nil"
                    if userLogin != "vira-kran74@mail.ru" && userLogin != "nil"{
                        self.usersNameBD["\(userLogin)"] = uid
                    }
                }
                self.filterUsers(with: query)
            }
        }
    }
    
    //MARK: фильтрация списка имен пользователей по префиксу, получение последних сообщений из чатов по пользователям из отфильтрованного списка
    func filterUsers(with term: String) {
        if usersNameBD.count != 0 {
            self.latestMessages.removeAll()
//            self.usersNameBD = self.usersNameBD.keys.filter{$0.hasPrefix(term)}
            for userName in usersNameBD{
                filteredData.append(userName.key)
            }
            self.filteredData = self.filteredData.filter{$0.hasPrefix(term)}
            if filteredData.count != 0{
                for value in filteredData{
                    let uid = self.usersNameBD[String(describing: value)] ?? "nil"
                    db.collection("users/\(uid)/conversations").document("lastMessage").getDocument { (document, error) in
                        if let document = document, document.exists {
                            let documents_data = document.data()
                            let FirebaseDate = documents_data!["date"] as! Timestamp
                            let message = documents_data!["message"] as? String ?? "nil"
                            let epocTime = TimeInterval(FirebaseDate.seconds)
                            let date = NSDate(timeIntervalSince1970: epocTime)
                            let tmpObject = LatestMessage(date: date as Date, message: message, conversationUIDOwner: uid, conversationNameOwner: value)
                            self.latestMessages.append(tmpObject)
                            self.updateUI()
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
            else{
                self.spinner.dismiss()
            }
        }
    }
}
