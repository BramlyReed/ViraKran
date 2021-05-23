//
//  ProfileViewController.swift
//  ViraKran
//
//  Created by Stanislav on 01.03.2021.
//

import UIKit
import SDWebImage
class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    let tableview: UITableView = {
        let table = UITableView()
        table.register(ProfileTableViewCellImage.nib(), forCellReuseIdentifier: ProfileTableViewCellImage.identifier)
        table.register(ProfileTableViewCellName.self, forCellReuseIdentifier:ProfileTableViewCellName.identifier)
        //table.register(ProfileTableViewCellValue.nib(), forCellReuseIdentifier: ProfileTableViewCellValue.identifier)
        return table
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableview)
        tableview.dataSource = self
        tableview.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeController))

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0{
            let cell = tableview.dequeueReusableCell(withIdentifier: ProfileTableViewCellImage.identifier, for: indexPath) as! ProfileTableViewCellImage
            let pictureURL = UserDefaults.standard.string(forKey: "pictureURL") ?? "Guest1"
            cell.configure(with: pictureURL)
            return cell
        }
        if indexPath.item == 1{
            let cell = tableview.dequeueReusableCell(withIdentifier: ProfileTableViewCellName.identifier, for: indexPath) as! ProfileTableViewCellName
            let name = UserDefaults.standard.string(forKey: "fullname") ?? "Guest"
            cell.textLabel?.font.withSize(20.0)
            cell.textLabel?.text = "Имя: \(name)"
            return cell
        }
        if indexPath.item == 2{
            let cell = tableview.dequeueReusableCell(withIdentifier: ProfileTableViewCellName.identifier, for: indexPath) as! ProfileTableViewCellName
            let email = UserDefaults.standard.string(forKey: "email") ?? "Guest"
            cell.textLabel?.font.withSize(20.0)
            cell.textLabel?.text = "email: \(email)"
            return cell
        }
        let value = UserDefaults.standard.string(forKey: "value") ?? "Guest"
        let cell = tableview.dequeueReusableCell(withIdentifier: ProfileTableViewCellName.identifier, for: indexPath) as! ProfileTableViewCellName
        cell.textLabel?.text = "Тип валюты: \(value)"
       
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 3{
            changeValue()
        }
    }
    
    func changeValue(){
        let actionSheet = UIAlertController(title: "Изображение профиля", message: "Откуда выбрать изображение?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Фунты", style: .default, handler: { [weak self] _ in
            self?.updateValue(value: "Фунты")
        }))
        actionSheet.addAction(UIAlertAction(title: "Евро", style: .default, handler: { [weak self] _ in
            self?.updateValue(value: "Евро")
        }))
        actionSheet.addAction(UIAlertAction(title: "Доллары", style: .default, handler: { [weak self] _ in
            self?.updateValue(value: "Доллары")
        }))
        actionSheet.addAction(UIAlertAction(title: "Рубли", style: .default, handler: { [weak self] _ in
            self?.updateValue(value: "Рубли")
        }))
        present(actionSheet, animated: true)
        
    }
    func updateValue(value: String){
        UserDefaults.standard.set(value, forKey: "value")
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
    
    @objc func closeController() {
        self.dismiss(animated: true, completion: nil)
    }

}

