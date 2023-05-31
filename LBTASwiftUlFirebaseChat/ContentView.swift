//
//  ContentView.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 5/29/23.
//

import SwiftUI



struct ContentView: View {
    @State private var isLoginMode = false
    @State private var email: String = ""
    @State private var password = ""
    @State private var shouldShowImagePicker = false
    @State private var image: UIImage?
    @State private var loginStatusMessage = ""
     var didCompleteLoginProcess: (String) -> ()
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Picker here", selection: $isLoginMode) {
                        Text("Login")
                            .tag(true)
                        Text("Create account")
                            .tag(false)
                        
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64) .stroke(Color.black, lineWidth: 3))
                           
                        }
                    }
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.none)
                            
                        SecureField("Password", text: $password)
                            
                    }
                    .padding(12)
                    .background(Color.white)
                    Button(action: handleAction) {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.vertical, 10)
                            Spacer()
                        }
                        .background(Color.blue)
                    }
                    Text(self.loginStatusMessage)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create account")
            
            .background(Color(white: 0, opacity: 0.05), ignoresSafeAreaEdges: .all)
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImagePicker(image: $image)
        }
    }
    
    private func persistImageStorage() {

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        print("get uid")
        guard let imageDate = image?.jpegData(compressionQuality: 0.5) else { return }
       
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        ref.putData(imageDate) { metadata, err in
            if let err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }
                self.loginStatusMessage = "Successfully stored image with url \(url?.absoluteString ?? "")"
                print(url?.absoluteString)
                if let url {
                    storeUserInformation(uid, imageProfileURL: url)
                } else {
                    loginStatusMessage = "Failed to stored user to firebase"
                }
                
            }
            self.didCompleteLoginProcess(uid)
        }
    }
    
    private func storeUserInformation(_ uid: String, imageProfileURL: URL) {

        
        let userData: [String: Any] = ["email": email, "uid": uid, "profileImageUrl": imageProfileURL.absoluteString]
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                
                if let err {
                    print(err)
                    self.loginStatusMessage = "Failed set data to firebase store\(err)"
                    return
                }
                print("Success")
            }
    }
    
    private func handleAction() {
       // storeUserInformation(imageProfileURL: URL(string: "pEG0dFNG60QXoDgmGI6ch9lEk093")!)
        if isLoginMode {
            loginUser()
//        print ("Should log into Firebase with existing credentials")
        } else {
            createAcount()
//            print ("Register a new account inside of Firebase Auth and then store image in Storage somehow...")
            
        }
    }
    
    private func loginUser() {
       
        FirebaseManager.shared.auth.signIn(withEmail: self.email, password: password) { res, err in
            if let err {
                self.loginStatusMessage = "Failed to login user: \(err) "
                return
            }
            self.didCompleteLoginProcess(res?.user.uid ?? "")
            self.loginStatusMessage = "Successfully logged in as user: \(res?.user.uid ?? "")"
           
        }
    }
    
    private func createAcount() {
        if image == nil {
            loginStatusMessage = "Please set image"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: self.email, password: self.password) { result, err in
            if let err {
                print("Failed to registered... \(err)")
                self.loginStatusMessage = "Failed to registered... \(err)"
                return
            }
           
            print("Successfully registered user: \(result?.user.uid ?? "")")
            persistImageStorage()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(didCompleteLoginProcess: { _ in
           
        })
    }
}
