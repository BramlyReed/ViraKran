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
    override func viewDidLoad() {
        super.viewDidLoad()
        //DatabaseManager.shared.test()
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
            print(pictureURL)
            let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .fill)
            self.profileImage.sd_setImage(with: URL(string: pictureURL), placeholderImage: nil, context: [.imageTransformer: transformer])
            //self.profileImage.sd_setImage(with: URL(string: pictureURL))
            //self.profileImage.image?.resizeImageWith(newSize: 500.0)
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
        print("--------")
        let email = UserDefaults.standard.string(forKey: "email") ?? "Guest1"
        Storage.storage().reference().child("userImages/\(email)/\(email).profile_picture.png").downloadURL(completion: { url, error in
            guard let url = url else {
                print("Failed to get download url")
                return
            }
            UserDefaults.standard.set("\(url)", forKey: "pictureURL")
            print(url)
        }
    )
        //print(url)

        var pictureURL = UserDefaults.standard.string(forKey: "pictureURL") ?? "Guest1"
        pictureURL = pictureURL.replacingOccurrences(of: "@", with: "%40")
        print(pictureURL)
        let transformer = SDImageResizingTransformer(size: CGSize(width: 500, height: 500), scaleMode: .fill)
        self.profileImage.sd_setImage(with: URL(string: pictureURL), placeholderImage: nil, context: [.imageTransformer: transformer])

    }
    
    @IBAction func showProfileViewController(_ sender: Any) {
        print("show Profile View Controller")
    }
    
    
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
    
//    @IBAction func showEquipmentCards(_ sender: Any){
//        let vc = EquipmentsViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav,animated:true)
//    }
    
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
    
    @IBAction func logOut(_ sender: Any) {
        do{
            try FirebaseAuth.Auth.auth().signOut()
            print("Success")
            self.fullNameLabel.text = "Guest"
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "fullname")
            UserDefaults.standard.removeObject(forKey: "chosenUser")

        }
        catch{
            print("Can't sign out!")
        }
    }
    
}
