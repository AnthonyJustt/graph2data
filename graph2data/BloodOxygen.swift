//
//  BloodOxygen.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 29.11.2021.
//

import SwiftUI

struct BloodOxygen: View {
    
    @SceneStorage("isZooming") var isZooming: Bool = false
    
    @State private var bo_koef: Float = 3.14
    @State private var bo_start = 0
    @State private var bo_end = 0
    
    @State private var boDate = Date()
    
    @State private var arrayRes: [String] = []
    
    @ObservedObject var mediaItems = PickedMediaItems()
    
    @State private var photoPickerIsPresented = false
    @State private var showingHealthView = false
    
    @Environment(\.colorScheme) var colorScheme
    
    func changeArray() {
        //        for (index, _) in bo_values.enumerated() {
        //            bo_values[index].value = arrayRes[index]
        //        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    Image(systemName: "lungs")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.mint, Color.cyan)
                        .font(.system(size: 60))
                        .offset(y: isZooming ? -200 : 0)
                        .animation(.easeInOut, value: isZooming)
                    
                    HStack {
                        Button("Select Images...", action: {
                            photoPickerIsPresented = true
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                        
                        Button("Analyse Images", action: {
                            
                            for (index, item) in mediaItems.items.enumerated() {
                                
                                var croppeduiimage = cropImage(item.photo!, toRect: CGRect(x: 1000, y: 150, width: 400, height: 100), viewWidth: item.photo!.size.width, viewHeight: item.photo!.size.height)
                                
                                let sdate = detectTextWithVision(imageN: croppeduiimage!)
                                
                                print(sdate)
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "dd M yyyy"
                                boDate = dateFormatter.date(from: "\(sdate[0]) 2021")!
                                
                                print(boDate)
                                
                                croppeduiimage = cropImage(item.photo!, toRect: CGRect(x: 2200, y: 300, width: 100, height: 450), viewWidth: item.photo!.size.width, viewHeight: item.photo!.size.height)
                                
                                let bounds = detectTextWithVision(imageN: croppeduiimage!)
                                
                                print(bounds)
                                
                                let boHighestBound = Int(bounds[0].replacingOccurrences(of: "%", with: "")) ?? 0
                                let boMaxLevel = boHighestBound
                                let boLOwerBound = Int(bounds[0].replacingOccurrences(of: "%", with: ""))! - (Int(bounds[0].replacingOccurrences(of: "%", with: ""))! - Int(bounds[1].replacingOccurrences(of: "%", with: ""))!)*3
                                
                                mediaItems.items[index].changeFirstValues(newDate: boDate, newboLOwerBound: boLOwerBound, newboHighestBound: boHighestBound, newboMaxLevel: boMaxLevel)
                            }
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                            .opacity(mediaItems.items.count == 0 ? 0 : 1)
                    }
                    
                    if mediaItems.items.count > 0 {
                        TabView {
                            ForEach(mediaItems.items, id: \.id) { item in
                                VStack {
                                    GroupBoxView(boDate: item.date, boLOwerBound: item.boLOwerBound, boHighestBound: item.boHighestBound, boMaxLevel: item.boMaxLevel)
                                    if colorScheme == .dark {
                                        ImageView(uiImage: item.photo ?? UIImage())
                                            .colorInvert()
                                    } else {
                                        ImageView(uiImage: item.photo ?? UIImage())
                                    }
                                    Text("Start = \(item.boStart); End = \(item.boEnd); K = \(item.boKoef)\nBars Count = \(item.boValues.count)")
                                }
                            }
                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .frame(height: 515)
                    }
                    
                    HStack {
                        Button("1. get start", action: {
                            for (index, item) in mediaItems.items.enumerated() {
                                (bo_koef, bo_start, bo_end) = bo_getStartAndEndPoints(inputImage: item.photo!)
                                
                                mediaItems.items[index].changeSecondValues(newboKoef: bo_koef, newboStart: bo_start, newboEnd: bo_end)
                            }
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                        
                        Button("2. get pixel color", action: {
                            for (index, item) in mediaItems.items.enumerated() {
                                mediaItems.items[index].changeThirdValues(newboValues: bo_getBloodOxygen(inputImage: item.photo!, bo_start: item.boStart, bo_koef: item.boKoef))
                            }
                        })
                            .buttonStyle(customButton(fillColor: .cyan))
                    }
                    
                    Button("3. scan bars", action: {
                        //                        arrayRes = bo_scanBars(inputImage: pickerResult[0], bo_values: bo_values, boLOwerBound: boLOwerBound, boHighestBound: boHighestBound)
                        //                        changeArray()
                    })
                        .buttonStyle(customButton(fillColor: .cyan))
                    
                    if mediaItems.items.count > 0 {
                        ForEach(mediaItems.items, id: \.id) { item in
                            VStack {
                                DisclosureView(hubArray: item.boValues, DisclosureGroupName: "\(item.date.formatted(date: .long, time: .omitted))")
                                    .accentColor(.cyan)
                            }
                        }
                    }
                    
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
                        //                        let jsonEncoder = JSONEncoder()
                        //                        jsonEncoder.outputFormatting = .prettyPrinted
                        //                        do {
                        //                            let jsonData = try //jsonEncoder.encode([])//(bo_values)
                        //                            let jsonString = String(data: jsonData, encoding: .utf8)
                        //                            print("JSON String : " + jsonString!)
                        //
                        //                            saveToFile(fileName: "\(boDate.formatted(date: .numeric, time: .omitted)).json", fileContent: jsonString!)
                        //                        }
                        //                        catch {
                        //                        }
                    })
                        .padding()
                }
                .padding()
            }
            .navigationTitle(LocalizedStringKey("BloodOxygen.Title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                
                mediaItems.items = []
                bo_koef = 0
                bo_start = 0
                bo_end = 0
                boDate = Date()
                //                boLOwerBound = 75
                //                boHighestBound = 100
                //                boMaxLevel = 100
                //                arrayRes = []
                //                pickerResult = []
                //                bo_values = []
                
                
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
            
            .sheet(isPresented: $photoPickerIsPresented, content: {
                PhotoPicker(mediaItems: mediaItems)
                { didSelectItem in
                    if didSelectItem == true {
                        print("true")
                    } else
                    {
                        print("false")
                    }
                    photoPickerIsPresented = false
                }
                .ignoresSafeArea()
            })
            
            .sheet(isPresented: $showingHealthView) {
                HealthView(date: boDate, type: "Blood Oxygen", healthValues: [])//bo_values)
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
