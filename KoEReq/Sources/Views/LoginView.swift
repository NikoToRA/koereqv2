import SwiftUI

struct LoginView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State private var facilityId: String = ""
    @State private var sasToken: String = ""
    @State private var showingAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("KoEReq")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("施設ID", text: $facilityId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("SASトークン", text: $sasToken)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                if !facilityId.isEmpty && !sasToken.isEmpty {
                    sessionViewModel.login(facilityId: facilityId, sasToken: sasToken)
                } else {
                    showingAlert = true
                }
            }) {
                Text("ログイン")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("エラー"), message: Text("施設IDとSASトークンを入力してください"), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }
}
