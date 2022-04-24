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
    
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            Circle()
                .trim(from: 0.3, to: 1)
                .stroke(lineWidth: 1)
                .frame(width: 50, height: 50)
                .padding()
                .rotationEffect(.degrees(spinCircle ? 0 : -360), anchor: .center)
                .onAppear {
                    withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                        self.spinCircle = true
                    }
                }
                .foregroundColor(Color("AccentColor"))
            
            Text("Operations are in progress")
                .padding()
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .layoutPriority(1)
            
            ProgressView("Image % of \(GlobalVars.boImagesCount)", value: Double(2), total: Double(10))
                .accentColor(Color("AccentColor"))
                .padding()
            
            Text("\(model.boCurrentProgress)")
                .onChange(of: model.boCurrentProgress) { newValue in
                    print(newValue)
                }
            
            Text("\(Model.shared.boCurrentProgress)")
                .onChange(of: Model.shared.boCurrentProgress) { newValue in
                    DispatchQueue.main.async {
                    print("new value is \(newValue)")
                    }
                }
            
            ProgressView("Current progress", value: Double(2), total: Double(10))
                .accentColor(Color("AccentColor"))
                .padding()
            
            Spacer()
            
            //            Color.gray.frame(height: CGFloat(2) / UIScreen.main.scale)
            //            Text("OK")
            //                .padding()
            //                .frame(minWidth: 0, maxWidth: .infinity)
            //                .onTapGesture(perform: {
            //                    print("OK")
            //                })
            
            Color.gray.frame(height: CGFloat(2) / UIScreen.main.scale)
            Button(action: {
                withAnimation(Animation.easeInOut(duration: 0.25)){
                    showingModal = false
                }
            }, label: {
                Text("Cancel")
                    .bold()
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(Color.primary)
            })
        }
        .frame(minWidth: 240, idealWidth: 240, maxWidth: 260, minHeight: 320, idealHeight: 320, maxHeight: 360, alignment: .center)
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
            .environmentObject(Model())
//                    .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
