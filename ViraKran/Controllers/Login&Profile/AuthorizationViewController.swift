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

class AuthorizationViewController: UIViewController {
    var db: Firestore!
    var sign = false
    var policy = false
    var checkBoxPlace = false
    var userData: UserModel?
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var loginfield: UITextField!
    @IBOutlet weak var passwordfield: UITextField!
    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var surnamefield: UITextField!
    @IBOutlet weak var haveregistr: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var policyLabel: UILabel!
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        imageProfile.isUserInteractionEnabled = true
        imageProfile.layer.masksToBounds = false
        imageProfile.layer.cornerRadius = imageProfile.frame.height/2
        imageProfile.clipsToBounds = true
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(pictureSelector))
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        addTapGestureToHideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        imageProfile.addGestureRecognizer(gesture)
        let gesture1 = UITapGestureRecognizer(target: self,
                                             action: #selector(policyTerms))
        policyLabel.addGestureRecognizer(gesture1)
        let gesture2 = UITapGestureRecognizer(target: self,
                                             action: #selector(showCheckBox))
        checkBox.addGestureRecognizer(gesture2)
        signInMode()
    }

    // MARK: Keyboard
    //remove notifications when controller's out
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func kbWillShow(notification: Notification){
        print("SHOW")
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else {return}
        scrollView.contentInset.bottom = keyboardSize.height
    }
    @objc func kbWillHide(notification: Notification){
        print("HIDE")
        scrollView.contentInset.bottom = .zero
    }
    
    @objc func policyTerms(){
        if policy == false{
            changePassword()
        }
        else{
            showPolicyTerms()
        }
    }
    @objc func showCheckBox(){
        checkBoxPlace.toggle()
        if checkBoxPlace == false{
            checkBox.image = UIImage(named: "checkboxFalse")
        }
        else{
            checkBox.image = UIImage(named: "checkboxTrue")
        }
    }
    
    @IBAction func changeForm(_ sender: Any) {
        sign.toggle()
        if sign{ signUpMode() }
        else{ signInMode() }
    }
    func signInMode() {
        self.topConstraint.constant = 80.0
        imageProfile.isHidden = true
        namefield.isHidden = true
        surnamefield.isHidden = true
        policy = false
        policyLabel.text = "Забыли пароль?"
        policyLabel.font.withSize(19.0)
        checkBox.isHidden = true
        haveregistr.setTitle("Зарегистрироваться", for: .normal)
    }
    func signUpMode() {
        self.topConstraint.constant = 361.0
        imageProfile.isHidden = false
        namefield.isHidden = false
        surnamefield.isHidden = false
        policy = true
        policyLabel.text = "Вы принимаете условия соглашения:"
        policyLabel.font.withSize(13.0)
        checkBox.isHidden = false
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
            // MARK: Регистрация
            if name.isEmpty || email.isEmpty || password.isEmpty || surname.isEmpty {
                showAlert(message: "Все поля должны быть заполнены")
            }
            else {
                if checkBoxPlace != false{
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult, error in
                    guard let strongSelf = self else {
                        return
                    }
                    guard authResult != nil, (error == nil) else {
                        return self!.showAlert(message:"Ошибка при создании пользователя, поменяйте логин и/или пароль")
                    }
                    let user = UserModel(name: name, surname: surname, email: email)
                    DatabaseManager.shared.insertUser(with: user)
                    guard let image = strongSelf.imageProfile.image,
                          let data = image.pngData() else {
                        return
                    }
                    let filename = "\(user.email).profile_picture.png"
//                    UserDefaults.standard.set(email, forKey: "email")
//                    UserDefaults.standard.set("\(name) \(surname)", forKey: "fullname")
//                    UserDefaults.standard.set("Рубли", forKey: "value")
                    StorageManager.shared.uploadPicture(with: data, fileName: filename, userName: email, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "pictureURL")
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFullData"), object: nil)
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        })
                    authResult?.user.sendEmailVerification{ (error) in
                        guard error != nil else{
                            return print("send notification")
                        }
                    }
                    self?.showAlert(message:"Для использования учетной записи подтвердите аккаунт по ссылке из письма, отправленного по указанному email, затем ввойдите в свой аккаунт")
                    self?.navigationController?.popToRootViewController(animated: true)
                })
            }
                else{
                    showAlert(message: "Для регистрации необходимо принять соглашение")
                }
            
        }
        }
        else {
            //MARK: Авторизация
            if email.isEmpty || password.isEmpty {
                showAlert(message: "Все поля должны быть заполнены")
            } else {
                FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
                    guard self != nil else {
                        return
                    }
                    guard authResult != nil, (error == nil) else {
                        return self!.showAlert(message: "Неправильный логин и/или пароль")
                    }
//
//                    switch authResult?.user.isEmailVerified{
//                    case true:
//                        print("")
//                    case false:
//                        authResult?.user.sendEmailVerification{ (error) in
//                            guard error != nil else{
//                                return print("send notification")
//                            }
//                        }
//                        return self!.showAlert(message:"Для использования учетной записи подтвердите аккаунт по ссылке из письма, отправленного по указанному email, затем ввойдите в свой аккаунт")
//
//                    case .none:
//                        break
//                    case .some(_):
//                        break
//                    }
                    
                    let docRef = self?.db.collection("users").document(email)
                    docRef?.getDocument { (document, error) in
                        if let document = document, document.exists {
                            guard let docdata = document.data() else {return}
                            let name = docdata["name"] as? String ?? "nil"
                            let surname = docdata["surname"] as? String ?? "nil"
                            let email = docdata["email"] as? String ?? "nil"
                            let fullname: String = "\(name) \(surname)"
                            UserDefaults.standard.set(email, forKey: "email")
                            UserDefaults.standard.set(fullname, forKey: "fullname")
                            UserDefaults.standard.set("Рубли", forKey: "value")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFullData"), object: nil)
                        }
                        else {
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
    
    func changePassword(){
        print("change password")
        if loginfield.text != ""{
            Auth.auth().sendPasswordReset(withEmail:loginfield.text!) { error in
                guard error != nil else{
                    return self.showAlert(message: "На указанный email было выслано письмо со сбросом пароля")
                }
            }
        }
        else{
            showAlert(message: "Введите email")
        }
    }
    
    func showPolicyTerms(){
        print("show policy")
    }
}
//MARK: Работа с изображением: выбор из галерии или из камеры
extension AuthorizationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Изображение профиля", message: "Откуда выбрать изображение?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Оставить изображение по умолчанию", style: .default, handler: { [weak self] _ in
            self?.dafaultImage()
        }))
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
    func dafaultImage() {
        imageProfile.image = UIImage(named: "guest_image")
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
        picker.dismiss(animated: true, completion: nil)
    }
}
