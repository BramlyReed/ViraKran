//
//  CategoryEquipmentViewController.swift
//  ViraKran
//
//  Created by Stanislav on 19.05.2021.
//


// MARK: Добавить подписку на обновления таблицы
import UIKit
import JJFloatingActionButton
import RealmSwift
class CategoryEquipmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var data: [Equipment] = []
    let realm = try! Realm()

    @IBOutlet weak var cardTableView: UITableView!
    
    
    var actionButton = JJFloatingActionButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFullTableView), name: NSNotification.Name(rawValue: "updateCategoryList"), object: nil)
        self.data = []
        let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
        let objects = realm.objects(Equipment.self).filter("catId == %@", chosenCatId)
        if objects.count != 0{
            print("Found items ",objects.count)
            for item in objects{
                self.data.append(item)
            }
        }
        print("ALL RIGHT")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeChatViewController))
        let item1 = actionButton.addItem()
        item1.titleLabel.text = "Сортировать по году выпуска"
//        item1.imageView.image = UIImage(named: "phone")
        item1.action = { item in
            self.sortPage(type: "year")
        }
        let item2 = actionButton.addItem()
        item2.titleLabel.text = "Сортировать по стоимости"
        //item2.imageView.image = UIImage(named: "messages")
        item2.action = { item in
            self.sortPage(type: "cost")
        }
        let item3 = actionButton.addItem()
        item3.titleLabel.text = "Сортировать по названию"
        //item3.imageView.image = UIImage(named: "messages")
        item3.action = { item in
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
        print("Tap cell number \(indexPath.item)")
        UserDefaults.standard.set(String(data[indexPath.item].eqId), forKey: "eqId")

        let myViewController = storyboard?.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController
        myViewController?.title = String(data[indexPath.item].title)
        let myNavigationController = UINavigationController(rootViewController: myViewController!)
        myNavigationController.modalPresentationStyle = .fullScreen
        self.present(myNavigationController, animated: true)
    
    }
    func sortPage(type: String){
        if type == "year"{
            self.data = data.sorted(by: { Int($0.year)! > Int($1.year)! })
        }
        else if type == "cost"{
            self.data = data.sorted(by: { Double($0.cost)! > Double($1.cost)! })

        }
        else if type == "name"{
            self.data = data.sorted(by: { $0.title > $1.title })

        }
        DispatchQueue.main.async {
            self.cardTableView.reloadData()
        }
    }
    
    @objc func updateFullTableView(){
        print("Open Notification")
        let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
        let objects = realm.objects(Equipment.self).filter("catId == %@", chosenCatId)
        if objects.count != 0{
            print("Found items")
            self.data = []
            for item in objects{
                print("COUNT ",data.count)
                self.data.append(item)
            }
            DispatchQueue.main.async {
                self.cardTableView.reloadData()
            }
        }
    }
    
    @objc func closeChatViewController() {
        print("CLOSE")
        UserDefaults.standard.removeObject(forKey: "catId")
        self.dismiss(animated: true, completion: nil)
    }
}