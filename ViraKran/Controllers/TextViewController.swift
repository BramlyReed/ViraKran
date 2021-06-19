//
//  TextViewController.swift
//  ViraKran
//
//  Created by Stanislav on 07.06.2021.
//

import UIKit
class TextViewController: UIViewController {
        
    @IBOutlet weak var textView: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Соглашение"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(closeController))
        setUpTextView()
    }
    
    func setUpTextView(){
        let path = Bundle.main.path(forResource: "Privacy", ofType: "txt")
        let url = URL(fileURLWithPath: path!)
        let contentString = try! NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue)
        textView.text = contentString as String
    }
    
    @objc func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
}
