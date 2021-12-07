//
//  BloodOxygen.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 29.11.2021.
//

import SwiftUI



struct BloodOxygen: View {
    
    @State private var bo_koef: Float = 3.14
    @State private var bo_start = 0
    @State private var bo_end = 0
    
    @State private var boLOwerBound = 75
    @State private var boHighestBound = 100
    @State private var boMaxLevel = 100
    let range = 0...100
    
    @State private var arrayRes: [String] = []
    
    @State private var boDate = Date()
    // Дата на изображении, определятеся с помощью Vision позднее, либо задается вручную
    
    @State private var photoPickerIsPresented = false
    @State var pickerResult: [UIImage] = []
    
    @State private var bo_values: [healthItem] = []
    
    @State private var showingHealthView = false
    
    @Environment(\.colorScheme) var colorScheme
    
    
    func changeArray() {
        for (index, _) in bo_values.enumerated() {
            bo_values[index].value = arrayRes[index]
        }
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
                    
                    Text("bo_start = \(bo_start)\nbo_end = \(bo_end)\nbo_koef = \(bo_koef)\n---\nbo_barsCount = \(bo_values.count)")
                    
                    HStack {
                        Button("0. Import Image", action: {
                            photoPickerIsPresented = true
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                        
                        Button("Crop Image", action: {
                         var croppeduiimage = cropImage(pickerResult[0], toRect: CGRect(x: 1000, y: 150, width: 400, height: 100), viewWidth: pickerResult[0].size.width, viewHeight: pickerResult[0].size.height)
                            
                            pickerResult.append(croppeduiimage!)
                            
                           print( detectTextWithVision(imageN: croppeduiimage!))
                            
                             croppeduiimage = cropImage(pickerResult[0], toRect: CGRect(x: 2200, y: 300, width: 100, height: 450), viewWidth: pickerResult[0].size.width, viewHeight: pickerResult[0].size.height)
                               
                               pickerResult.append(croppeduiimage!)
                            
                           print( detectTextWithVision(imageN: croppeduiimage!))
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                    }
                    
                    TabView {
                        Text("777")
                            .opacity(pickerResult.count == 0 ? 1 : 0)
                        ForEach(pickerResult, id: \.self) { uiImage in
                            if colorScheme == .dark {
                                ImageView(uiImage: uiImage)
                                    .colorInvert()
                            } else {
                                ImageView(uiImage: uiImage)
                            }
                        }
                        .padding()
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .frame(height: 200)
                    
                    HStack {
                        Button("1. get start", action: {
                            (bo_koef, bo_start, bo_end) = bo_getStartAndEndPoints(inputImage: pickerResult[0])
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                        
                        Button("2. get pixel color", action: {
                            bo_values = bo_getBloodOxygen(inputImage: pickerResult[0], bo_start: bo_start, bo_koef: bo_koef)
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                    }
                    
                    Button("3. scan bars", action: {
                        arrayRes = bo_scanBars(inputImage: pickerResult[0], bo_values: bo_values, boLOwerBound: boLOwerBound, boHighestBound: boHighestBound)
                        changeArray()
                    })
                        .buttonStyle(customButton(fillColor: .cyan))
                    
                    DisclosureView(hubArray: bo_values, DisclosureGroupName: "\(boDate.formatted(date: .long, time: .omitted))")
                        .accentColor(.cyan)
                    
                    Button(action: {
                        print("Export to Apple Health")
                        showingHealthView.toggle()
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
                    
                    
                    Button("Save to File", action: {
//                        var s: String = ""
//                        var ss: String = ""
//                        for item in bo_values {
//                            ss = "bo,\(item.id),\(item.x),\(item.y), \(item.date),\(item.value)\n"
//                            s = s + ss
//                        }
//                        saveToFile(fileName: "date.txt", fileContent: s)
                        
                        
                        let jsonEncoder = JSONEncoder()
                        jsonEncoder.outputFormatting = .prettyPrinted
                        do {
                            let jsonData = try jsonEncoder.encode(bo_values)
                            let jsonString = String(data: jsonData, encoding: .utf8)
                            print("JSON String : " + jsonString!)
                            
                            saveToFile(fileName: "\(boDate.formatted(date: .numeric, time: .omitted)).json", fileContent: jsonString!)
                        }
                        catch {
                        }
                    })
                        .padding()
                }
                .padding()
            }
            .navigationTitle(LocalizedStringKey("BloodOxygen.Title"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $photoPickerIsPresented) {
                PhotoPicker(pickerResult: $pickerResult,
                            isPresented: $photoPickerIsPresented)
            }
            .sheet(isPresented: $showingHealthView) {
                HealthView(date: boDate, type: "Blood Oxygen", healthValues: bo_values)
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
