//
//  ChatViewController.swift
//  ViraKran
//
//  Created by Stanislav on 16.03.2021.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView
import FirebaseFirestore
class ChatViewController: MessagesViewController {

    let db = Firestore.firestore()
    var messages = [Message]()
    var selfSender: SenderType?
    var otherSender: SenderType?
    var userLogin = ""
    var photoURL = "https://firebasestorage.googleapis.com/v0/b/vira-kran.appspot.com/o/userImages%2Fnew@gmail.com%2Fnew@gmail.com.profile_picture.png?alt=media&token=5d870651-8d89-4539-91ce-d8c4f3dc7f19"
    var chosenUserLogin = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        chosenUserLogin = UserDefaults.standard.string(forKey: "chosenUser") ?? "Guest"
        print(userLogin)
        messageInputBar.delegate = self
        if userLogin != "admin@gmail.com"{
            print("I'm not Admin")
            selfSender = Sender(photoURL: photoURL, senderId: "2", displayName: userLogin)
            otherSender = Sender(photoURL: photoURL, senderId: "1", displayName: "Администратор")
            getAllMessagesByUser(userLogin: userLogin)
        }
        else{
            print("I'm Admin")
            selfSender = Sender(photoURL: "", senderId: "1", displayName: "Администратор")
            otherSender = Sender(photoURL: "", senderId: "2", displayName: chosenUserLogin)
            getAllMessagesByUser(userLogin: chosenUserLogin)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeChatViewController))
        

        view.backgroundColor = .black
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if  touches.first != nil{
                view.endEditing(true)
            }
            super.touchesBegan(touches, with: event)
    }
    @objc func closeChatViewController() {
        print("CLOSE")
        self.messages = []
        self.messagesCollectionView.reloadData()
        userLogin = ""
        chosenUserLogin = ""
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChatViewController{
    func getAllMessagesByUser(userLogin: String){
        self.messages = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        print(userLogin)
        db.collection("users/\(userLogin)/conversations").addSnapshotListener{(querySnapshot, error) in guard querySnapshot != nil else { return }
            self.messages = []
            for document in (querySnapshot!.documents){
                let documents_data = document.data()
                let messageID = String(document.documentID)
                let FirebaseDate = documents_data["date"] as! Timestamp
                print(FirebaseDate.seconds)
                let epocTime = TimeInterval(FirebaseDate.seconds)
                let date = NSDate(timeIntervalSince1970: epocTime)
                let type = documents_data["type"] as? String ?? nil
                let textMessage = documents_data["message"] as? String ?? "nil"
                var kind: MessageKind = .text("nil")
                if type == "text"{
                    kind = .text(textMessage)
                }
                else if type == "image"{
                    
                }
                print(date)
                let user_email = documents_data["user_email"] as? String ?? "nil"
                if (user_email == "admin@gmail.com" && self.selfSender?.displayName == "Администратор") || (user_email != "admin@gmail.com" && self.selfSender?.displayName != "Администратор"){
                    self.messages.append(Message(sender: self.selfSender!, messageId: messageID, sentDate: date as Date, kind: kind))

                }
                else if (user_email != "admin@gmail.com" && self.selfSender?.displayName == "Администратор") || (user_email == "admin@gmail.com" && self.selfSender?.displayName != "Администратор"){
                    self.messages.append(Message(sender: self.otherSender!, messageId: messageID, sentDate: date as Date, kind: kind))

                }
            }
            if self.messages.count != 0{
            self.messages = self.messages.sorted(by: { Int($0.messageId)! < Int($1.messageId)! })
            }
            print(self.messages)
            self.messagesCollectionView.reloadData()
        }
    }
}
    
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate,InputBarAccessoryViewDelegate{
    func currentSender() -> SenderType {
        return selfSender!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String){

        var USER = ""
        if userLogin == "admin@gmail.com"{
            USER = chosenUserLogin
        }
        else{
            USER = userLogin
        }
        let NumberMessage = Int(self.messages.last!.messageId)! + 1
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        let dateString = Date.init()
        db.collection("users/\(USER)/conversations").document(String(NumberMessage)).setData([
                "date": dateString,
                "message": text,
                "type": "text",
                "user_email": userLogin
            ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                
            } else {
                print("Document successfully written!")
                inputBar.inputTextView.text = ""
                
            }
        }
    }
}

