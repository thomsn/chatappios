//
//  AccountView.swift
//  chat
//
//  Created by Matthew External on 2024-02-27.
//

import SwiftUI


struct AccountView: View {
    @ObservedObject var accountViewModel: AccountViewModel
    @StateObject var messageViewModel = MessageViewModel()
    @State var newMessageText: String = ""
    
    var body: some View {
        VStack (alignment: .center) {
            Text("Chat App Tutorial").font(.title)
            if let accountRef = accountViewModel.ref {
                ScrollView () {
                    ForEach(messageViewModel.messages) { message in
                        MessageView(message: message)
                    }
                    VoiceView(accountRef: accountRef, messageViewModel: messageViewModel)
                }.defaultScrollAnchor(.bottom)
                    .onAppear {
                        messageViewModel.getMessages(accountRef: accountRef)
                    }
                TextField("Message", text: $newMessageText, axis: .vertical).onSubmit {
                    messageViewModel.newMessage(accountRef: accountRef, text: newMessageText)
                    newMessageText.removeAll()
                }
            }
        }.padding().padding()
    }
}
