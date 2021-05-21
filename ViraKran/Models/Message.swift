//
//  Message.swift
//  ViraKran
//
//  Created by Stanislav on 16.03.2021.
//

import Foundation
import UIKit
import MessageKit
import RealmSwift

struct Message: MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}



