import SwiftUI

struct FooterView: View {
    @Binding var isRecording: Bool
    @State private var showingGenerateMenu = false
    
    let onRecordingToggle: () -> Void
    let onGenerateMenu: () -> Void
    
    var body: some View {
        HStack {
            if !isRecording {
                Button(action: {
                    onGenerateMenu()
                }) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding(.leading)
            }
            
            Spacer()
            
            Button(action: {
                onRecordingToggle()
            }) {
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 30))
                    .padding()
                    .background(isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .padding(.trailing)
        }
        .padding(.vertical)
        .background(Color.white)
        .shadow(radius: 2)
    }
}

struct GenerateMenuView: View {
    let onChartGenerate: () -> Void
    let onLetterGenerate: () -> Void
    let onConsult: () -> Void
    let onCustomPrompt: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: onChartGenerate) {
                Text("カルテ生成")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: onLetterGenerate) {
                Text("紹介状作成")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: onConsult) {
                Text("AIに相談")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: onCustomPrompt) {
                Text("オリジナル")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
