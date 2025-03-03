import SwiftUI

struct LetterRowView: View {
    let letter: Letter
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(letter.title)
                .font(.headline)
            Text(letter.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
} 