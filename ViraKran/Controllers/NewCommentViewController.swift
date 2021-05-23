//
//  NewCommentUIViewController.swift
//  ViraKran
//
//  Created by Stanislav on 22.05.2021.
//

import UIKit
import FirebaseFirestore

class NewCommentViewController: UIViewController {


    @IBOutlet weak var textView: UITextView!
    let database = Firestore.firestore()
    let products = ["avtokran", "bashkran", "bustrokran", "podkran"]
    let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"

    override func viewDidLoad() {
        super.viewDidLoad()
        print("OpenCommentController")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(SendComment))
       
        
    }
    
    @objc func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func SendComment() {
        if textView.text != ""{
            let chcatId = products[Int(chosenCatId)! - 1]
            let choseneqId = UserDefaults.standard.string(forKey: "eqId") ?? "Guest1"
            let userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"

            self.database.collection("equipment/\(chcatId)/items/\(choseneqId)/comments").addDocument(data:[
                "useremail": userLogin,
                "date": Date(),
                "comment": textView.text!
            ])
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                }
                else{
                    self.textView.text = ""
                    self.dismiss(animated: true, completion: nil)
                }
            }
        
        }
    }
}
