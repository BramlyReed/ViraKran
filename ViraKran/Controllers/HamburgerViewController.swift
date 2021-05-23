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
import CardSlider
import RealmSwift
class HamburgerViewController: UIViewController, CardSliderDataSource, UIGestureRecognizerDelegate {
    func item(for index: Int) -> CardSliderItem {
        return data[index]

    }
    
    func numberOfItems() -> Int {
        return data.count

    }
    

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var logOutButton: UIButton!
    var data = [Item]()
    var aView: UIView?
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.borderWidth = 3
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.yellow.cgColor
        
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(updateFullName), name: NSNotification.Name(rawValue: "updateFullName"), object: nil)
        self.fullNameLabel.text = UserDefaults.standard.string(forKey: "fullname") ?? "Guest"
        var pictureURL = UserDefaults.standard.string(forKey: "pictureURL") ?? "Guest1"
        if pictureURL != "Guest1"{
            pictureURL = pictureURL.replacingOccurrences(of: "@", with: "%40")
            //print(pictureURL)
            let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .fill)
            self.profileImage.sd_setImage(with: URL(string: pictureURL), placeholderImage: nil, context: [.imageTransformer: transformer])
        }
        data.append(Item(image: UIImage(named: "colorful kran")!,
                         rating: nil,
                         title: "Краны",
                         subtitle: "Маленькие краны",
                         description: "Описание совета"))
        data.append(Item(image: UIImage(named: "colorful kran")!,
                         rating: nil,
                         title: "Краны",
                         subtitle: "Маленькие краны",
                         description: "Описание совета"))
        data.append(Item(image: UIImage(named: "colorful kran")!,
                         rating: nil,
                         title: "Краны",
                         subtitle: "Маленькие краны",
                         description: "Описание совета"))
        data.append(Item(image: UIImage(named: "colorful kran")!,
                         rating: nil,
                         title: "Краны",
                         subtitle: "Маленькие краны",
                         description: "Описание совета"))
    }
    
    @objc func updateFullName(){
        self.fullNameLabel.text = UserDefaults.standard.string(forKey: "fullname") ?? "Guest1"
        //let ZictureURL = UserDefaults.standard.string(forKey: "pictureURL") ?? "Guest"
        //print("--------")
        let email = UserDefaults.standard.string(forKey: "email") ?? "Guest1"

        var pictureURL = UserDefaults.standard.string(forKey: "pictureURL") ?? "Guest1"
        
        StorageManager.shared.downloadURL(for: email, completion: { [weak self] result in
            switch result {
            case .success(let url):
                //self?.pictures.append(url)
                print("success")
                DispatchQueue.main.async {
                    UserDefaults.standard.set("\(url)", forKey: "pictureURL")
                    print("Ypur picture URL ", url)
                    pictureURL = "\(url)".replacingOccurrences(of: "@", with: "%40")
                    let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .fill)
                    self!.profileImage.sd_setImage(with: URL(string: pictureURL), placeholderImage: nil, context: [.imageTransformer: transformer])
                }
                
            case .failure(let error):
                print("The Error")
                print("\(error)")
            }
        })
        
        

    }
    
    @IBAction func showProfileViewController(_ sender: Any) {
        print("show Profile View Controller")
        let vc = ProfileViewController()
        vc.title = "Ваш профиль"
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav,animated:true)
    }
    
    // MARK:Show chat or conversations

    @IBAction func showConversation(_ sender: Any) {
        let userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        
        if userLogin == "admin@gmail.com"{
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
    
    // MARK:Open useful tips

        @IBAction func didTapButton(){
            guard let dataSource = self as? CardSliderDataSource else{
                return
            }
            let vc = CardSliderViewController.with(dataSource: self)
            vc.dataSource = self
            vc.title = "Welcome!"
            vc.modalPresentationStyle = .fullScreen
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(closeChatViewController))
            recognizer.numberOfTapsRequired = 2
            recognizer.delegate = self
            vc.view.addGestureRecognizer(recognizer)
            present(vc,animated: true)
            }
    
    @objc func closeChatViewController() {
        print("CLOSE")
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:Log out from account
    
    @IBAction func logOut(_ sender: Any) {
        do{
            try FirebaseAuth.Auth.auth().signOut()
            let objects = self.realm.objects(FavoriteEquipment.self)
            if objects.count != 0{
                try! self.realm.write {
                    self.realm.delete(objects)
                }
            }
            print("Success")
            self.fullNameLabel.text = "Guest"
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "fullname")
            UserDefaults.standard.removeObject(forKey: "chosenUser")
            UserDefaults.standard.removeObject(forKey: "pictureURL")
            self.profileImage.image = UIImage(named:"guest_image")
            
        }
        catch{
            print("Can't sign out!")
        }
    }
    @IBAction func testButton(_ sender: Any){
        self.showSpinner()
        self.removeSpinner()
    }
    
    @IBAction func favoriteButton(_ sender: Any) {
        let userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        if userLogin == "Guest"{
            showAlert(message: "Войдите в свой аккаунт")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
}

extension HamburgerViewController {
    func showSpinner(){
        print("startSpinner")
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView(style: .large)
        ai.center = aView!.center
        ai.startAnimating()
        aView?.addSubview(ai)
        self.view.addSubview(aView!)
    }
    func removeSpinner(){
        print("RemoveSpinner")
        aView?.removeFromSuperview()
        aView = nil
    }
}
