//
//  NewsPageViewController.swift
//  ViraKran
//
//  Created by Stanislav on 27.05.2021.
//

import UIKit
import SDWebImage
import RealmSwift
import FirebaseFirestore

//MARK: Виды секций в контролере
enum SectionTypeForNews {
    case newsPhotos
    case newsInfo(viewModels: [TextCellViewmodel])
    }

class NewsPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MyCollectionCellDelegate{
    let realm = try! Realm()
    let database = Firestore.firestore()
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
        table.register(PhotoCarouselTableViewCell.self, forCellReuseIdentifier: PhotoCarouselTableViewCell.identifier)
        table.register(ParametersTableViewCell.self, forCellReuseIdentifier: ParametersTableViewCell.identifier)
        return table
    }()
    var sections = [SectionTypeForNews]()
    
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
        let SectionTypeForNews = sections[section]
        switch SectionTypeForNews {
        case .newsPhotos:
            return 1
        case .newsInfo(viewModels: let viewModels):
            return viewModels.count
        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let SectionTypeForNews = sections[section]
//        return "NAME"
//    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let SectionTypeForNews = sections[indexPath.section]
        switch SectionTypeForNews{
        case .newsPhotos:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCarouselTableViewCell.identifier, for: indexPath) as? PhotoCarouselTableViewCell else{
                fatalError()
            }
            cell.delegate = self
            return cell
            
        case .newsInfo(let viewModels):
            let viewModel = viewModels[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
            cell.configure(with: viewModel)
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
    
    //MARK: настройка секций в соответствии с данными из о новости из Realm
    func configureSections(){
        let chosenNewsId = UserDefaults.standard.string(forKey: "chosenNewsId") ?? "Guest1"
        print("NewsID ", chosenNewsId)
        let objects = realm.objects(NewsModel.self).filter("id == %@", chosenNewsId)
        if objects.count != 0{
            let tmpObject = objects[0]
            title = tmpObject.title
            sections.append(.newsPhotos)
            sections.append(.newsInfo(viewModels: [TextCellViewmodel(text: "\(tmpObject.date)", font: .systemFont(ofSize: 10))]))
            sections.append(.newsInfo(viewModels: [TextCellViewmodel(text: tmpObject.text_string, font: .systemFont(ofSize: 20))]))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionType = sections[indexPath.section]
        switch sectionType{
        case .newsPhotos:
            return view.frame.size.width
        case .newsInfo:
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
        UserDefaults.standard.removeObject(forKey: "chosenNewsId")
        self.dismiss(animated: true, completion: nil)
    }
}
 
//extension UITableViewCell {
//    func configure(with viewModel: TextCellViewmodel){
//        textLabel?.text = viewModel.text
//        textLabel?.numberOfLines = 0
//        textLabel?.font = viewModel.font
//    }
//}

