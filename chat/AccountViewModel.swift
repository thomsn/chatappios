//
//  AccountViewModel.swift
//  chat
//
//  Created by Matthew External on 2024-02-27.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Account: Codable {
    @DocumentID var id: String?
}

class AccountViewModel: ObservableObject {
    @Published var account: Account?
    @Published var ref: DocumentReference?
    
    init() {
        Auth.auth().signInAnonymously { authResult, error in
            guard let authUser = authResult?.user else {
                print("There was an error collecting the firebase user")
                return
            }
            print("user id is: ", authUser.uid)
            let db = Firestore.firestore()
            let docRef = db.collection("account").document(authUser.uid)
            self.ref = docRef
            
            docRef.getDocument(as: Account.self) { result in
                switch result {
                case .success(let newAccount):
                    self.account = newAccount
                case .failure(let error):
                    print(error)
                    do {
                        self.account = Account()
                        try docRef.setData(from: self.account)
                    } catch let error {
                        print(error)
                    }
                }
            }
            
        }
    }
}
