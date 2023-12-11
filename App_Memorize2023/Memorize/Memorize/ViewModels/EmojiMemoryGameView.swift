import SwiftUI
import Foundation
import AlertToast

struct EmojiMemoryGameView: View {
    

    
    @ObservedObject var viewModel: EmojiMemoryGame
    
    var body: some View {
        VStack {
            Grid(viewModel.cards) { card in
                CardView(card: card).onTapGesture {
                    viewModel.selectCard(card)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.chooseCardWithSimpleAI()
                        if let chosenIndex = viewModel.cards.firstIndex(where: { $0.id == card.id }) {
                            let reward: Double = viewModel.cards[chosenIndex].isMatched ? 1.0 : -0.1
                            viewModel.trainSimpleAI(reward: reward)
                        }
                    }
                }
                .padding(5)
            }
            .padding()
            .foregroundColor(Color.orange)
            
        }
        .onAppear {
            // Chama trainSimpleAI ao final do jogo, com base em uma recompensa acumulada
            viewModel.trainSimpleAI(reward: 1.0) // Exemplo de recompensa positiva
        }
    }
}

struct CardView: View {
    var card: MemoryGame<String>.Card
    
    var body: some View{
        GeometryReader { geometry in
            self.body(for: geometry.size)
          }
        }
        
        func body(for size: CGSize) -> some View {
            ZStack {
                if card.isFaceUp {
                    RoundedRectangle(cornerRadius: corneRadius).fill(Color.white)
                    RoundedRectangle(cornerRadius: corneRadius).stroke(lineWidth: edgeLineWidth)
                    Text(card.content)
                } else {
                    if !card.isMatched {
                        RoundedRectangle(cornerRadius: corneRadius).fill()
                    }
                }
            }
             .font(Font.system(size: fontSize(for: size)))
         }
            
    
    // Mark: - Drawing Constants
    
    let corneRadius: CGFloat = 10.0
    let edgeLineWidth: CGFloat = 3
    func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.75
    }
}
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            EmojiMemoryGameView(viewModel: EmojiMemoryGame())
        }
    }
