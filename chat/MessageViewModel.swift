//
//  MessageViewModel.swift
//  chat
//
//  Created by Matthew External on 2024-02-27.
//

import Foundation
import FirebaseFirestore

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    var time: Date
    var text: String
    var author: Bool
}

class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    var listener: ListenerRegistration?
    
    func getMessages(accountRef: DocumentReference) {
        self.listener = accountRef.collection("message").order(by: "time").addSnapshotListener { querySnapshot, error in
            self.messages = querySnapshot?.documents.compactMap { message in
                try? message.data(as: Message.self)
            } ?? []
        }
    }
    
    func newMessage(accountRef: DocumentReference, text: String) {
        accountRef.collection("message").addDocument(data: [
            "text": text,
            "author": true,
            "time": Timestamp(date: Date())
        ])
    }
}
