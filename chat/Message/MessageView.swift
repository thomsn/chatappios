//
//  MessageView.swift
//  chat
//
//  Created by Matthew External on 2024-02-27.
//

import SwiftUI

struct MessageView: View {
    let message: Message
    let minLength = 30.0
    
    var body: some View {
        HStack {
            if message.author {
                Spacer(minLength: minLength)
            }
            Text(message.text).padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: message.author ? [.teal, .green]:[.blue, .teal]),
                                   startPoint: UnitPoint(x: 0, y: 1),
                                   endPoint: UnitPoint(x:1, y: 0)
                                  )
                ).cornerRadius(14).foregroundColor(.white)
            if !message.author {
                Spacer(minLength: minLength)
            }
        }
    }
}
