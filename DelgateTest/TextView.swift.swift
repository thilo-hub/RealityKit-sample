{
    @State private var text = ""
    
    var body: some View {
        VStack {
            Text("Type something in the box below")
            Text("Current count: \(self.text.count)")
            TextView(text: self.$text)
                .border(Color.gray).padding()
        }.navigationBarTitle("UITextView example")
    }
}
