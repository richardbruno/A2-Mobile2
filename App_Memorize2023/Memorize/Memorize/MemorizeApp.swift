//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Sósthenes Oliveira Lima on 20/08/23.
//

import SwiftUI

@main
struct MemorizeApp: App { 
    var body: some Scene {
        WindowGroup {
            let game = EmojiMemoryGame()
            EmojiMemoryGameView(viewModel: game)
        }
    }
}
