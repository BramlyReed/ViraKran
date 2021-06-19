//
//  PhotoViewController.swift
//  ViraKran
//
//  Created by Stanislav on 01.03.2021.
//

import UIKit
import SDWebImage

class PhotoViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Фото"
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = 4
            scrollView.delegate = self
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(closeViewController))
            let imageURL = UserDefaults.standard.string(forKey: "pictureURLforFull") ?? "Guest1"
            self.imageView.sd_setImage(with: URL(string: imageURL))
        }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let conditionLeft = newWidth*scrollView.zoomScale > imageView.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - imageView.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                let conditioTop = newHeight*scrollView.zoomScale > imageView.frame.height
                let top = 0.5 * (conditioTop ? newHeight - imageView.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
    
    @objc func closeViewController() {
        UserDefaults.standard.removeObject(forKey: "pictureURLforFull")
        self.dismiss(animated: true, completion: nil)
    }
}
