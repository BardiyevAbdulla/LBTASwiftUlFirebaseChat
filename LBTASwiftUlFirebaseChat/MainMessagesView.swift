//
//  MainMessagesView.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 5/30/23.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

class MainMessagesViewModel: ObservableObject {
    @Published var chatUser: ChatUser?
   
    @Published var errorMassage = ""
    
    @Published var isUserCurrentlyLoggedOut = false
    
    @Published var userUid: String? = "sClEimUajdQJB3NimSZ4co8peEq1"
    
    @Published var recentMessages: [RecentMessage] = []
    
    init() {
        
        if let uid = StoragePhone.shared.getToken() {
            self.userUid = uid
           print("Abdullo: \(uid)")
        } else { isUserCurrentlyLoggedOut = true; return }
        
        fetchCurrentUser()
        fetchRecentMessage()
    }
    
    func fetchRecentMessage() {
        recentMessages.removeAll()
        FirebaseManager.shared.firestore
        .collection(FirebaseConstant.recentMessages)
        .document(userUid ?? "")
        .collection(FirebaseConstant.messages)
        .order(by: FirebaseConstant.timestamp)
        .addSnapshotListener { snapshot, error in
            if let error {
                print("Failed to recent message \(error)")
                self.errorMassage = error.localizedDescription
                return
            }
            
            snapshot?.documentChanges.forEach({ change in
                let docId = change.document.documentID
                if let index = self.recentMessages.firstIndex(where: {
                    rm in
                    return rm.id == docId}) {
                    self.recentMessages.remove (at: index)
                }
                self.recentMessages.insert(.init(doc: docId, data: change.document.data()), at: 0)
            })
        }
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
    @State var chatUser: ChatUser?
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject var viewModel = MainMessagesViewModel()
    var body: some View {
        NavigationView {
            
            VStack {
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser, userId: self.viewModel.userUid ?? "")
                    
                    
                }
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
                   
                    Button("Sign out", role: .destructive) {
                        viewModel.handleSignOut()
                    }
                    
                }
            message: {
                Text("What do you want to do")
            }
                ScrollView {
                    ForEach(viewModel.recentMessages) { recentMessage in
                       
                        VStack {
                            Button {
                                chatUser = ChatUser(uid: recentMessage.toId, email: recentMessage.email, profileImageUrl: recentMessage.profileImageUrl)
                                
                                shouldNavigateToChatLogView.toggle()
                            } label: {
                                HStack {
                                    WebImage(url: URL(string: recentMessage.profileImageUrl))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipped()
                                        .cornerRadius(64)
                                        .overlay(RoundedRectangle(cornerRadius: 64) .stroke(Color.black, lineWidth: 1))

                                    VStack {
                                        Text(recentMessage.email)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color(.label))
                                        Text(recentMessage.text)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(.darkGray))
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    Text(recentMessage.timeAgo)
                                        .font(.system(size: 14, weight: .semibold))
                                }
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
                        .frame(minWidth: 300, maxHeight: 80)
                        
                    }
                    , alignment: .bottom )
                
            }
           
        }
        .fullScreenCover(isPresented: $viewModel.isUserCurrentlyLoggedOut) {
            ContentView(didCompleteLoginProcess: { uid in
                StoragePhone.shared.setToken(uid)
                print(uid)
                self.viewModel.fetchCurrentUser(uid)
                self.viewModel.fetchRecentMessage()
            })
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView(viewModel.userUid ?? "", didSelectNewUser: {
                user in
                self.chatUser = user
                print("user id: \(user.id)")
                self.shouldNavigateToChatLogView.toggle()
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
