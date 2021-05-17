//
//  ConversationsViewController.swift
//  ViraKran
//
//  Created by Stanislav on 01.03.2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import JGProgressHUD
class ConversationsViewController: UIViewController {
    
    let db = Firestore.firestore()
    var usersNameBD: [String] = []
    let spinner = JGProgressHUD (style: .dark)
    let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeConversationsViewController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        setupTableView()
        fetchConversations()
        getAllChatsByAdmin()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    @objc func closeConversationsViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func didTapComposeButton() {
        let vc = NewConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    func showAlert(message: String) {
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    func fetchConversations() {
        tableView.isHidden = false
    }
    
    func getAllChatsByAdmin() {
        db.collection("users").addSnapshotListener{(querySnapshot, error) in guard querySnapshot != nil else { return }
            self.usersNameBD = []
            for document in (querySnapshot!.documents){
                let userLogin = String(document.documentID)
                if userLogin != "admin@gmail.com"{
                    self.usersNameBD.append(userLogin)
                    DispatchQueue.main.async {
                    self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersNameBD.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.textLabel?.text = usersNameBD[indexPath.item]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userName = UserDefaults.standard.string(forKey: "fullname") ?? "Guest"
        print(userName)
        let vc = ChatViewController()
        
        let tmpValue = usersNameBD[indexPath.item]
        print(tmpValue)
        UserDefaults.standard.set(tmpValue, forKey: "chosenUser")
        vc.title = tmpValue
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
//        vc.navigationItem.largeTitleDisplayMode = .never
//        navigationController?.pushViewController(vc, animated: true)
    }
}
