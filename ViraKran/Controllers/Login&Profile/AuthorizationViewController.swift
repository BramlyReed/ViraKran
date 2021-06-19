//
//  AuthorizationViewController.swift
//  ViraKran
//
//  Created by Stanislav on 02.03.2021.
//

import UIKit
import Photos
import FirebaseAuth
import Firebase
import FirebaseFirestore
import JGProgressHUD

class AuthorizationViewController: UIViewController {
    var db: Firestore!
    var sign = false
    var policy = false
    var checkBoxPlace = false
    var userData: UserModel?
    let spinner = JGProgressHUD(style: .dark)
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
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func kbWillShow(notification: Notification){
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else {return}
        scrollView.contentInset.bottom = keyboardSize.height
    }
    @objc func kbWillHide(notification: Notification){
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
        self.navigationItem.title = "Авторизация"
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
        self.navigationItem.title = "Регистрация"
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
    func showAlert(title: String, message: String) {
        self.spinner.dismiss()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @IBAction func SIGNIN(_ sender: Any) {
        let name = namefield.text!
        let surname = surnamefield.text!
        let email = loginfield.text!
        let password = passwordfield.text!
        
        if sign == true {
            self.navigationItem.title  = "Регистрация"
            // MARK: Регистрация
            if name.isEmpty || email.isEmpty || password.isEmpty || surname.isEmpty {
                showAlert(title: "Ошибка", message: "Все поля должны быть заполнены")
            }
            else {
                if checkBoxPlace != false{
                    self.spinner.show(in: view)
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult, error in
                    guard let strongSelf = self else {
                        return
                    }
                    guard authResult != nil, (error == nil) else {
                        return self!.showAlert(title: "Ошибка", message:"Ошибка при создании пользователя, поменяйте логин и/или пароль")
                    }
                    let uid = String(authResult?.user.uid ?? "0")
                    let user = UserModel(uid: uid, name: name, surname: surname, email: email)
                    DatabaseManager.shared.insertUser(with: user)
                    guard let image = strongSelf.imageProfile.image,
                          let data = image.pngData() else {
                        return
                    }
                    let filename = "\(user.email).profile_picture.png"
                    StorageManager.shared.uploadPicture(with: data, location: "usersProfileImages",fileName: filename, userName: email, completion: { result in
                            switch result {
                            case .success(_):
                                print("successful")
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        })
                    authResult?.user.sendEmailVerification{ (error) in
                        guard error != nil else{
                            self?.spinner.dismiss()
                            return print("send notification")
                        }
                    }
                    self?.namefield.text = ""
                    self?.surnamefield.text = ""
                    self?.loginfield.text = ""
                    self?.passwordfield.text = ""
                    self?.imageProfile.image = UIImage(named: "guest_image")
                    self?.showCheckBox()
                    self?.showAlert(title: "Уведомление", message:"Для использования учетной записи подтвердите аккаунт по ссылке из письма, отправленного по указанному email, затем войдите в свой аккаунт")
                })
            }
                else{
                    showAlert(title: "Ошибка", message: "Для регистрации необходимо принять соглашение")
                }
        }
        }
        else {
            self.navigationItem.title = "Авторизация"
            //MARK: Авторизация
            if email.isEmpty || password.isEmpty {
                showAlert(title: "Ошибка", message: "Все поля должны быть заполнены")
            } else {
                spinner.show(in: view)
                FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
                    guard self != nil else {
                        return
                    }
                    guard authResult != nil, (error == nil) else {
                        return self!.showAlert(title: "Ошибка", message: "Неправильный логин и/или пароль")
                    }
                    switch authResult?.user.isEmailVerified{
                    case true:
                        print("")
                    case false:
                        authResult?.user.sendEmailVerification{ (error) in
                            guard error != nil else{
                                return print("send notification")
                            }
                        }
                        return self!.showAlert(title: "Уведомление", message:"Для использования учетной записи подтвердите аккаунт по ссылке из письма, отправленного по указанному email, затем войдите в свой аккаунт")

                    case .none:
                        break
                    case .some(_):
                        break
                    }
                    let uid = String(authResult?.user.uid ?? "0")
                    let docRef = self?.db.collection("users").document(uid)
                    docRef?.getDocument { (document, error) in
                        if let document = document, document.exists {
                            guard let docdata = document.data() else {return}
                            let name = docdata["name"] as? String ?? "nil"
                            let surname = docdata["surname"] as? String ?? "nil"
                            let email = docdata["email"] as? String ?? "nil"
                            let fullname: String = "\(name) \(surname)"
                            UserDefaults.standard.set(email, forKey: "email")
                            UserDefaults.standard.set(fullname, forKey: "fullname")
                            UserDefaults.standard.set(uid, forKey: "MyUID")
                            UserDefaults.standard.set("Рубли", forKey: "value")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFullData"), object: nil)
                        }
                        else {
                            print("Document does not exist")
                        }
                    }
                    self?.spinner.dismiss()
                    self?.navigationController?.popToRootViewController(animated: true)
                })
            }
        }
    }
    @objc func pictureSelector() {
        presentPhotoActionSheet()
    }
    
    func changePassword(){
        if loginfield.text != ""{
            Auth.auth().sendPasswordReset(withEmail:loginfield.text!) { error in
                guard error != nil else{
                    return self.showAlert(title: "Уведомление", message: "На указанный email было выслано письмо со сбросом пароля")
                }
            }
        }
        else{
            showAlert(title: "Ошибка", message: "Введите email")
        }
    }
    
    func showPolicyTerms(){
        let myViewController = storyboard?.instantiateViewController(withIdentifier: "TextViewController") as? TextViewController
        let myNavigationController = UINavigationController(rootViewController: myViewController!)
        myNavigationController.modalPresentationStyle = .fullScreen
        self.present(myNavigationController, animated: true)
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
        self.checkPermissions()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.imageProfile.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func checkPermissions() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in ()
            })
        }

        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
            vc.delegate = self
            vc.allowsEditing = true
            present(vc, animated: true)
        } else {
            PHPhotoLibrary
                .requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
            vc.delegate = self
            vc.allowsEditing = true
            present(vc, animated: true)
        } else {
            DispatchQueue.main.async {
                self.showAlert(title: "Ошибка", message: "Нет доступа")
            }
        }
    }
}
