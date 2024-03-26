import SwiftUI
import FirebaseFirestore


struct VoiceView: View {
    let accountRef: DocumentReference
    @ObservedObject var messageViewModel: MessageViewModel
    @StateObject var waveViewModel = WaveformViewModel()
    @StateObject var voiceViewModel = VoiceViewModel()
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Spacer()
            if voiceViewModel.isRecording || voiceViewModel.isPlaying {
                WaveformView(viewModel: waveViewModel, author: voiceViewModel.isRecording)
                    .onReceive(timer) { _ in
                        voiceViewModel.updateAudioLevels()
                        waveViewModel.update(voiceViewModel.audioLevel)
                }
                Spacer()
            }
            if voiceViewModel.uploadLevel != 0.0 {
                ProgressView(value: voiceViewModel.uploadLevel).tint(.green)
            }
            Button(action: {
                if voiceViewModel.isRecording {
                    voiceViewModel.stopRecording(accountId: accountRef.documentID)
                } else {
                    voiceViewModel.startRecording()
                }
            }) {
                Image(systemName: "mic").resizable().scaledToFit().frame(width:64, height: 64)
            }
        }.foregroundStyle(voiceViewModel.isRecording ? Color.red: Color.green).onAppear() {
            messageViewModel.listenForLatestAudio(accountRef: accountRef) { audio in
                voiceViewModel.startPlaying(path: audio)
            }
        }
    }
}
