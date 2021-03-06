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
    
    @StateObject var mediaItems = PickedMediaItems()
    
    @State private var photoPickerIsPresented = false
    @State private var showingHealthView = false
    
    @State var showingModal: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    let queue = DispatchQueue.global()
    @State private var item: DispatchWorkItem = DispatchWorkItem { }
    
    @State private var getStartButton = false
    @State private var getBarsButton = false
    @State private var scanBarsButton = false
    @State private var exportToHealthButton = false
    
    @State private var errorText: String = ""
    
    @EnvironmentObject var model: Model
    
    @State private var boLOwerBound: Int = 0
    @State private var boHighestBound: Int = 0
    @State private var boMaxLevel: Int = 0
    
    func refresh() {
        mediaItems.items = []
        bo_koef = 0
        bo_start = 0
        bo_end = 0
        boDate = Date()
        getStartButton = false
        getBarsButton = false
        scanBarsButton = false
        exportToHealthButton = false
        errorText = ""
        boLOwerBound = 0
        boHighestBound = 0
        boMaxLevel = 0
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack {
                        
                        HeaderView(imageName: "lungs", accentColor: .cyan, additionalColor: .mint, isZooming: $isZooming, photoPickerIsPresented: $photoPickerIsPresented, mediaItems_Items_Count: mediaItems.items.count, analyseAction: {
                            item = DispatchWorkItem {
                                GlobalVars.boImagesCount = mediaItems.items.count
                                print(GlobalVars.boImagesCount)
                                withAnimation(Animation.easeOut){
                                    showingModal = true
                                }
                                let date = Date()
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy"
                                let yearString = dateFormatter.string(from: date)
                                print(yearString)
                                errorText = ""
                                if item.isCancelled != true {
                                    for (index, item) in mediaItems.items.enumerated() {
                                        
                                        var croppeduiimage = cropImage(item.photo!, toRect: CGRect(x: 1000, y: 150, width: 400, height: 100), viewWidth: item.photo!.size.width, viewHeight: item.photo!.size.height)
                                        
                                        let sdate = detectTextWithVision(imageN: croppeduiimage!)
                                        
                                        print(sdate)
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "dd M yyyy"
                                        
                                        if sdate.count > 0 {
                                            if dateFormatter.date(from: "\(sdate[0]) \(yearString)") == nil {
                                                boDate = Date()
                                                errorText += "Image #\(index+1): Date wasn't recognized"
                                            } else {
                                                boDate = dateFormatter.date(from: "\(sdate[0]) \(yearString)")!
                                            }
                                        } else {
                                            boDate = Date(timeIntervalSince1970: 0)
                                            errorText += "Image #\(index+1): There is no date"
                                        }
                                        
                                        
                                        
                                        //                                        boDate = dateFormatter.date(from: "\(sdate[0]) \(yearString)") ?? Date()
                                        
                                        print(boDate)
                                        
                                        croppeduiimage = cropImage(item.photo!, toRect: CGRect(x: 2200, y: 300, width: 100, height: 450), viewWidth: item.photo!.size.width, viewHeight: item.photo!.size.height)
                                        
                                        let bounds = detectTextWithVision(imageN: croppeduiimage!)
                                        
                                        print(bounds)
                                        
                                        if bounds.count > 1 {
                                            boHighestBound = Int(bounds[0].replacingOccurrences(of: "%", with: "")) ?? 0
                                            boMaxLevel = boHighestBound
                                            boLOwerBound = (Int(bounds[0].replacingOccurrences(of: "%", with: "")) ?? 0) - ((Int(bounds[0].replacingOccurrences(of: "%", with: "")) ?? 0) - (Int(bounds[1].replacingOccurrences(of: "%", with: "")) ?? 0))*3
                                        }else {
                                            errorText += "Image #\(index+1): There are no bounds"
                                        }
                                        
                                        mediaItems.items[index].changeCommonValues(newDate: boDate)
                                        
                                        mediaItems.items[index].changeFirstboValues(newboLOwerBound: boLOwerBound, newboHighestBound: boHighestBound, newboMaxLevel: boMaxLevel)
                                    }
                                }
                                withAnimation(Animation.easeIn){
                                    showingModal = false
                                }
                            }
                            queue.async(execute: item)
                            
                            getStartButton = true
                        }, errorText: errorText)
                        
                        if mediaItems.items.count > 0 {
                            TabView {
                                ForEach($mediaItems.items, id: \.id) { $item in
                                    VStack {
                                        GroupBoxViewBO(boDate: $item.date, boLOwerBound: $item.boLOwerBound, boHighestBound: $item.boHighestBound, boMaxLevel: $item.boMaxLevel)
                                        if colorScheme == .dark {
                                            ImageView(uiImage: item.photo ?? UIImage())
                                                .colorInvert()
                                        } else {
                                            ImageView(uiImage: item.photo ?? UIImage())
                                        }
                                        Text("Start = \(item.boStart); End = \(item.boEnd); K = \(item.boKoef)\nBars Count = \(item.hiValues.count)")
                                    }
                                }
                            }
                            .tabViewStyle(.page)
                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                            .frame(height: 515)
                        }
                        
                        VStack {
                            if getStartButton {
                                Button("Get Start & End Points", action: {
                                    item = DispatchWorkItem {
                                        showingModal = true
                                        if item.isCancelled != true {
                                            for (index, item) in mediaItems.items.enumerated() {
                                                (bo_koef, bo_start, bo_end) = bo_getStartAndEndPoints(inputImage: item.photo!)
                                                
                                                mediaItems.items[index].changeSecondValues(newboKoef: bo_koef, newboStart: bo_start, newboEnd: bo_end)
                                            }
                                        }
                                        showingModal = false
                                    }
                                    
                                    queue.async(execute: item)
                                    getBarsButton = true
                                })
                                .buttonStyle(customButton(fillColor: .cyan))
                            }
                            
                            if getBarsButton {
                                Button("Get Bars", action: {
                                    item = DispatchWorkItem {
                                        showingModal = true
                                        if item.isCancelled != true {
                                            for (index, item) in mediaItems.items.enumerated() {
                                                mediaItems.items[index].changeThirdValues(newhiValues: bo_getBloodOxygen(inputImage: item.photo!, bo_start: item.boStart, bo_koef: item.boKoef))
                                            }
                                        }
                                        showingModal = false
                                    }
                                    queue.async(execute: item)
                                    scanBarsButton = true
                                })
                                .buttonStyle(customButton(fillColor: .cyan))
                            }
                            
                            if scanBarsButton {
                                Button("Scan Bars", action: {
                                    item = DispatchWorkItem {
                                        showingModal = true
                                        if item.isCancelled != true {
                                            for (index, item) in mediaItems.items.enumerated() {
                                                mediaItems.items[index].changeFourthValues(newarrayRes: bo_scanBars(inputImage: item.photo!, bo_values: item.hiValues, boLOwerBound: item.boLOwerBound, boHighestBound: item.boHighestBound))
                                            }
                                            
                                            
                                            print(mediaItems.items[0].hiMin)
                                            print(mediaItems.items[0].hiMax)
                                        }
                                        showingModal = false
                                    }
                                    queue.async(execute: item)
                                    exportToHealthButton = true
                                })
                                .buttonStyle(customButton(fillColor: .cyan))
                            }
                        }
                        
                        if mediaItems.items.count > 0 {
                            ForEach(mediaItems.items, id: \.id) { item in
                                VStack {
                                    DisclosureView(hubArray: item.hiValues, DisclosureGroupName: "\(item.date.formatted(date: .long, time: .omitted))", accentColor: .cyan, hiMin: item.hiMin, hiMax: item.hiMax)
                                }
                            }
                        }
                        
                        if exportToHealthButton {
                            ExportButtonView(accentColor: .cyan, buttonAction: {
                                print("Export to Apple Health")
                                showingHealthView.toggle()
                            })
                        }
                        
                        //                        Button("showing modal", action: {
                        //                            withAnimation(Animation.easeInOut(duration: 0.25)){
                        //                                GlobalVars.boImagesCount = mediaItems.items.count
                        //                                print(GlobalVars.boImagesCount)
                        //                                showingModal = true
                        //                            }
                        //                        })
                        //                        .padding()
                        
                    } // VSTACK
                    .padding()
                } // SCROLLVIEW
                .blur(radius: $showingModal.wrappedValue ? 2 : 0, opaque: false)
                .navigationTitle(LocalizedStringKey("BloodOxygen.Title"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    refresh()
                    mediaItems.append(item: PhotoPickerModel(photo: UIImage(named: "boIMG")!))
                }, label: {
                    Text("Demo")
                        .foregroundColor(.cyan)
                })
                    .opacity(showingModal ? 0 : 1)
                                    , trailing:
                                        Button(action: {
                    refresh()
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(Font.title2)
                        .foregroundColor(.cyan)
                }
                    .opacity(showingModal ? 0 : 1)
                )
                ////   .safeAreaInset(edge: .top) { HStack { Image(systemName: "arrow.clockwise.circle.fill")
                ////  Spacer()
                ////Image(systemName: "arrow.clockwise.circle.fill")}
                //// .overlay(Text("text"))
                //// .padding()
                ////  .background(.ultraThinMaterial)}
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
                    HealthView(type: "Blood Oxygen", mediaItems: mediaItems)
                }
                
                if $showingModal.wrappedValue {
                    ZStack {
                        Color("ColorTransparentBlack")
                            .edgesIgnoringSafeArea(.all)
                        ModalView(showingModal: $showingModal)
                    }
                }
            } // ZSTACK
        } // NAVIGATIONVIEW
    }
}

struct BloodOxygen_Previews: PreviewProvider {
    static var previews: some View {
        BloodOxygen()
            .environmentObject(Model())
        // .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
