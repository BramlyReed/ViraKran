//
//  ViewController.swift
//  ViraKran
//
//  Created by Stanislav on 06.02.2021.
//

import UIKit
import Firebase
class MainController: UIViewController, UITableViewDataSource {
    var db: Firestore!
    var NewsArray = [NewsModel]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        loadData()
        checkForUpdates()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.NewsArray.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell
        cell?.setText(title: NewsArray.last?.title ?? "Default")
        return cell!
    }
    
    func loadData(){
        db.collection("news").getDocuments{ (querySnapshot, error) in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                print("I step here!")
                self.NewsArray = (querySnapshot!.documents.flatMap({NewsModel(dictionary: $0.data())}))
                DispatchQueue.main.async {    //обновлять данные скролл вью в будущем
                    self.tableView.reloadData()
                    print(self.NewsArray.count)
                }
            }
        }
    }
    func checkForUpdates(){
        db.collection("news").whereField("date", isGreaterThan: Date()).addSnapshotListener{(querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            
            snapshot.documentChanges.forEach({(diff) in
                if diff.type == .added{
                    self.NewsArray.append(NewsModel(dictionary: diff.document.data())!)
                    DispatchQueue.main.async {    //обновлять данные скролл вью в будущем
                        self.tableView.reloadData()
                        print(self.NewsArray.count)

                    }
                }
            })
        }
        printData()
    }
    func printData(){
        print(NewsArray.count)
    }
}

