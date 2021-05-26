//
//  FavoriteItemsViewController.swift
//  ViraKran
//
//  Created by Stanislav on 23.05.2021.
//

import UIKit
import RealmSwift
import FirebaseFirestore

class FavoriteItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let database = Firestore.firestore()
    var storedObjects: [FavoriteEquipment] = []
    let realm = try! Realm()
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "FavoriteCell", bundle: nil), forCellWithReuseIdentifier: "FavoriteCell")
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollection), name: NSNotification.Name(rawValue: "updateFavoriteCollection"), object: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (collectionView.frame.width - 30) / 3
            return CGSize(width: width, height: width)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            10
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            10
        }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.storedObjects.count
        }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCollectionViewCell
        if self.storedObjects.count != 0{
            let object = realm.objects(Equipment.self).filter("catId == %@ && eqId == %@", storedObjects[indexPath.item].catId, storedObjects[indexPath.item].eqId)
            if object.count != 0{
                let tmpString = "\(object[0].image_links[0].link)"
                cell.imageURL = URL(string: tmpString)
            }
        }
        return cell
    }
    //MARK: открытие экрана с товаром
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UserDefaults.standard.set(String(storedObjects[indexPath.item].eqId), forKey: "eqId")
        UserDefaults.standard.set(String(storedObjects[indexPath.item].catId), forKey: "catId")
        UserDefaults.standard.set("true", forKey: "isFavorite?")
        let object = realm.objects(Equipment.self).filter("catId == %@ && eqId == %@", storedObjects[indexPath.item].catId, storedObjects[indexPath.item].eqId)
        let myViewController = storyboard?.instantiateViewController(withIdentifier: "ProductViewController") as? ProductViewController
        if object.count != 0{
            myViewController?.title = String(object[0].title)
        }
        let myNavigationController = UINavigationController(rootViewController: myViewController!)
        myNavigationController.modalPresentationStyle = .fullScreen
        self.present(myNavigationController, animated: true)
    }
    //MARK: заполнение массива данными с сохраненными товарами
    func configure(){
        let objects = realm.objects(FavoriteEquipment.self)
        self.storedObjects = []
        if objects.count != 0{
            for item in objects{
                self.storedObjects.append(item)
            }
        }
        self.collectionView.reloadData()
    }
    
    //MARK: получение данных из коллекции и запись в realm
    func getData() {
        let email = UserDefaults.standard.string(forKey: "email") ?? "Guest1"
        let docRef = database.collection("users/\(email)/savedItems")
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let objects = self.realm.objects(FavoriteEquipment.self)
                if objects.count != 0{
                    try! self.realm.write {
                        self.realm.delete(objects)
                    }
                }
                for document in querySnapshot!.documents {
                    let tmpObject = FavoriteEquipment()
                    let docdata = document.data()
                    tmpObject.catId = docdata["catId"] as? String ?? ""
                    tmpObject.eqId = docdata["eqId"] as? String ?? ""
                    try! self.realm.write{
                        self.realm.add(tmpObject)
                    }
                }
            }
            self.configure()
        }
    }
    @objc func updateCollection(){
        print("GotNotification")
        self.configure()
    }
}
