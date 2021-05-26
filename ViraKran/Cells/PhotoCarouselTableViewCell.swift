//
//  PhotoCarouselTableViewCell.swift
//  ViraKran
//
//  Created by Stanislav on 17.05.2021.
//

import UIKit
import RealmSwift


protocol MyCollectionCellDelegate: AnyObject {
    func showPicture()
}

class PhotoCarouselTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    static let identifier = "ProductPhotoCarousel"
    let realm = try! Realm()
    weak var delegate: MyCollectionCellDelegate?

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        return collectionView
    }()
    
    //var images = [UIImage]()
    var images: [String] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let chosenCatId = UserDefaults.standard.string(forKey: "catId") ?? "Guest1"
        let choseneqId = UserDefaults.standard.string(forKey: "eqId") ?? "Guest1"
        let objects = realm.objects(Equipment.self).filter("catId == %@ && eqId == %@", chosenCatId, choseneqId)
        var tmpObject: [Equipment] = []
        if objects.count != 0{
            print("Found items")
            for item in objects{
                tmpObject.append(item)
            }
        }
        for img in tmpObject.last!.image_links{
            images.append(img.link)
        }
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else{
            fatalError()
        }
        cell.configure(with: images[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: contentView.frame.size.width, height: contentView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tap number ", indexPath.item)
        UserDefaults.standard.set(images[indexPath.item], forKey: "pictureURLforFull")
        showPicture((Any).self)
    }
    
    func showPicture(_ sender: Any) {
        delegate?.showPicture()
    }
}
