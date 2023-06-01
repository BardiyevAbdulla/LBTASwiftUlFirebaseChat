//
//  CreateNewMessageView.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 5/31/23.
//

import SwiftUI
import SDWebImageSwiftUI


class CreateNewMessageViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var errorMassage = ""
   
    init(uid: String) {
        
        fetchData(uid)
    }
    
    func fetchData(_ uid: String) {
        FirebaseManager.shared.firestore.collection("users").getDocuments { snapshot, err in
            
            if let err {
                self.errorMassage = "Failed to fetch users: \(err)"
                print("Failed to fetch users: \(err)")
                return
            }
            snapshot?.documents.forEach({ doc in
                let data = doc.data()
                let user = ChatUser(data: data)
                if uid != user.uid {
                    self.users.append(.init(data: data))
                }
                
            })
            self.errorMassage = "Successfully fetch user data"
            
        }
    }
}

struct CreateNewMessageView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject  var viewModel: CreateNewMessageViewModel
    var uid: String
    let didSelectNewUser: (ChatUser) -> ()
    init(_ uid: String, didSelectNewUser: @escaping (ChatUser) -> ()) {
        self.uid = uid
        self.didSelectNewUser = didSelectNewUser
        viewModel = CreateNewMessageViewModel(uid: uid)
    }
    var body: some View {
        NavigationView {
            ScrollView{
                
                Text(viewModel.errorMassage)
                ForEach(viewModel.users) { user in
                    Button {
                        self.didSelectNewUser(user)
                        dismiss()
                    } label: {
                        HStack {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .clipped()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50) .stroke(Color.black, lineWidth: 2))
                                .padding(.trailing)
                            Text(user.email)
                            Spacer()
                        }.padding(.horizontal)
                    }

                   
                    Divider()
                }
            }
            .navigationTitle("New Messsage")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
      
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewMessageView("RdGjqgMJX4XNL6ApbSukLmc3iNg2", didSelectNewUser: {
            _ in
        })
    }
}
