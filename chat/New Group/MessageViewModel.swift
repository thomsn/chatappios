import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    var audio: String?
    var time: Date
    var text: String
    var author: Bool
}

class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    var listener: ListenerRegistration?
    var audioListener: ListenerRegistration?
    let storage = Storage.storage()
    
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
    
    func listenForLatestAudio(accountRef: DocumentReference, onNewAudio: @escaping (URL)->()) {
        self.audioListener = accountRef.collection("message").order(by: "time", descending: true).limit(to: 1)
            .addSnapshotListener { querySnapshot, error in
                querySnapshot?.documentChanges.forEach {diff in
                    if diff.type == .modified {
                        let currentMessage = (querySnapshot?.documents.compactMap {message in
                            try? message.data(as: Message.self)
                        } ?? []).first
                        
                        if let message = currentMessage {
                            if let audio = message.audio {
                                let storageRef = self.storage.reference()
                                let uuid = UUID()
                                print("uuid \(uuid.uuidString)")
                                let temporaryFilename = uuid.uuidString + ".mp3"
                                
                                let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                                                isDirectory: true)
                                let path = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
                                print("saving to \(path)")
                                let downloadTask = storageRef.child(audio).write(toFile: path)
                                downloadTask.observe(.success) { snapshot in
                                    onNewAudio(path)
                                }
                                downloadTask.observe(.pause) { snapshot in
                                    print("paused")
                                }
                                downloadTask.observe(.progress) { snapshot in
                                    print(snapshot.progress?.fractionCompleted.description)
                                }
                                
                                downloadTask.observe(.failure) { snapshot in
                                    guard let errorCode = (snapshot.error as? NSError)?.code else {
                                        return
                                    }
                                    guard let error = StorageErrorCode(rawValue: errorCode) else {
                                        return
                                    }
                                    print(error.localizedDescription)
                                }
                                
                            }
                        }
                    }
                }
                
            }
    }
}
