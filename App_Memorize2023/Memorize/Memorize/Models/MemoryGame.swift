import Foundation
import SwiftUI

struct SimpleLogisticRegressionAgent<CardContent> where CardContent: Equatable {
    var weights: [Double]
    
    init(numberOfFeatures: Int) {
        // Inicializar os pesos do modelo
        weights = Array(repeating: 0.0, count: numberOfFeatures)
    }
    
    // Função de ativação logística
    func sigmoid(_ x: Double) -> Double {
        return 1.0 / (1.0 + exp(-x))
    }
    
    mutating func chooseCard(cards: [MemoryGame<CardContent>.Card]) -> MemoryGame<CardContent>.Card? {
        // Filtrar as cartas que não estão viradas para cima e não estão combinadas
        let faceDownAndUnmatchedCards = cards.filter { !$0.isFaceUp && !$0.isMatched }
        
        // Se não houver cartas viradas para baixo e não combinadas, retornar nil
        guard !faceDownAndUnmatchedCards.isEmpty else {
            return nil
        }
        
        // Calcular a probabilidade de cada carta ser uma correspondência
        var probabilities: [Double] = []
        
        for card in faceDownAndUnmatchedCards {
            var features = faceDownAndUnmatchedCards.map { $0.isFaceUp ? 1.0 : 0.0 }
            let index = faceDownAndUnmatchedCards.firstIndex { $0.id == card.id }!
            features[index] = 1.0
            let score = zip(features, weights).map { $0 * $1 }.reduce(0, +)
            probabilities.append(sigmoid(score))
        }
        
        // Escolher a carta ponderando pela probabilidade
        let totalProbability = probabilities.reduce(0, +)
        let weightedProbabilities = probabilities.map { $0 / totalProbability }
        
        // Selecionar uma carta com base nas probabilidades ponderadas
        let randomValue = Double.random(in: 0.0..<1.0)
        var cumulativeProbability: Double = 0.0
        
        for (index, weightedProbability) in weightedProbabilities.enumerated() {
            cumulativeProbability += weightedProbability
            if randomValue < cumulativeProbability {
                return faceDownAndUnmatchedCards[index]
            }
        }
        
        // Em caso de erro, retornar a primeira carta
        return faceDownAndUnmatchedCards.first
    }




    
    mutating func train(features: [Double], reward: Double) {
        let learningRate: Double = 0.1  // Ajuste isso conforme necessário
        
        for (index, feature) in features.enumerated() {
            let prediction = sigmoid(weights[index] * feature)
            let error = reward - prediction
            weights[index] += learningRate * error * feature
        }
    }
}



struct MemoryGame<CardContent> where CardContent: Equatable {
    var cards: Array<Card>
    var agent: SimpleLogisticRegressionAgent<CardContent>

    mutating func chooseCardWithSimpleAI() {
        if let aiChosenCard = agent.chooseCard(cards: cards) {
            choose(card: aiChosenCard)
            let features = cards.map { $0.isFaceUp ? 1.0 : 0.0 }
            agent.train(features: features, reward: 1.0)
        }
    }

    mutating func trainSimpleAI(reward: Double) {
        let features = cards.map { $0.isFaceUp ? 1.0 : 0.0 }
        agent.train(features: features, reward: reward)
    }

    var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get { cards.indices.filter { cards[$0].isFaceUp }.only }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = index == newValue
            }
        }
    }

    mutating func choose(card: Card) {
        print("card chosen: \(card)")
        if let chosenIndex = cards.firstIndex(matching: card), !cards[chosenIndex].isFaceUp, !cards[chosenIndex].isMatched {
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                self.cards[chosenIndex].isFaceUp = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
        }
    }

    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = Array<Card>()
        for pairIndex in 0..<numberOfPairsOfCards  {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
        }
        cards.shuffle()
        agent = SimpleLogisticRegressionAgent(numberOfFeatures: numberOfPairsOfCards * 2)
    }

    struct Card: Identifiable {
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var content: CardContent
        var id: Int
    }
}

