import SwiftUI

@main
struct DeductlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = DeductlyViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Deductly")
                    .font(.largeTitle).bold()

                Text("Scan receipts. Find tax deductions.")
                    .foregroundColor(.gray)

                Button(action: viewModel.startScan) {
                    HStack {
                        Image(systemName: "camera.viewfinder")
                        Text("Scan Receipt")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                List(viewModel.deductions) { deduction in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(deduction.category)
                                .font(.headline)
                            Text(deduction.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(String(format: "£%.2f", deduction.amount))
                            .foregroundColor(.green)
                    }
                }

                NavigationLink(destination: ChatView(viewModel: viewModel)) {
                    Text("Ask the AI Assistant")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct ChatView: View {
    @ObservedObject var viewModel: DeductlyViewModel
    @State private var message: String = ""

    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.messages) { msg in
                    HStack {
                        if msg.isUser {
                            Spacer()
                            Text(msg.text)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        } else {
                            Text(msg.text)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                }
            }

            HStack {
                TextField("Type a message...", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    viewModel.send(message)
                    message = ""
                }
            }
            .padding()
        }
        .navigationTitle("Tax Assistant")
    }
}

class DeductlyViewModel: ObservableObject {
    struct Deduction: Identifiable {
        let id = UUID()
        let category: String
        let amount: Double
        let date: Date
    }

    struct Message: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
    }

    @Published var deductions: [Deduction] = []
    @Published var messages: [Message] = []

    func startScan() {
        let mock = Deduction(category: "Office Supplies", amount: 42.99, date: Date())
        deductions.append(mock)
    }

    func send(_ text: String) {
        messages.append(Message(text: text, isUser: true))
        let reply = Message(text: "Got it! I've logged this as a deduction.", isUser: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.messages.append(reply)
        }
    }
}
