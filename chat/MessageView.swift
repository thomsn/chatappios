//
//  MessageView.swift
//  chat
//
//  Created by Matthew External on 2024-02-27.
//

import SwiftUI

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.author {
                Spacer()
            }
            Text(message.text).padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [.teal, .green]),
                                   startPoint: UnitPoint(x: 0, y: 1),
                                   endPoint: UnitPoint(x:1, y: 0)
                                  )
                ).cornerRadius(14).foregroundColor(.white)
            if !message.author {
                Spacer()
            }
        }
    }
}
