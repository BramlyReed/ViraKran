//
//  CategoryEquipmentViewController.swift
//  ViraKran
//
//  Created by Stanislav on 19.05.2021.
//


import UIKit
import JJFloatingActionButton
import RealmSwift
class CategoryEquipmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var data: [Equipment] = []
    var canceldata: [Equipment] = []
    let realm = try! Realm()
    @IBOutlet weak var cardTableView: UITableView!
    var actionButton = JJFloatingActionButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFullTableView), name: NSNotification.Name(rawValue: "updateCategoryList"), object: nil)
        self.data.removeAll()
        //MARK: выбор объектов из Realm с соответствующей категорией
        let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
        let products = ["Автокраны", "Башенные", "Быстромонтируемые", "Подъёмники"]
        title = products[Int(chosenCatId)! - 1]
        let objects = realm.objects(Equipment.self).filter("catId == %@", chosenCatId)
        if objects.count != 0{
            for item in objects{
                self.data.append(item)
                self.canceldata.append(item)
            }
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeViewController))
        //MARK: Кнопки с сортировками
        let item0 = actionButton.addItem()
        item0.titleLabel.text = "Отменить сортировку"
        item0.imageView.image = UIImage(named: "cancel")
        item0.action = { item in
            self.sortPage(type: "cancel")
        }
        let item1 = actionButton.addItem()
        item1.titleLabel.text = "По году выпуска"
        item1.imageView.image = UIImage(named: "sortlow")
        item1.action = { item in
            self.sortPage(type: "year")
        }
        let item2 = actionButton.addItem()
        item2.titleLabel.text = "По наибольшей стоимости"
        item2.imageView.image = UIImage(named: "sort")
        item2.action = { item in
            self.sortPage(type: "highcost")
        }
        let item3 = actionButton.addItem()
        item3.titleLabel.text = "По наименьшей стоимости"
        item3.imageView.image = UIImage(named: "sortlow")
        item3.action = { item in
            self.sortPage(type: "lowcost")
        }
        let item4 = actionButton.addItem()
        item4.titleLabel.text = "По названию"
        item4.imageView.image = UIImage(named: "namesort")
        item4.action = { item in
            self.sortPage(type: "name")
        }
        view.addSubview(actionButton)
        actionButton.buttonImage = UIImage(named: "sorting")
        actionButton.buttonColor = .red
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? CategoryEquipmentTableViewCell else{
            fatalError()
        }
        cell.configure(picture: data[indexPath.item].image_links[0].link, title: data[indexPath.item].title)
        return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        UserDefaults.standard.set(String(data[indexPath.item].eqId), forKey: "eqId")
        let myViewController = storyboard?.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController
        myViewController?.title = String(data[indexPath.item].title)
        let myNavigationController = UINavigationController(rootViewController: myViewController!)
        myNavigationController.modalPresentationStyle = .fullScreen
        self.present(myNavigationController, animated: true)
    }
    //MARK: настройка видов сортировки
    func sortPage(type: String){
        if type == "year"{
            self.data = data.sorted(by: { Int($0.year)! > Int($1.year)! })
        }
        else if type == "lowcost"{
            self.data = data.sorted(by: { Double($0.cost)! < Double($1.cost)! })

        }
        else if type == "highcost"{
            self.data = data.sorted(by: { Double($0.cost)! > Double($1.cost)! })

        }
        else if type == "name"{
            self.data = data.sorted(by: { $0.title.lowercased() < $1.title.lowercased() })

        }
        else if type == "name"{
            
            self.data = data.sorted(by: { $0.title > $1.title })

        }
        else if type == "cancel"{
            if canceldata.count != 0{
                self.data = self.canceldata
            }
        }
        DispatchQueue.main.async {
            self.cardTableView.reloadData()
        }
    }
    
    //MARK: обновления товаров из Realm, тк получено уведомление о том что добавлен новый товар техники
    @objc func updateFullTableView(){
        let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
        let objects = realm.objects(Equipment.self).filter("catId == %@", chosenCatId)
        if objects.count != 0{
            self.data.removeAll()
            self.canceldata.removeAll()
            for item in objects{
                self.data.append(item)
                self.canceldata.append(item)
            }
            DispatchQueue.main.async {
                self.cardTableView.reloadData()
            }
        }
    }
    
    @objc func closeViewController() {
        DatabaseManager.shared.removeListener()
        UserDefaults.standard.removeObject(forKey: "catId")
        self.dismiss(animated: true, completion: nil)
    }
}
