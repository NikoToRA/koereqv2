import SwiftUI

struct ConsultModalView: View {
    @Binding var consultText: String
    @State private var isRecording = false
    @Environment(\.dismiss) private var dismiss
    
    let onSubmit: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("AIに何を相談しますか?")
                .font(.headline)
            
            Divider()
            
            HStack {
                Button(action: {
                    isRecording.toggle()
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("録音")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: {
                }) {
                    HStack {
                        Image(systemName: "keyboard")
                        Text("入力")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            if !isRecording {
                TextField("相談内容を入力", text: $consultText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    onSubmit(consultText)
                    dismiss()
                }) {
                    Text("送信")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}
