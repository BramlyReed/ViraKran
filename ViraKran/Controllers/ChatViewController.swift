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
import SDWebImage
class ChatViewController: MessagesViewController {

    let db = Firestore.firestore()
    var messages = [Message]()
    var selfSender: SenderType?
    var otherSender: SenderType?
    var userLogin = ""
    var photoURL = ""
    var chosenUserLogin = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        chosenUserLogin = UserDefaults.standard.string(forKey: "chosenUser") ?? "Guest"
        messageInputBar.delegate = self
    //MARK: настройка selfSender и otherSender
        if userLogin != "admin@gmail.com"{
            selfSender = Sender(photoURL: photoURL, senderId: "2", displayName: userLogin)
            otherSender = Sender(photoURL: photoURL, senderId: "1", displayName: "Администратор")
            getAllMessagesByUser(userLogin: userLogin)
        }
        else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Инфо",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(openProfileViewController))
            
            selfSender = Sender(photoURL: "", senderId: "1", displayName: "Администратор")
            otherSender = Sender(photoURL: "", senderId: "2", displayName: chosenUserLogin)
            getAllMessagesByUser(userLogin: chosenUserLogin)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeChatViewController))
        
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentPhotoActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
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
        self.messages = []
        self.messagesCollectionView.reloadData()
        userLogin = ""
        chosenUserLogin = ""
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: открыть профиль пользователя
    @objc func openProfileViewController(){
        UserDefaults.standard.set("true", forKey: "isAdminOpenFromChats")
        let vc = ProfileViewController()
        vc.title = chosenUserLogin
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav,animated:true)
    }
    
}

extension ChatViewController{
//MARK: получение всех сообщений (документов) из коллекции пользователя
    func getAllMessagesByUser(userLogin: String){
        self.messages = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        db.collection("users/\(userLogin)/conversations").addSnapshotListener{(querySnapshot, error) in guard querySnapshot != nil else { return }
        self.messages = []
        for document in (querySnapshot!.documents){
            let documents_data = document.data()
            let messageID = String(document.documentID)
            if messageID != "lastMessage" {
                let FirebaseDate = documents_data["date"] as! Timestamp
                let epocTime = TimeInterval(FirebaseDate.seconds)
                let date = NSDate(timeIntervalSince1970: epocTime)
                let type = documents_data["type"] as? String ?? nil
                let textMessage = documents_data["message"] as? String ?? "nil"
                var kind: MessageKind = .text("nil")
                if type == "text"{
                    kind = .text(textMessage)
                }
                else if type == "image"{
                    guard let url = URL(string: textMessage),
                        let placeholder = UIImage(systemName: "plus") else {
                            return
                    }
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 300.0, height: 300.0))
                    kind = .photo(media)
                }
                let user_email = documents_data["user_email"] as? String ?? "nil"
//MARK: настройка senderов сообщений для структуры Message
                if (user_email == "admin@gmail.com" && self.selfSender?.displayName == "Администратор") || (user_email != "admin@gmail.com" && self.selfSender?.displayName != "Администратор"){
                    self.messages.append(Message(sender: self.selfSender!, messageId: messageID, sentDate: date as Date, kind: kind))
                }
                else if (user_email != "admin@gmail.com" && self.selfSender?.displayName == "Администратор") || (user_email == "admin@gmail.com" && self.selfSender?.displayName != "Администратор"){
                    self.messages.append(Message(sender: self.otherSender!, messageId: messageID, sentDate: date as Date, kind: kind))
                }
            }
            if self.messages.count != 0{
//MARK: сортировка сообщений по id
            self.messages = self.messages.sorted(by: { Int($0.messageId)! < Int($1.messageId)! })
            }
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
//            if self.messages.count > 3{
//                self.messagesCollectionView.scrollToBottom()
//            }
        }
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
    //MARK: отправка сообщения в коллекцию с документами и запись его в качестве последнего сообщения
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
            ])
        db.collection("users/\(USER)/conversations").document("lastMessage").updateData([
                "date": dateString,
                "message": text
            ]){ err in
            if let err = err {
                print("Error writing document: \(err)")
                
            } else {
                print("Documents successfully written!")
                inputBar.inputTextView.text = ""
            }
        }
    }
    //MARK: настройка аватаров
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
    //MARK: Текущий пользователь
            let pictureURL = UserDefaults.standard.string(forKey: "pictureURL") ?? "Guest1"
            avatarView.sd_setImage(with: URL(string: pictureURL), completed: nil)
        }
        else {
    //MARK: Адресат переписки, скачивание ссылки на изображение профиля
            var email = chosenUserLogin
            //print("chosenUser ", chosenUserLogin)
            if chosenUserLogin == "Guest" || chosenUserLogin == ""{
                email = "admin@gmail.com"
            }
            StorageManager.shared.downloadURL(for: email, completion: { [weak self] result in
                switch result {
                case .success(let url):
                    DispatchQueue.main.async {
                        avatarView.sd_setImage(with: url, completed: nil)
                    }
                case .failure(let error):
                    print("\(error)")
                }
            })
        }
    }
    //MARK: настройка сообщений изображений
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let pictureURL = "\(imageUrl)".replacingOccurrences(of: "@", with: "%40")
            let transformer = SDImageResizingTransformer(size: CGSize(width: 300, height: 300), scaleMode: .fill)
            imageView.sd_setImage(with: URL(string: pictureURL), placeholderImage: nil, context: [.imageTransformer: transformer])
        default:
            break
        }
    }
}
//MARK: выбор изображений с камеры или галерии
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Изображение", message: "Откуда выбрать изображение?", preferredStyle: .actionSheet)
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
    //MARK: загрузка изображения в Storage, скачивание ссылки этого изображения
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        //print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let data = selectedImage.pngData() else { return }
        var email = ""
        if userLogin == "admin@gmail.com"{
            email = chosenUserLogin
        }
        else{
            email = userLogin
        }
        var NumberMessage = 0
        if messages.count != 0{
        NumberMessage = Int(self.messages.last!.messageId)! + 1
        }
        let filename = "photo_message_\(NumberMessage).png"
        let LoginSender = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, userName: email, completion: { result in
                switch result {
                case .success(let downloadUrl):
                    self.sendPhotoImage(USER: email, messageURL: downloadUrl, userLogin: LoginSender, type: "image")

                case .failure(let error):
                    print("Storage manager error: \(error)")
                }
            })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: запись данных о сообщении с изображением в коллекцию с чатом пользователя и в качестве последнего сообщения
    func sendPhotoImage(USER: String, messageURL: String, userLogin: String, type: String){
        let NumberMessage = Int(self.messages.last!.messageId)! + 1
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        let dateString = Date.init()
        db.collection("users/\(USER)/conversations").document(String(NumberMessage)).setData([
                "date": dateString,
                "message": messageURL,
                "type": type,
                "user_email": userLogin
            ])
        db.collection("users/\(USER)/conversations").document("lastMessage").updateData([
                "date": dateString,
                "message": messageURL
            ]){ err in
            if let err = err {
                print("Error writing document: \(err)")
                
            } else {
                print("Documents successfully written!")
            }
        }
    }
}
