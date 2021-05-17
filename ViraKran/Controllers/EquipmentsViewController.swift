//
//  EquipmentsViewController.swift
//  ViraKran
//
//  Created by Stanislav on 11.05.2021.
//

import UIKit

class EquipmentsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var equipments:[Equipment] = []
    let cellScacle: CGFloat = 0.6
    override func viewDidLoad() {
        super.viewDidLoad()
        equipments = Equipment.fetchEquipments()

        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScacle)
        let cellHeight = floor(screenSize.height * cellScacle)
        let insetX = (view.bounds.width - cellWidth) / 4.0
        let insetY = (view.bounds.height - cellHeight) / 4.0

        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: insetY, right: insetX)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGray6
        collectionView.layer.masksToBounds = true
    }


}

extension EquipmentsViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return equipments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eqCollectionViewCell", for: indexPath) as! EquipmentCollectionViewCell
        let equipment = equipments[indexPath.item]
        cell.equipment = equipment
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.backgroundColor = UIColor.clear.cgColor

        cell.contentView.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .white
        return cell
    }
}
