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
    var name: String
    var surname: String
    var email: String
}

struct ItemProcut{
    var catId = ""
    var eqId = ""
}
