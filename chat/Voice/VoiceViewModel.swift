import Foundation
import AVFoundation
import FirebaseStorage

class VoiceViewModel: NSObject, ObservableObject,  AVAudioPlayerDelegate {
    let storage = Storage.storage()
    let session = AVAudioSession.sharedInstance()
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var path: URL?
    var recordingId: String?
    
    @Published var uploadLevel = 0.0
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var audioLevel = 0.0
    
   override init() {
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print(error)
        }
    }
    
    func startRecording() {
        do {
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                                isDirectory: true)
            
            recordingId = UUID().uuidString
            
            let temporaryFilename = recordingId! + ".wav"

            path = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
            
            recorder = try AVAudioRecorder(url: path!, settings: [:])
            
            // Start recording
            recorder?.isMeteringEnabled = true
            
            recorder?.record()
            isRecording = true
        } catch {
            print(error)
        }
    }
    
    func stopRecording(accountId: String) {
        recorder?.stop()
        recorder = nil
        isRecording = false
        audioLevel = 0.0
        
        if let id = recordingId {
            let storageRef = storage.reference()
            let ref = storageRef.child("account/\(accountId)/message/\(id)/author.wav")
            
            let uploadTask = ref.putFile(from: path!, metadata: nil) { metadata, error in
                
            }
            
            uploadTask.observe(.progress) { snapshot in
                self.uploadLevel = snapshot.progress?.fractionCompleted ?? 0.0
            }
            
            uploadTask.observe(.success) { snapshot in
                self.uploadLevel = 0.0
            }
        }
    }
    
    func updateAudioLevels() {
        if let rec = recorder {
            rec.updateMeters()
            audioLevel = max(0.2, CGFloat(rec.averagePower(forChannel: 0)) + 50) / 50 // Normalize to 0...1
        }
        if let play = player {
            player?.updateMeters()
            audioLevel = max(0.2, CGFloat(play.averagePower(forChannel: 0)) + 50) / 50 // Normalize to 0...1
        }
    }
    
    func startPlaying(path: URL) {
        player = try! AVAudioPlayer(contentsOf: path)
        player?.delegate = self
        player?.isMeteringEnabled = true
        player?.play()
        isPlaying = true
    }
    
    func stopPlaying() {
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        self.player = nil
    }
}
