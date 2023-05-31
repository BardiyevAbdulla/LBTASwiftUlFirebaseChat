//
//  MainMessagesView.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 5/30/23.
//

import SwiftUI
import SDWebImageSwiftUI


class MainMessagesViewModel: ObservableObject {
    @Published var chatUser: ChatUser?
   
    @Published var errorMassage = ""
    
    @Published var isUserCurrentlyLoggedOut = false
    
    @Published var userUid: String? = "sClEimUajdQJB3NimSZ4co8peEq1"
    
    init() {
        fetchCurrentUser()
    }
    
    func fetchCurrentUser(_ uid: String? = nil) {
        if let uid = uid  {
            self.userUid = uid }
        
        guard let uid = userUid else {
            isUserCurrentlyLoggedOut = true
            return
            
        }
        isUserCurrentlyLoggedOut = false
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).getDocument { snapshot, error in
                if let error {
                    print("Failed to fetch data: \(error)")
                    return
                }
                guard let data = snapshot?.data() else { return }
                self.errorMassage = "\(data)"
                
                self.chatUser = .init(data: data)
                
            }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
}

struct MainMessagesView: View {
    @State var shouldShowLogOutOption = false
    @State var shouldShowNewMessageScreen = false
    
    @ObservedObject var viewModel = MainMessagesViewModel()
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 16) {
                    WebImage(url: URL(string: viewModel.chatUser?.profileImageUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipped()
                        .cornerRadius(44)
                        .overlay(RoundedRectangle(cornerRadius: 44) .stroke(Color.black, lineWidth: 1))
                        .shadow(radius: 5)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.chatUser?.name ?? "User Name")
                            .font(.system(size: 24, weight: .bold))
                        HStack {
                            Circle()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.green)
                            Text("online")
                                .foregroundColor(Color.gray)
                        }
                        
                    }
                    Spacer()
                    Button {
                        shouldShowLogOutOption.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(Color.black)
                            .font(.system(size: 24, weight: .bold))
                    }

                    
                }
                .padding()
                
                .confirmationDialog("Setting", isPresented: $shouldShowLogOutOption) {
                    Text("salll")
                    Button("Sign out", role: .destructive) {
                        viewModel.handleSignOut()
                    }
                    
                }
            message: {
                Text("What do you want to do")
            }
                ScrollView {
                    ForEach(0..<10) { num in
                        VStack {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 32))
                                    .padding(8)
                                    .overlay(RoundedRectangle(cornerRadius: 44) .stroke(Color.black, lineWidth: 1))
                                VStack {
                                    Text("UserName")
                                    Text("Message sent to user")
                                }
                                Spacer()
                                Text("22d")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            Divider()
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 50)
                }
                .overlay (
                    
                    Button {
                        shouldShowNewMessageScreen.toggle()
                    } label: {
                        HStack {
                            Spacer()
                            Text("+ New Message")
                                .font(.system(size: 16, weight: .bold))
                               Spacer()
                        }
                        .foregroundColor(Color.white)
                        .padding(.vertical)
                        .background(Color.blue)
                        .cornerRadius(24)
                        .shadow(radius: 15)
                        .padding(.horizontal)
                        
                    }
                    , alignment: .bottom)
            }
           
        }
        .fullScreenCover(isPresented: $viewModel.isUserCurrentlyLoggedOut) {
            ContentView(didCompleteLoginProcess: { uid in
                
                viewModel.fetchCurrentUser(uid)
            })
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView(viewModel.userUid ?? "", didSelectNewUser: {
                user in
                
            })
        }
    }
    
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
           // .preferredColorScheme(.dark)
    }
}
