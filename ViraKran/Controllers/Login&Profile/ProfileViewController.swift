//
//  ProfileViewController.swift
//  ViraKran
//
//  Created by Stanislav on 01.03.2021.
//

import UIKit
import FirebaseFirestore
import SDWebImage
class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let db = Firestore.firestore()
    let tableview: UITableView = {
        let table = UITableView()
        table.register(ProfileTableViewCellImage.nib(), forCellReuseIdentifier: ProfileTableViewCellImage.identifier)
        table.register(ProfileTableViewCellName.self, forCellReuseIdentifier:ProfileTableViewCellName.identifier)
        table.separatorStyle = .none
        return table
    }()
    var name = UserDefaults.standard.string(forKey: "fullname") ?? "Guest"
    var email = UserDefaults.standard.string(forKey: "email") ?? "Guest"
    let isAdminOpenFromChats = UserDefaults.standard.string(forKey: "isAdminOpenFromChats") ?? "false"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableview)
        tableview.dataSource = self
        tableview.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeController))
        if isAdminOpenFromChats == "true"{
            email = UserDefaults.standard.string(forKey: "chosenUser") ?? "Guest"
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
        
    //MARK: Настройка каждой из ячеек таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0{
            let cell = tableview.dequeueReusableCell(withIdentifier: ProfileTableViewCellImage.identifier, for: indexPath) as! ProfileTableViewCellImage
            if isAdminOpenFromChats == "false"{
                let pictureURL = UserDefaults.standard.string(forKey: "pictureURL") ?? "Guest1"
                print("New picture ", pictureURL)
                cell.configure(with: pictureURL)
            }
            else{
                StorageManager.shared.downloadURL(for: email, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        cell.configure(with: "\(url)")
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }
            return cell
        }
        if indexPath.item == 1{
            let cell = tableview.dequeueReusableCell(withIdentifier: ProfileTableViewCellName.identifier, for: indexPath) as! ProfileTableViewCellName
            cell.textLabel?.font.withSize(20.0)
            if isAdminOpenFromChats == "false"{
                cell.textLabel?.text = "Имя: \(name)"
            }
            else{
                let docRef = db.collection("users").document(email)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let name = data!["name"] as? String ?? "Guest"
                        let surname = data!["surname"] as? String ?? "Guest"
                        cell.textLabel?.text = "Имя: \(name) \(surname)"
                    } else {
                        print("Document does not exist")
                    }
                }
            }
            return cell
        }
        if indexPath.item == 2{
            let cell = tableview.dequeueReusableCell(withIdentifier: ProfileTableViewCellName.identifier, for: indexPath) as! ProfileTableViewCellName
            cell.textLabel?.font.withSize(20.0)
            cell.textLabel?.text = "email: \(email)"
            return cell
        }
        let value = UserDefaults.standard.string(forKey: "value") ?? "Guest"
        let cell = tableview.dequeueReusableCell(withIdentifier: ProfileTableViewCellName.identifier, for: indexPath) as! ProfileTableViewCellName
        if isAdminOpenFromChats != "true"{
            cell.textLabel?.text = "Тип валюты: \(value)"
        }
        else{
            cell.textLabel?.text = "Тип валюты:"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAdminOpenFromChats != "true"{
            if indexPath.item == 0{
                print("TRUE")
                presentPhotoActionSheet()
            }
            else if indexPath.item == 3{
                changeValue()
            }
        }
    }
    
    //MARK: Смена типа валюты
    func changeValue(){
        let actionSheet = UIAlertController(title: "Валюта", message: "Какую выбрать валюту?", preferredStyle: .actionSheet)
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
        UserDefaults.standard.set("false", forKey: "isAdminOpenFromChats")
        self.dismiss(animated: true, completion: nil)
    }

}
//MARK: Работа с изображением: выбор из галерии или из камеры
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Изображение профиля", message: "Откуда выбрать изображение?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Сделать снимок", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Выбрать изображение", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    //MARK: Перезапись нового изображения профиля на место старого по тому же имени
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let data = selectedImage.pngData() else { return }
        let filename = "\(email).profile_picture.png"
        StorageManager.shared.uploadPicture(with: data, fileName: filename, userName: email, completion: { result in
                switch result {
                case .success(let downloadUrl):
                    UserDefaults.standard.set("\(downloadUrl)", forKey: "pictureURL")
                    print("Download ",downloadUrl)
                    self.updateTable()
                
                case .failure(let error):
                    print("Storage manager error: \(error)")
                }
            })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    //MARK: обновление таблицы и отправка уведомления в HamburgerViewController
    func updateTable(){
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFullData"), object: nil)
    }
}
