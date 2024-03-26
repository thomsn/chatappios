import Foundation

class WaveformViewModel: ObservableObject {
    let size = 16
    @Published var wave: [Double] = []
    
    func update(_ value: Double) {
        if wave.count == size {
            wave.removeFirst()
        }
        wave.append(value)
    }
}
