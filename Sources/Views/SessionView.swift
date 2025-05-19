import SwiftUI

struct SessionView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State private var showingConsultModal = false
    @State private var consultText = ""
    @State private var showingQRCode = false
    @State private var selectedAIResponse: AIResponse?
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        if let session = sessionViewModel.currentSession {
                            Text(session.summary)
                                .font(.headline)
                                .padding()
                        }
                        
                        ForEach(sessionViewModel.transcripts) { transcript in
                            TranscriptView(transcript: transcript)
                        }
                        
                        ForEach(sessionViewModel.aiResponses) { response in
                            AIResponseView(response: response)
                                .onTapGesture {
                                    selectedAIResponse = response
                                    showingQRCode = true
                                }
                        }
                        
                        if sessionViewModel.isProcessing {
                            HStack {
                                ProgressView()
                                Text("認識中...")
                            }
                            .padding()
                        }
                    }
                }
                
                Spacer()
                
                FooterView(
                    isRecording: $sessionViewModel.isRecording,
                    onRecordingToggle: {
                        sessionViewModel.toggleRecording()
                    },
                    onGenerateMenu: {
                        showingConsultModal = true
                    }
                )
            }
            
            if sessionViewModel.isRecording {
                Rectangle()
                    .fill(Color.black.opacity(0.6))
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack {
                            Text("● REC")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                        }
                    )
            }
        }
        .sheet(isPresented: $showingConsultModal) {
            ConsultModalView(
                consultText: $consultText,
                onSubmit: { text in
                }
            )
        }
        .sheet(isPresented: $showingQRCode) {
            if let response = selectedAIResponse {
                QRCodeView(text: response.text)
            }
        }
    }
}

struct TranscriptView: View {
    let transcript: TranscriptChunk
    
    var body: some View {
        Text(transcript.text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

struct AIResponseView: View {
    let response: AIResponse
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(response.promptType.name)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(response.text)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}
