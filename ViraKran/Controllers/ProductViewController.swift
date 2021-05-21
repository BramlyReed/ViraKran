//
//  ProductViewController.swift
//  ViraKran
//
//  Created by Stanislav on 17.05.2021.
//
// MARK: Добавить подписку на обновления таблицы

import UIKit
import SDWebImage
import RealmSwift
import JJFloatingActionButton

struct TextCellViewmodel{
    let text: String
    let font: UIFont
}

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

class ProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let realm = try! Realm()
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
        table.register(PhotoCarouselTableViewCell.self, forCellReuseIdentifier: PhotoCarouselTableViewCell.identifier)
        table.register(ParametersTableViewCell.self, forCellReuseIdentifier: ParametersTableViewCell.identifier)
        return table
    }()
    
    var actionButton = JJFloatingActionButton()

    private var sections = [SectionType]()
    
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
        let item1 = actionButton.addItem()
        item1.titleLabel.text = "Звонок"
        item1.imageView.image = UIImage(named: "phone")
        item1.action = { item in
            print("Tap1")
            self.showAlert(message: "ништяк")
        }
        let item2 = actionButton.addItem()
        item2.titleLabel.text = "Сообщение"
        item2.imageView.image = UIImage(named: "messages")
        item2.action = { item in
            print("Tap2")
            self.showAlert(message: "клево")

        }

        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true

        // last 4 lines can be replaced with
        // actionButton.display(inViewController: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
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
            return cell
            
        case .productInfo(let viewModels):
            let viewModel = viewModels[indexPath.item]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
            cell.configure(with: viewModel)
            return cell
        case .productParameters(let viewModels):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ParametersTableViewCell.identifier, for: indexPath) as? ParametersTableViewCell else{
                fatalError()
            }
            cell.configure(with: viewModels[indexPath.item])
            return cell
        }
    }
    func configureSections(){
        print("Show something")
        let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
        let choseneqId = UserDefaults.standard.string(forKey: "eqId") ?? "Guest1"
        let objects = realm.objects(Equipment.self).filter("catId == %@ && eqId == %@", chosenCatId, choseneqId)
        let tmpObject = objects[0]
        title = tmpObject.title
        var tmpParameters: [ParametersTableViewCellViewModel] = []
        print(objects)
            print("Found items")
            for eqch in tmpObject.eqCharacteristic{
                        tmpParameters.append(ParametersTableViewCellViewModel(title: eqch.stringKey, value: eqch.stringValue))
                
            }
        print(tmpObject)
        sections.append(.productPhotos)
        sections.append(.productInfo(viewModels: [TextCellViewmodel(text: tmpObject.textInfo, font: .systemFont(ofSize: 20))]))
        sections.append(.productParameters(viewModels: tmpParameters))
        sections.append(.productInfo(viewModels: [TextCellViewmodel(text: "Стоимость/мес: \(tmpObject.cost)", font: .systemFont(ofSize: 20))]))
        
        sections.append(.productInfo(viewModels: [TextCellViewmodel(text: "Год выпуска: \(tmpObject.year)", font: .systemFont(ofSize: 20))]))
        
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
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func closeViewController() {
        print("CLOSE")
        self.dismiss(animated: true, completion: nil)
    }
}
 
extension UITableViewCell {
    func configure(with viewModel: TextCellViewmodel){
        textLabel?.text = viewModel.text
        textLabel?.numberOfLines = 0
        textLabel?.font = viewModel.font
    }
}

