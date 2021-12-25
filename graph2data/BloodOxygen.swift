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
    
    @State private var arrayimageData: [bo_imageData] = []
    
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
                    
                    HStack {
                        Button("Select Images...", action: {
                            photoPickerIsPresented = true
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                        
                        Button("Analyse Images", action: {
                            
                            for item in pickerResult {
                                
                                var croppeduiimage = cropImage(item, toRect: CGRect(x: 1000, y: 150, width: 400, height: 100), viewWidth: pickerResult[0].size.width, viewHeight: pickerResult[0].size.height)
                                
                                let sdate = detectTextWithVision(imageN: croppeduiimage!)
                                
                                print(sdate)
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "dd M yyyy"
                                boDate = dateFormatter.date(from: "\(sdate[0]) 2021")!
                                
                                print(boDate)
                                
                                croppeduiimage = cropImage(item, toRect: CGRect(x: 2200, y: 300, width: 100, height: 450), viewWidth: pickerResult[0].size.width, viewHeight: pickerResult[0].size.height)
                                
                                let bounds = detectTextWithVision(imageN: croppeduiimage!)
                                
                                print(bounds)
                                
                                boHighestBound = Int(bounds[0].replacingOccurrences(of: "%", with: "")) ?? 0
                                boMaxLevel = boHighestBound
                                boLOwerBound = Int(bounds[0].replacingOccurrences(of: "%", with: ""))! - (Int(bounds[0].replacingOccurrences(of: "%", with: ""))! - Int(bounds[1].replacingOccurrences(of: "%", with: ""))!)*3
                                
                                arrayimageData.append(bo_imageData(date: boDate, boLOwerBound: boLOwerBound, boHighestBound: boHighestBound, boMaxLevel: boMaxLevel))
                            }
                            
                            print(arrayimageData)
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                            .opacity(pickerResult.count == 0 ? 0 : 1)
                    }
                    
                    if pickerResult.count > 0 {
                        TabView {
                            ForEach(pickerResult, id: \.self) { uiImage in
                                VStack {
                                    GroupBoxView(boLOwerBound: 0, boHighestBound: 0, boMaxLevel: 0)
                                    if colorScheme == .dark {
                                        ImageView(uiImage: uiImage)
                                            .colorInvert()
                                    } else {
                                        ImageView(uiImage: uiImage)
                                    }
                                    Text("Start = \(bo_start); End = \(bo_end); K = \(bo_koef)\nBars Count = \(bo_values.count)")
                                }
                            }
                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .frame(height: 515)
                    }
                    
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
            .navigationBarItems(trailing:
                                    Button(action: {


                bo_koef = 0
                bo_start = 0
                bo_end = 0
                boLOwerBound = 75
                boHighestBound = 100
                boMaxLevel = 100
                arrayRes = []
                boDate = Date()
                pickerResult = []
                bo_values = []


            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(Font.title2)
                    .foregroundColor(.cyan)
            })
            
//            .safeAreaInset(edge: .top) {
//                HStack {
//                    Image(systemName: "arrow.clockwise.circle.fill")
//                    Spacer()
//                    Image(systemName: "arrow.clockwise.circle.fill")
//                }
//                .overlay(Text("text"))
//                .padding()
//
//                    .background(.ultraThinMaterial)
//            }
            
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
