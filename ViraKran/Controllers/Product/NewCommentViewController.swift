//
//  NewCommentUIViewController.swift
//  ViraKran
//
//  Created by Stanislav on 22.05.2021.
//

import UIKit
import FirebaseFirestore

class NewCommentViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    let database = Firestore.firestore()
    let products = ["avtokran", "bashkran", "bustrokran", "podkran"]
    let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(SendComment))
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        addTapGestureToHideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    // MARK: Keyboard
    //remove notifications when controller's out
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        tapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGesture)
    }
    @objc func kbWillShow(notification: Notification){
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else {return}
        if keyboardSize.height >= 230{
            textView.contentInset.bottom = keyboardSize.height + 75.0
        }
        else if keyboardSize.height >= 220{
            textView.contentInset.bottom = keyboardSize.height + 55.0
        }
        else{
            textView.contentInset.bottom = keyboardSize.height + 40.0
        }
    }
    @objc func kbWillHide(notification: Notification){
        textView.contentInset.bottom = .zero
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

