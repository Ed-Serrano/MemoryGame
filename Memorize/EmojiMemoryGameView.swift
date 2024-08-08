import SwiftUI

struct EmojiMemoryGameView: View {
    typealias Card = MemoryGame<String>.Card
    @ObservedObject var viewModel: EmojiMemoryGame
    //Keyword tells us if something changes, redraw me
    
    private let aspectRatio: CGFloat = 2/3
    
    var body: some View {
        VStack{
            title.padding(.maximum(0, 15))
                cards
                    .foregroundColor(Color.blue)
                    //value waits for the appropriate action before animating
            HStack{
                score
                Spacer()
                deck.foregroundColor(.blue)
                Spacer()
                shuffle
            }
            .font(Font.largeTitle)
            

        }
        .padding()
    }
    
    var title: some View{
        Text("Memorize!")
            .bold()
            .font(.largeTitle)
            .foregroundColor(.blue)
    }
    
    private var score: some View {
        Text("Score: \(viewModel.score)")
            .animation(nil)
    }
    
    //@State private var isDisabled = false
    private var shuffle: some View {
        Button("Shuffle!"){
            //isDisabled = true
            withAnimation() {
                viewModel.shuffle()
                //This is an intent
            }
        }
//        .disabled(isDisabled)
//        .padding(8)
//        .background(isDisabled ? .gray : .blue)
//        .foregroundColor(.white)
        
    }
    
    @ViewBuilder
    private var cards: some View{
        AspectVGrid(viewModel.cards, aspectRatio: aspectRatio) { card in
            if isDealt(card) {
                CardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
                    .padding(4)
                    .overlay(FlyingNumber(number: scoreChange(causedBy: card)))
                //Flying number will animate overlayed on the card
                    .zIndex(scoreChange(causedBy: card) != 0 ? 1 : 0)
                    .onTapGesture {
                        choose(card)
                    }
                    
            }
        }
        
    }
    
    
    @State private var dealt = Set<Card.ID>()
    
    private func isDealt(_ card: Card) -> Bool {
        dealt.contains(card.id)
    }
    private var undealtCards: [Card] {
        viewModel.cards.filter { !isDealt($0) }
    }
    
    @Namespace private var dealingNamespace
    
    private var deck: some View {
        ZStack {
            ForEach(undealtCards) { card in
                CardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
            }
            
        }
        .frame(width: deckWidth, height: deckWidth / aspectRatio)
        .onTapGesture {
            deal()
        }
    }
    
    private func deal() {
        // deal the cards
        var delay: TimeInterval = 0
        for card in viewModel.cards {
            withAnimation(dealAnimation.delay(delay)) {
                _ = dealt.insert(card.id)
            }
            delay += dealInterval
        }
    }
    
    private let dealAnimation: Animation = .easeIn(duration: 1)
    private let dealInterval: TimeInterval = 0.15
    private let deckWidth: CGFloat = 50
    
    private func choose(_ card: Card) {
        withAnimation() {
            let scoreBeforeChoosing = viewModel.score
            viewModel.choose(card)
            let scoreChange = viewModel.score - scoreBeforeChoosing
            lastScoreChange = (scoreChange, causedByCardId: card.id)
        }
    }
    
    @State private var lastScoreChange = (0, causedByCardId: "")
            
    private func scoreChange(causedBy card: Card) -> Int {
        let (amount, id) = lastScoreChange
        return card.id == id ? amount : 0
    }
}


#Preview {
    EmojiMemoryGameView(viewModel: EmojiMemoryGame())
}






//You are allows to click each card once. If you click it again and miss, you lose points.
