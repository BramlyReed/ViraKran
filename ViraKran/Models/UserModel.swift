//
//  UserModel.swift
//  ViraKran
//
//  Created by Stanislav on 02.03.2021.
//

import Foundation
//protocol UserSeriazible{
//    init?(userName: String, userSurname: String, userLogin: String)
//}
//struct UserModel{
//    var userName: String?
//    var userSurname: String?
//    var userLogin: String?
//}
//extension UserModel: UserSeriazible{
//    init?(userName: String, userSurname: String, userLogin: String){
//        guard let userName =  userName as? String,
//              let userSurname = userSurname as? String,
//              let userLogin = userLogin as? String
//        else {
//            print("Doesn't work!")
//            return nil
//        }
//        self.init(userName: userName, userSurname: userSurname, userLogin: userLogin)
//    }
//}

struct UserModel {
    let name: String
    let surname: String
    let email: String
    //let profilePictureUrl: URL

    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }

    var profilePictureFileName: String {
        //afraz9-gmail-com_profile_picture.png
        return "\(email).profile_picture.png"
    }
}
