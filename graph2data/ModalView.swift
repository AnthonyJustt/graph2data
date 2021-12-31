//
//  ModalView.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 31.12.2021.
//

import SwiftUI

struct ModalView: View {
    @State  var spinCircle = false
    @Binding var showingModal: Bool
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .center, spacing: 16) {
                Circle()
                    .trim(from: 0.3, to: 1)
                    .stroke(lineWidth: 1)
                    .frame(width: 50, height: 50)
                    .padding(.all, 8)
                    .rotationEffect(.degrees(spinCircle ? 0 : -360), anchor: .center)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                            self.spinCircle = true
                        }
                    }
                
                Text("Operations are in progress")
                    .padding()
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .layoutPriority(1)
            }
            
            Spacer()
            
            Color.gray.frame(height: CGFloat(2) / UIScreen.main.scale)
            Text("OK")
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .onTapGesture(perform: {
                    print("OK")
                })
              //  .background(.thinMaterial)
            
            Color.gray.frame(height: CGFloat(2) / UIScreen.main.scale)
            Text("Cancel")
                .bold()
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .onTapGesture(perform: {
                    withAnimation(Animation.easeInOut(duration: 0.25)){
                        showingModal = false
                    }
                })
             //   .background(.thinMaterial)
        }
        .frame(minWidth: 250, idealWidth: 250, maxWidth: 300, minHeight: 260, idealHeight: 280, maxHeight: 320, alignment: .center)
        .background(.thinMaterial)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct ModalView_Previews: PreviewProvider {
    @State static var sM = true
    static var previews: some View {
        ModalView(showingModal: $sM)
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
