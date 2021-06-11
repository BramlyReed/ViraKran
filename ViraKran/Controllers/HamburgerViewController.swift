//
//  HamburgerViewController.swift
//  ViraKran
//
//  Created by Stanislav on 25.02.2021.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import SDWebImage
import RealmSwift
class HamburgerViewController: UIViewController, UIGestureRecognizerDelegate {
  
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(updateFullData), name: NSNotification.Name(rawValue: "updateFullData"), object: nil)
        self.fullNameLabel.text = UserDefaults.standard.string(forKey: "fullname") ?? "Guest"
        var pictureURL = UserDefaults.standard.string(forKey: "pictureURL") ?? "Guest1"
        //MARK: Замена символа @ на %40 в строке с url, тк по первому варианту запрос не идет
        if pictureURL != "Guest1"{
            pictureURL = pictureURL.replacingOccurrences(of: "@", with: "%40")
            let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .fill)
            DispatchQueue.main.async {
                self.profileImage.sd_setImage(with: URL(string: pictureURL), placeholderImage: nil, context: [.imageTransformer: transformer])
            }
        }
    }
    
    //MARK: Обновление данных профиля, загрузка ссылки изображения профиля и сохранение в UserDefaults
    @objc func updateFullData(){
        self.fullNameLabel.text = UserDefaults.standard.string(forKey: "fullname") ?? "Guest1"
        let email = UserDefaults.standard.string(forKey: "email") ?? "Guest1"
        var pictureURL = UserDefaults.standard.string(forKey: "pictureURL") ?? "Guest1"
        StorageManager.shared.downloadURL(for: email, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    UserDefaults.standard.set("\(url)", forKey: "pictureURL")
                    pictureURL = "\(url)".replacingOccurrences(of: "@", with: "%40")
                    let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .fill)
                    self!.profileImage.sd_setImage(with: URL(string: pictureURL), placeholderImage: nil, context: [.imageTransformer: transformer])
                }
            case .failure(let error):
                print("The Error: \(error)")
            }
        })
    }
    //MARK: Открыть ProfileViewController
    @IBAction func showProfileViewController(_ sender: Any) {
        let vc = ProfileViewController()
        vc.title = "Ваш профиль"
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav,animated:true)
    }
    
    // MARK:Открыть чаты (если администратор) или чат (если обычный пользователь)

    @IBAction func showConversation(_ sender: Any) {
        let userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        
        if userLogin == "vira-kran74@mail.ru"{
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
    
    // MARK:Открыть ProfileViewController
    @IBAction func didTapButton(){
        
        showProfileViewController((Any).self)
    }
    
    @objc func closeChatViewController() {
        print("CLOSE1")
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:Выход из аккаунта и удаление всех персональных данных из UserDefaults и Real
    
    @IBAction func logOut(_ sender: Any) {
        do{
            try FirebaseAuth.Auth.auth().signOut()
            let objects = self.realm.objects(FavoriteEquipment.self)
            if objects.count != 0{
                try! self.realm.write {
                    self.realm.delete(objects)
                }
            }
            self.fullNameLabel.text = "Guest"
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "fullname")
            UserDefaults.standard.removeObject(forKey: "chosenUser")
            UserDefaults.standard.removeObject(forKey: "pictureURL")
            UserDefaults.standard.removeObject(forKey: "MyUID")
            self.profileImage.image = UIImage(named:"guest_image")
        }
        catch{
            showAlert(message: "Ошибка при выходе из аккаунта")
            print("Can't sign out!")
        }
    }
    //MARK: Открыть FavoriteViewController
    @IBAction func favoriteButton(_ sender: Any) {
        let userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        if userLogin == "Guest"{
            showAlert(message: "Войдите в свой аккаунт")
        }
        else{
            DatabaseManager.shared.checkForUpdatesOfRest(i: 0)
            DatabaseManager.shared.checkForUpdatesOfRestOptional1(i: 1)
            DatabaseManager.shared.checkForUpdatesOfRestOptional1(i: 2)
            DatabaseManager.shared.checkForUpdatesOfRestOptional1(i: 3)
            let mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "FavouriteController") as! FavoriteItemsViewController
            let navigationController = UINavigationController(rootViewController: newViewcontroller)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

