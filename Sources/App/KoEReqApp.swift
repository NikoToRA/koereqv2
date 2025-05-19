import SwiftUI

@main
struct KoEReqApp: App {
    @StateObject private var sessionViewModel = SessionViewModel()
    
    var body: some Scene {
        WindowGroup {
            if sessionViewModel.isLoggedIn {
                HomeView()
                    .environmentObject(sessionViewModel)
            } else {
                LoginView()
                    .environmentObject(sessionViewModel)
            }
        }
    }
}
