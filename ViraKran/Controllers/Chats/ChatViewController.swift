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
    var listener: ListenerRegistration?
    var userLogin = ""
    var myUID = ""
    var photoURL = ""
    var chosenUserLogin = ""
    var chosenUserUID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        userLogin = UserDefaults.standard.string(forKey: "email") ?? "Guest"
        myUID = UserDefaults.standard.string(forKey: "MyUID") ?? "Guest"
        chosenUserLogin = UserDefaults.standard.string(forKey: "chosenUserLogin") ?? "Guest"
        chosenUserUID = UserDefaults.standard.string(forKey: "chosenUser") ?? "Guest"
        messageInputBar.delegate = self
    //MARK: настройка selfSender и otherSender
        if userLogin != "vira-kran74@mail.ru"{
            selfSender = Sender(photoURL: photoURL, senderId: "2", displayName: userLogin)
            otherSender = Sender(photoURL: photoURL, senderId: "1", displayName: "Администратор")
            getAllMessagesByUser(userUID: myUID)
        }
        else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Инфо",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(openProfileViewController))
            
            selfSender = Sender(photoURL: "", senderId: "1", displayName: "Администратор")
            otherSender = Sender(photoURL: "", senderId: "2", displayName: chosenUserLogin)
            getAllMessagesByUser(userUID: chosenUserUID)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeChatViewController))
        
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(named: "imageplane"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentPhotoActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.delegate = self
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTap))
        //messagesCollectionView.addGestureRecognizer(gesture)

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    @objc func didTap(){
        self.messageInputBar.inputTextView.resignFirstResponder()
    }
    @objc func closeChatViewController() {
        self.messages = []
        self.messagesCollectionView.reloadData()
        if listener != nil{
            listener!.remove()
        }
        UserDefaults.standard.removeObject(forKey: "chosenUser")
        UserDefaults.standard.removeObject(forKey: "chosenUserLogin")
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
    func openPhotoViewController(){
        let mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        let navigationController = UINavigationController(rootViewController: newViewcontroller)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
    }
}

extension ChatViewController{
//MARK: получение всех сообщений (документов) из коллекции пользователя по uid
    func getAllMessagesByUser(userUID: String){
        self.messages = []
        listener = db.collection("users/\(userUID)/conversations").addSnapshotListener{[weak self] (querySnapshot, error) in guard querySnapshot != nil else { return }
            self!.messages = []
            print("Fresh meat")
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
                        let placeholder = UIImage(named: "bashennuikran") else {
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
                if (user_email == "vira-kran74@mail.ru" && self!.selfSender?.displayName == "Администратор") || (user_email != "vira-kran74@mail.ru" && self!.selfSender?.displayName != "Администратор"){
                    self!.messages.append(Message(sender: self!.selfSender!, messageId: messageID, sentDate: date as Date, kind: kind))
                }
                else if (user_email != "vira-kran74@mail.ru" && self!.selfSender?.displayName == "Администратор") || (user_email == "vira-kran74@mail.ru" && self!.selfSender?.displayName != "Администратор"){
                    self!.messages.append(Message(sender: self!.otherSender!, messageId: messageID, sentDate: date as Date, kind: kind))
                }
            }
            if self!.messages.count != 0{
//MARK: сортировка сообщений по id
                self!.messages = self!.messages.sorted(by: { Int($0.messageId)! < Int($1.messageId)! })
            }
        }
        self!.messagesCollectionView.reloadData()
        self!.messagesCollectionView.scrollToLastItem()
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
        var UID = ""
        if userLogin == "vira-kran74@mail.ru"{
            UID = chosenUserUID
        }
        else{
            UID = myUID
        }
        let NumberMessage = Int(self.messages.last!.messageId)! + 1
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        let dateString = Date.init()
        db.collection("users/\(UID)/conversations").document(String(NumberMessage)).setData([
                "date": dateString,
                "message": text,
                "type": "text",
                "user_email": userLogin
            ])
        db.collection("users/\(UID)/conversations").document("lastMessage").updateData([
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
        self.messageInputBar.inputTextView.resignFirstResponder()
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
                email = "vira-kran74@mail.ru"
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
        var uid = ""
        if userLogin == "vira-kran74@mail.ru"{
            uid = chosenUserUID
        }
        else{
            uid = myUID
        }
        var NumberMessage = 0
        if messages.count != 0{
        NumberMessage = Int(self.messages.last!.messageId)! + 1
        }
        let filename = "photo_message_\(NumberMessage).png"
        StorageManager.shared.uploadPicture(with: data, location: "userImages", fileName: filename, userName: uid, completion: { result in
                switch result {
                case .success(let downloadUrl):
                    self.sendPhotoImage(UID: uid, messageURL: downloadUrl, userLogin: self.userLogin, type: "image")

                case .failure(let error):
                    print("Storage manager error: \(error)")
                }
            })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: запись данных о сообщении с изображением в коллекцию с чатом пользователя и в качестве последнего сообщения
    func sendPhotoImage(UID: String, messageURL: String, userLogin: String, type: String){
        let NumberMessage = Int(self.messages.last!.messageId)! + 1
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        let dateString = Date.init()
        db.collection("users/\(UID)/conversations").document(String(NumberMessage)).setData([
                "date": dateString,
                "message": messageURL,
                "type": type,
                "user_email": userLogin
            ])
        db.collection("users/\(UID)/conversations").document("lastMessage").updateData([
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
//MARK: открыть изображение на полный экран

extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }

        let message = messages[indexPath.section]

        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            UserDefaults.standard.set("\(imageUrl)", forKey: "pictureURLforFull")
            openPhotoViewController()
        case .text(_):
            break
        case .attributedText(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
    }
}

