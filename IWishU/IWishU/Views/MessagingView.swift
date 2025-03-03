import SwiftUI

struct MessagingView: View {
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var isTyping = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .slide),
                                        removal: .opacity
                                    ))
                            }
                        }
                    }
                    .rotationEffect(.degrees(180))
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                HStack {
                    TextField("Message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: messageText) { _ in
                            withAnimation(.spring()) {
                                isTyping = !messageText.isEmpty
                            }
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(isTyping ? 0 : -90))
                            .scaleEffect(isTyping ? 1.1 : 1.0)
                            .animation(.spring(), value: isTyping)
                    }
                }
                .padding()
            }
            .navigationTitle("Messages")
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        withAnimation(.spring()) {
            let newMessage = Message(
                content: messageText,
                isFromCurrentUser: true,
                timestamp: Date()
            )
            messages.append(newMessage)
            messageText = ""
        }
    }
}

struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.isFromCurrentUser == rhs.isFromCurrentUser &&
        lhs.timestamp == rhs.timestamp
    }
} 