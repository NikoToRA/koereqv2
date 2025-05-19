import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        VStack {
            Text("KoEReq")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            Button(action: {
                sessionViewModel.startNewSession()
            }) {
                Text("新規セッション")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationDestination(isPresented: Binding<Bool>(
            get: { sessionViewModel.currentSession != nil },
            set: { _ in }
        )) {
            SessionView()
        }
    }
}
