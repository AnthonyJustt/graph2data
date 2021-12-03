//
//  BloodOxygen.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 29.11.2021.
//

import SwiftUI

private var bo_koef: Float = 3.14
private var bo_start = 0

struct BloodOxygen: View {
    
    @State private var boLOwerBound = 75
    @State private var boHighestBound = 100
    @State private var boMaxLevel = 100
    let range = 0...100
    
    @State private var boDate = Date()
    // Дата на изображении, определятеся с помощью Vision позднее, либо задается вручную
    
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var values: [heartRateItem] = []
    
    @Environment(\.colorScheme) var colorScheme
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Image(systemName: "lungs")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.mint, Color.cyan)
                        .font(.system(size: 60))
                    
                    GroupBox {
                        DatePicker(selection: $boDate, in: ...Date(), displayedComponents: .date) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                                    .font(.title2)
                                Text("Date")
                            }
                        }
                        
                        Divider()
                        Stepper(value: $boLOwerBound, in: range, step: 1) {
                            HStack {
                                Image(systemName: "arrow.down.to.line")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.blue, .pink)
                                    .font(.title2)
                                Text("Lower bound is \(boLOwerBound)%")
                            }
                        }
                        Divider()
                        Stepper(value: $boHighestBound, in: range, step: 1) {
                            HStack {
                                Image(systemName: "arrow.up.to.line")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.purple, .pink)
                                    .font(.title2)
                                Text("Highest bound is \(boHighestBound)%")
                            }
                        }
                        Divider()
                        Stepper(value: $boMaxLevel, in: range, step: 1) {
                            HStack {
                                Image(systemName: "arrow.up.square")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                Text("Max level is \(boMaxLevel)%")
                            }
                        }
                    }
                    
                    Button("Import Image", action: {
                        self.showingImagePicker = true
                    })
                        .buttonStyle(customButton(fillColor: .cyan))
                    
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    }
                    
                    if colorScheme == .dark {
                        Image("IMG2")
                            .resizable()
                            .scaledToFit()
                            .colorInvert()
                    } else {
                        Image("IMG2")
                            .resizable()
                            .scaledToFit()
                    }
                    
                    HStack {
                        Button("get pixel color", action: {
                            bo_getBloodOxygen()
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                        
                        Button("get start", action: {
                            bo_getStartAndEndPoints()
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                    }
                    
                    Button("scan bars", action: {
                        bo_scanBars(array: values)
                    })
                        .buttonStyle(customButton(fillColor: .cyan))
                    
                    DisclosureView(hubArray: values, DisclosureGroupName: "\(boDate.formatted(date: .long, time: .omitted))")
                        .accentColor(.cyan)
                    
                    Button(action: {
                        print("Export to Apple Health")
                    }, label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            //                                .symbolRenderingMode(.palette)
                            //                                .foregroundStyle(.green, .cyan)
                                .foregroundColor(.secondary)
                                .font(.title2)
                            Spacer()
                            Text(LocalizedStringKey("MainView.ExportToAppleHealth"))
                            Spacer()
                        }
                    })
                        .buttonStyle(customButton(fillColor: .cyan))
                }
                .padding()
            }
            .navigationTitle(LocalizedStringKey("BloodOxygen.Title"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
        }
    }
}

struct BloodOxygen_Previews: PreviewProvider {
    static var previews: some View {
        BloodOxygen()
        // .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
