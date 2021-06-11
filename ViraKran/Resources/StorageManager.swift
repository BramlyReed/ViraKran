//
//  StorageManager.swift
//  ViraKran
//
//  Created by Stanislav on 05.03.2021.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseStorage

class StorageManager{
    let db = Firestore.firestore()
    static let shared = StorageManager()
    let storage = Storage.storage().reference()
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void

    //MARK: загрузка изображения в storage
    func uploadPicture(with data: Data, location: String, fileName: String, userName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("\(location)/\(userName)/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                return
            }
            strongSelf.storage.child("\(location)/\(userName)/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    return
                }
                let urlString = url.absoluteString
                completion(.success(urlString))
            })
        })
    }
    
    //MARK: скачивание ссылки на изображение
    func downloadURL(for email: String, completion: @escaping (Result<URL, Error>) -> Void){
        let reference = storage.child("usersProfileImages/\(email)/\(email).profile_picture.png")
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                print("Error")
                return
            }
            completion(.success(url))
        })
    }
}
