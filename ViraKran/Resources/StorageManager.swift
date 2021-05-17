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

    public func uploadProfilePicture(with data: Data, fileName: String, userName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("userImages/\(userName)/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                // failed
                print("failed to upload data to firebase for picture")
                return
            }

            strongSelf.storage.child("userImages/\(userName)/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    static func getPhoto(photomodel: String, completion: @escaping (UIImage?) -> Void){
        guard let imageURL = URL(string: photomodel) else { return }
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            let image = UIImage(data: imageData)
            completion(image)
        }
    }

}
