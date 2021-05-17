//
//  AuthorizationViewController.swift
//  ViraKran
//
//  Created by Stanislav on 02.03.2021.
//

import UIKit

import FirebaseAuth
import Firebase
import FirebaseFirestore
import FirebaseDatabase
//import RealmSwift

class AuthorizationViewController: UIViewController {
    var db: Firestore!
    var sign = false
    var userData: UserModel?

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var loginfield: UITextField!
    @IBOutlet weak var passwordfield: UITextField!
    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var surnamefield: UITextField!
    @IBOutlet weak var haveregistr: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        imageProfile.isUserInteractionEnabled = true
        //imageProfile.layer.borderWidth = 3
        imageProfile.layer.masksToBounds = false
        //imageProfile.layer.borderColor = UIColor.yellow.cgColor
        imageProfile.layer.cornerRadius = imageProfile.frame.height/2
        imageProfile.clipsToBounds = true
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(pictureSelector))
        imageProfile.addGestureRecognizer(gesture)
        signInMode()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if  touches.first != nil{
                view.endEditing(true)
            }
            super.touchesBegan(touches, with: event)
        }
    @objc func closeAuthorizationViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeForm(_ sender: Any) {
        print("TAPPED")
        sign.toggle()
        if sign{ signUpMode() }
        else{ signInMode() }
    }
    func signInMode() {
        //self.topConstraint.constant = 200.0
        imageProfile.isHidden = true
        namefield.isHidden = true
        surnamefield.isHidden = true
        haveregistr.setTitle("Зарегистрироваться", for: .normal)
    }
    func signUpMode() {
        //self.topConstraint.constant = 200.0
        imageProfile.isHidden = false
        namefield.isHidden = false
        surnamefield.isHidden = false
        haveregistr.setTitle("Уже зарегистрированы?", for: .normal)
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @IBAction func SIGNIN(_ sender: Any) {
        let name = namefield.text!
        let surname = surnamefield.text!
        let email = loginfield.text!
        let password = passwordfield.text!
        
        if sign == true {
            if name.isEmpty || email.isEmpty || password.isEmpty || surname.isEmpty {
                showAlert(message: "Все поля должны быть заполнены")
            }
            else {
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult, error in
                    guard let strongSelf = self else {
                        return
                    }
                    guard authResult != nil, (error == nil) else {
                        return self!.showAlert(message:"Ошибка при создании пользователя, поменяйте логин и/или пароль")
                    }
                    let user = UserModel(name: name, surname: surname, email: email)
                    DatabaseManager.shared.insertUser(with: user)
                    
                    // upload image
                    guard let image = strongSelf.imageProfile.image,
                          let data = image.pngData() else {
                        return
                    }
                    let filename = user.profilePictureFileName
                    UserDefaults.standard.set("defaultPicture", forKey: "profile_picture_url")
                    StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, userName: email, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                //print(downloadUrl)
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        })
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set("\(name) \(surname)", forKey: "fullname")
                    self?.navigationController?.popToRootViewController(animated: true)

                })
            }
        }
        else {
            if email.isEmpty || password.isEmpty {
                showAlert(message: "Все поля должны быть заполнены")
            } else {
                FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
                    guard let strongSelf = self else {
                        return
                    }
                    guard authResult != nil, (error == nil) else {
                        return self!.showAlert(message: "Неправильный логин и/или пароль")
                    }
                    //let pictureURL = StorageManager.shared
                    let docRef = self?.db.collection("users").document(email)
                    docRef?.getDocument { (document, error) in
                        if let document = document, document.exists {
                            guard let docdata = document.data() else {return}
                            let name = docdata["name"] as? String ?? "nil"
                            let surname = docdata["surname"] as? String ?? "nil"
                            let email = docdata["email"] as? String ?? "nil"
                            let fullname: String = "\(name) \(surname)"
                            print(fullname)
                            UserDefaults.standard.set(email, forKey: "email")
                            UserDefaults.standard.set(fullname, forKey: "fullname")
                            
//                            Storage.storage().reference().child("userImages/\(email)/\(email).profile_picture.png").downloadURL(completion: { url, error in
//                                guard let url = url else {
//                                    print("Failed to get download url")
//                                    return
//                                }
//                                UserDefaults.standard.set(url, forKey: "pictureURL")
//                                //print(url)
//                            }
//                        )
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFullName"), object: nil)
                            

                        } else {
                            print("Document does not exist")
                        }
                    }
                    self?.navigationController?.popToRootViewController(animated: true)

                })
            }
        }
    }
    @objc func pictureSelector() {
        print("Change picture called")
        presentPhotoActionSheet()
    }
    
}

extension AuthorizationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.imageProfile.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}
