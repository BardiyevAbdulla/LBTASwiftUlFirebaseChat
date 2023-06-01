//
//  ChatLogView.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 6/1/23.
//

import SwiftUI
import Firebase

class ChatLogViewModel: ObservableObject {
    let fromId: String
    let chatUser: ChatUser?
    @Published var chatText: String = ""
    @Published var errorMassage:String = ""
    @Published var chatMessages: [ChatMessage] = []
    
    init(userid: String, chatUser: ChatUser?) {
        self.fromId = userid
        self.chatUser = chatUser
        fetchMessages()
    }
    
    func sendData() {
        guard chatText.count > 1 else { return }
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection(FirebaseConstant.messages)
            .document(fromId)
            .collection(toId)
            .document()
        let message: [String: Any] = [FirebaseConstant.fromId: fromId, FirebaseConstant.toId: toId, FirebaseConstant.text : chatText, FirebaseConstant.timestamp: Timestamp()]
        document.setData(message) { error in
            if let error {
                self.errorMassage = "Failed to save to Firebase store \(error)"
                return
            }
            self.chatText = ""
            print("Successfully saved current user sending message")
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        recipientMessageDocument.setData(message) { err in
            if let err {
                self.errorMassage = "Failed to save to Firebase store \(err)"
                return
            }
            print ("Recipient saved message as well")
        }
        
    }
    
    func fetchMessages() {
        guard let toId = chatUser?.uid else { return }
        FirebaseManager.shared.firestore
            .collection(FirebaseConstant.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstant.timestamp)
            .addSnapshotListener { querySnapshot, err in
                if let err {
                    self.errorMassage = "Failed to fetch chats \(err)"
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        let docId = change.document.documentID
                        self.chatMessages.append(ChatMessage(docId: docId, data: data))
                    }
                   
                })
            }
    }
    
}


struct ChatLogView: View {
    var chatUser: ChatUser?
    var userId: String
    @ObservedObject var viewModel: ChatLogViewModel
    init(chatUser: ChatUser? = nil, userId: String) {
        self.chatUser = chatUser
        self.userId = userId
        self.viewModel = .init(userid: userId, chatUser: chatUser)
    }
    var body: some View {
        ZStack {
            
            Text(viewModel.errorMassage)
            messageView
                .background(Color.init(white: 0.9, opacity: 1))
                .navigationTitle(chatUser?.email ?? "")
        }
        
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messageView: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.chatMessages) { message in
                    HStack {
                        if message.toId == self.userId {
                            
                            HStack {
                                Text (message.text)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            Spacer()
                        } else {
                            Spacer()
                            HStack {
                                Text (message.text)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                           
                        }
                       
                        
                    }
                    .padding(.horizontal)
                }
                
                HStack(content: {
                    Spacer()
                })
               
                .background(Color(white: 0.4, opacity: 1))
               
                }
            .safeAreaInset(edge: .bottom) {
                chatBottomBar
                    .background(Color.white.ignoresSafeArea())
            }
        }
       
    }
    
    private var chatBottomBar: some View {
        HStack {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
                .lineLimit(0)
           
            TextField("Description", text: $viewModel.chatText)
            
            Button {
                viewModel.sendData()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(8)

        }
        .padding()
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(chatUser: ChatUser(data: ["uid" : "ASDfwekrsdvse3545nasldkf", "email" : "abdulla.bardiyev98@mail.ru", "profileImageUrl" : "https//www.ok.ru"]), userId: "RdGjqgMJX4XNL6ApbSukLmc3iNg2")
        }
    }
}
