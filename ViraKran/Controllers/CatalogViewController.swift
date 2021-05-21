//
//  CatalogViewController.swift
//  ViraKran
//
//  Created by Stanislav on 16.05.2021.
//

import UIKit

class CatalogViewController: UITableViewController {
    
    var catalogitems = [UIImage(named: "avtokran")!, UIImage(named: "bashennuikran")!, UIImage(named: "bustromontiruemue")!, UIImage(named: "stroipod")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(CatalogCell.self, forCellReuseIdentifier: "CatalogCell")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(catalogitems.count)
        return catalogitems.count
        }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CatalogCell", for: indexPath) as? CatalogCell
        cell?.mainImageView.image = catalogitems[indexPath.item]
            return cell!
        }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentImage = catalogitems[indexPath.item]
        let imageCrop = currentImage.getCropRatio()
        return tableView.frame.width / imageCrop
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("Tap cell number \(indexPath.item)")
        UserDefaults.standard.set(String(indexPath.item + 1), forKey: "catId")

//        let vc = CategoryEquipmentViewController()
//        let nav = UINavigationController(rootViewController: vc)
//
//        nav.modalPresentationStyle = .fullScreen
//        present(nav,animated:true)
        
        let myViewController = storyboard?.instantiateViewController(withIdentifier: "CategoryEquipmentViewController") as? CategoryEquipmentViewController
        let myNavigationController = UINavigationController(rootViewController: myViewController!)
        myNavigationController.modalPresentationStyle = .fullScreen
        self.present(myNavigationController, animated: true)
        
//        guard let VC = storyboard?.instantiateViewController(identifier: "CategoryEquipmentViewController") as? CategoryEquipmentViewController else { return }
//        VC.title = "ChosenCategory"
//        VC.modalTransitionStyle = .flipHorizontal
//        VC.modalPresentationStyle = .fullScreen
//        present(VC,animated: true)
//        VC.cardTableView.reloadData()
    }
}

extension UIImage {
    func getCropRatio() -> CGFloat {
        let widthRatio = CGFloat(self.size.width / self.size.height)
        return widthRatio
    }
}
