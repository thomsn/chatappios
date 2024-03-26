import SwiftUI

struct WaveformView: View {
    @ObservedObject var viewModel: WaveformViewModel
    let author: Bool
    let width = 4.0
    
    var body: some View {
        HStack (spacing: width/2.0) {
            ForEach(viewModel.wave.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: width/2.0)
                    .fill(author ? Color.green: Color.blue)
                    .frame(width: width, height: viewModel.wave[index]*60)
            }
            ForEach(viewModel.wave.indices.reversed(), id: \.self) { index in
                RoundedRectangle(cornerRadius: width/2.0)
                    .fill(author ? Color.green: Color.blue)
                    .frame(width: width, height: viewModel.wave[index]*60)
            }
        }.mask(
            Rectangle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [.clear, .black, .black, .clear]), startPoint: .leading, endPoint: .trailing)
                )
        )
    }
}
