//
//  ProductViewController.swift
//  ViraKran
//
//  Created by Stanislav on 17.05.2021.
//

import UIKit
import SDWebImage
import RealmSwift
import JJFloatingActionButton
import FirebaseFirestore

struct TextCellViewmodel{
    let text: String
    let font: UIFont
}

//MARK: Виды секций в контролере
enum SectionType {
    case productPhotos
    case productInfo(viewModels: [TextCellViewmodel])
    case productParameters(viewModels: [ParametersTableViewCellViewModel])
    var title: String?{
        switch self{
        case .productParameters:
            return "Технические характеристики"
        default:
            return nil
        }
    }
}

class ProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MyCollectionCellDelegate{
    let realm = try! Realm()
    let database = Firestore.firestore()
    let products = ["автокран", "башенный кран", "быстромонтируемый кран", "строительный подъемник"]
    let isFavorite = UserDefaults.standard.string(forKey: "isFavorite?") ?? "Guest1"
    private let application = UIApplication.shared
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
        table.register(PhotoCarouselTableViewCell.self, forCellReuseIdentifier: PhotoCarouselTableViewCell.identifier)
        table.register(ParametersTableViewCell.self, forCellReuseIdentifier: ParametersTableViewCell.identifier)
        return table
    }()
    
    var actionButton = JJFloatingActionButton()
    var sections = [SectionType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeViewController))
        
        configureSections()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        //MARK: объявление кнопок
        let item1 = actionButton.addItem()
        item1.titleLabel.text = "Звонок"
        item1.imageView.image = UIImage(named: "phone")
        item1.action = { item in
            self.makeACall()
        }
        let item2 = actionButton.addItem()
        item2.titleLabel.text = "Сообщение"
        item2.imageView.image = UIImage(named: "messages")
        item2.action = { item in
            self.goToChats()
        }
        let item3 = actionButton.addItem()
        if isFavorite != "true"{
        item3.titleLabel.text = "Добавить в избранное"
        item3.action = { item in
            self.addToFavorite()
        }
        }
        else{
            item3.titleLabel.text = "Удалить из избранного"
            item3.action = { item in
                self.deleteFromFavorite()
            }
        }
        let item4 = actionButton.addItem()
        item4.titleLabel.text = "Посмотреть отзывы"
        item4.action = { item in
            self.openComments()
        }

        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    //MARK: Настройка таблицы
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sections[section]
        switch sectionType {
        case .productPhotos:
            return 1
        case .productInfo(viewModels: let viewModels):
            return viewModels.count
        case .productParameters(viewModels: let viewModels):
            return viewModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = sections[section]
        return sectionType.title
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = sections[indexPath.section]
        switch sectionType{
        case .productPhotos:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCarouselTableViewCell.identifier, for: indexPath) as? PhotoCarouselTableViewCell else{
                fatalError()
            }
            cell.delegate = self
            return cell
            
        case .productInfo(let viewModels):
            let viewModel = viewModels[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
            cell.configure(with: viewModel)
            return cell
        case .productParameters(let viewModels):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ParametersTableViewCell.identifier, for: indexPath) as? ParametersTableViewCell else{
                fatalError()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    //MARK: открыть изображение на полный экран
    func showPicture(){
        let myViewController = storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController
        let myNavigationController = UINavigationController(rootViewController: myViewController!)
        myNavigationController.modalPresentationStyle = .fullScreen
        self.present(myNavigationController, animated: true)
    }
    
    //MARK: настройка секций в соответствии с данными из о товаре из Realm
    func configureSections(){
        let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
        let choseneqId = UserDefaults.standard.string(forKey: "eqId") ?? "Guest1"
        let objects = realm.objects(Equipment.self).filter("catId == %@ && eqId == %@", chosenCatId, choseneqId)
        let tmpObject = objects[0]
        title = tmpObject.title
        let baseAmountInRub = Double(tmpObject.cost) ?? 0
        var amount = tmpObject.cost
        var amountValue = "Руб"
        var tmpParameters: [ParametersTableViewCellViewModel] = []
        let value = UserDefaults.standard.string(forKey: "value") ?? "Guest"
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = " "
        amount = formatter.string(for: baseAmountInRub)!

        if value == "Евро"{
            amount = String(format: "%.2f",(DatabaseManager.shared.getActual(rates: "EUR") * baseAmountInRub))
            amount = formatter.string(for: Double(amount))!
            amountValue = "EUR"
        }
        else if value == "Доллары"{
            amount = String(format: "%.2f",(DatabaseManager.shared.getActual(rates: "USD") * baseAmountInRub))
            amount = formatter.string(for: Double(amount))!
            amountValue = "USD"
        }
        else if value == "Фунты"{
            amount = String(format: "%.2f",(DatabaseManager.shared.getActual(rates: "GBP") * baseAmountInRub))
            amount = formatter.string(for: Double(amount))!
            amountValue = "GBP"
        }
        
        for eqch in tmpObject.eqCharacteristic{
            tmpParameters.append(ParametersTableViewCellViewModel(title: eqch.stringKey, value: eqch.stringValue))
        }
        sections.append(.productPhotos)
        sections.append(.productInfo(viewModels: [TextCellViewmodel(text: tmpObject.textInfo, font: .systemFont(ofSize: 20))]))
    //MARK: доработать с обновлением данных о валюте
        sections.append(.productInfo(viewModels: [TextCellViewmodel(text: "Год выпуска: \(tmpObject.year)", font: .systemFont(ofSize: 20))]))
        sections.append(.productInfo(viewModels: [TextCellViewmodel(text: "Местонахождение: \(tmpObject.location)", font: .systemFont(ofSize: 20))]))
        sections.append(.productInfo(viewModels: [TextCellViewmodel(text: "Стоимость/мес: \(amount) \(amountValue)", font: .systemFont(ofSize: 20))]))
        sections.append(.productParameters(viewModels: tmpParameters))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionType = sections[indexPath.section]
        switch sectionType{
        case .productPhotos:
            return view.frame.size.width
        case .productInfo:
            return UITableView.automaticDimension
        case .productParameters:
            return UITableView.automaticDimension
        }
    }
    func showAlert(message: String) {
        var t = "Ошибка"
        if message == "Успешно"{
            t = "Уведомление"
        }
        let alert = UIAlertController(title: t, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func closeViewController() {
        print("CLOSE")
        UserDefaults.standard.removeObject(forKey: "isFavorite?")
        UserDefaults.standard.removeObject(forKey: "eqId")
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: звонок
    func makeACall(){
        let email = UserDefaults.standard.string(forKey: "email") ?? "Guest1"
        if email != "admin@gmail.com" && email != "Guest1"{
        if let phoneURL = URL(string: "tel://89026109919"){
            if application.canOpenURL(phoneURL){
                application.open(phoneURL, options: [:], completionHandler: nil)
            }
            else{
                self.showAlert(message: "Ошибка при совершении звонка")
            }
        }
        }
    }
    //MARK: переход к чатам
    func goToChats(){
        let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
        let chosenCategory = products[Int(chosenCatId)! - 1]
        let email = UserDefaults.standard.string(forKey: "email") ?? "Guest1"
        if email != "admin@gmail.com" && email != "Guest1"{
            let myViewController = storyboard?.instantiateViewController(withIdentifier: "chatViewController") as? ChatViewController
            let myNavigationController = UINavigationController(rootViewController: myViewController!)
            myNavigationController.modalPresentationStyle = .fullScreen
            myViewController?.messageInputBar.inputTextView.text = "Здравствуйте, заинтересовал \(chosenCategory) \(title!)"
            self.present(myNavigationController, animated: true)
        }
    }
    //MARK: переход к комментариям
    func openComments(){
        let vc = PostsViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav,animated:true)
    }
    
    //MARK: добавить в избранное
    func addToFavorite(){
        let email = UserDefaults.standard.string(forKey: "email") ?? "Guest1"
        if email != "Guest1"{
            let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
            let choseneqId = UserDefaults.standard.string(forKey: "eqId") ?? "Guest1"
            let docRef = database.collection("users/\(email)/savedItems").document("\(chosenCatId)_\(choseneqId)")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.showAlert(message: "Объект уже был сохранен")
                }
                else{
                    self.database.collection("users/\(email)/savedItems").document("\(chosenCatId)_\(choseneqId)").setData([
                "catId": chosenCatId,
                "eqId": choseneqId
            ])
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.showAlert(message: "Ошибка при добавлении объекта, повторите позже")
                }
                else{
                    let tmpObject = FavoriteEquipment()
                    tmpObject.catId = chosenCatId
                    tmpObject.eqId = choseneqId
                    try! self.realm.write{
                        self.realm.add(tmpObject)
                        self.showAlert(message: "Успешно")
                    }
                }
            }
            }
            }
    }
        else{
            self.showAlert(message: "Авторизуйтесь в приложении")
        }
}
    //MARK: удаление из избранного
    func deleteFromFavorite(){
        let email = UserDefaults.standard.string(forKey: "email") ?? "Guest1"
        if email != "Guest1"{
            let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
            let choseneqId = UserDefaults.standard.string(forKey: "eqId") ?? "Guest1"
            let docRef = database.collection("users/\(email)/savedItems").document("\(chosenCatId)_\(choseneqId)")
            docRef.delete() { err in
                if let err = err {
                    self.showAlert(message: "Ошибка при удалении объекта, повторите позже")
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    let object = self.realm.objects(FavoriteEquipment.self).filter("catId == %@ && eqId == %@", chosenCatId, choseneqId)
                    if object.count != 0{
                        try! self.realm.write {
                            self.realm.delete(object)
                        }
                    }
                    self.closeViewController()
                    print("sentNotification")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFavoriteCollection"), object: nil)
                }
            }
        }
    }
}
 
extension UITableViewCell {
    func configure(with viewModel: TextCellViewmodel){
        textLabel?.text = viewModel.text
        textLabel?.numberOfLines = 0
        textLabel?.font = viewModel.font
    }
}

