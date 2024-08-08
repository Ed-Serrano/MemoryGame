import SwiftUI

//ObservableObject makes UI reactive
class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    private static let emojis = ["⚽️","🏀","🏈","⚾️","🎱","🏓","🏉","🏐","🏒","🥍"]
    // Static keywords are type variables
    // Giving them global control
    private static func createMemoryGame() -> MemoryGame<String> {
        return MemoryGame(numberOfPairsOfCards: 8) { pairIndex in
            if emojis.indices.contains(pairIndex){
                return emojis[pairIndex]
            } else {
                return "🙊"
            }
        } 
            
    }
    
    @Published private var model = createMemoryGame()
    //Published keyword means make something changed happened
    
    var cards: Array<Card> {
        return model.cards
    }
    
    var score: Int {
        model.score
    }
    
    
    // Mark: - Intents
    
    func shuffle(){
        model.shuffle()
    }
    
    
    // _ : This makes it sort of like a generic
    func choose(_ card: Card){
        model.choose(card)
    }
}
