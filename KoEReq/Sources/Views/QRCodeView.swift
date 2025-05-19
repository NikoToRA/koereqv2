import SwiftUI

struct QRCodeView: View {
    let text: String
    @State private var qrImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("QRコード")
                .font(.headline)
                .padding()
            
            if let image = qrImage {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            } else {
                ProgressView()
                    .frame(width: 250, height: 250)
            }
            
            Text(text)
                .font(.caption)
                .padding()
                .multilineTextAlignment(.center)
            
            Button(action: {
                dismiss()
            }) {
                Text("閉じる")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            let qrService = QRService()
            qrImage = qrService.generate(text: text)
        }
    }
}
