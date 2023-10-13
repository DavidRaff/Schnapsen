//
//  ContentView.swift
//  Schnapsen
//
//  Created by David Laczkovits on 10.10.23.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var viewController = Controller()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image(.backgroundCloth)
                    .resizable()
                    .scaledToFill()
                VStack {
                    if viewController.atout != "" {
                        Text("Atout: \(viewController.atout)")
                            .padding(.top, 60)
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    HStack {
                        Text("Punkte Spieler \(viewController.player.points)")
                        Spacer()
                        Text("\(viewController.pc.points) Punkte PC")
                    }
                    .foregroundStyle(.white)
                    .font(.title3)
                    .padding(.leading, 20)
                    .padding(.trailing, 60)
                    .shadow(color: .black, radius: 10)
                    .padding(.top, -15)
                    
                    Spacer()
                    VStack {
                        HStack {
                            Image("back")
                            Image("back")
                        }
                        .frame(height: 5)
                        
                        HStack {
                            Image("back")
                            Image("back")
                            Image("back")
                        }
                        .frame(height: 5)
                    }
                    .padding(.bottom, 80)
                    .frame(height: 100)
                    
                    VStack {
                        HStack {
                            Image(viewController.currentPlayerCard.card)
                            Image(viewController.currentPcCard.card)
                        }
                        .padding(.top, 10)
                        
                        HStack {
                            Button("20 Ansagen") {
                                viewController.call20()
                            }
                            .disabled(viewController.call20disabled)
                            Spacer()
                            Button("40 Ansagen") {
                                viewController.call40()
                            }
                            .disabled(viewController.call40disabled)
                        }
                        .foregroundStyle(.white)
                        .font(.title)
                        .padding([.leading, .trailing], 20)
                        .padding(.top, -10)
                        .shadow(color: .black, radius: 10)
                    }
                    .padding(.bottom, 130)
                    
                    VStack {
                        HStack {
                            CardImageView(viewController: viewController, index: 0)
                            CardImageView(viewController: viewController, index: 1)
                            CardImageView(viewController: viewController, index: 2)
                        }
                        .frame(height: 150)
                        HStack {
                            CardImageView(viewController: viewController, index: 3)
                            CardImageView(viewController: viewController, index: 4)
                        }
                        .frame(height: 80)
                    }
                    .padding(.top, -110)
                }
            }
            .ignoresSafeArea()
            .task {
                viewController.newGame()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            viewController.newGame()
                        }
                    } label: {
                        Image(systemName: "plus.rectangle.fill")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
            }
        }
    }
}


#Preview {
    MainView(viewController: Controller())
}

