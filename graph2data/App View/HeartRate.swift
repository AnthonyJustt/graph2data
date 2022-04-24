//
//  ContentView.swift
//  pixels
//
//  Created by Anton Krivonozhenkov on 18.09.2021.
//

import SwiftUI

struct HeartRate: View {
    
    @SceneStorage("isZooming") var isZooming: Bool = false
    
    @ObservedObject var mediaItems = PickedMediaItems()
    
    @State private var photoPickerIsPresented = false
    @State private var showingHealthView = false
    
    @State  var showingModal: Bool = false
    
//    @State private var boDate = Date()
    
//    @State private var rateMin = 48
//    @State private var rateMax = 137
    // Минимальное и максимальное значения нужны, чтобы сузить прямоугольник поиска по изображению
    
//    @State private var rateStart = 57
//    @State private var rateEnd = 132
    // Начальное и конечное значения нужны, чтобы сопоставить полученные пиксели и искомые значения время-значение
    // Значение - это Y
    // Время - это X
    
    // xStart = 105 yStart = 866 hrStart = 57
    // xEnd = 2247  yEnd = 671   hrEnd = 132
    //                     195           75
    
    // 648px -- 137 bpm   648/137 = 4,7299270073
    // 890px -- 48 bpm    890/48 = 18,5416666667
    // 242px -- 89 bpm
    
    // image height = 1125
    
    //1125-671 = 454px -- 132 bpm
    //1125-866 = 259px -- 57 bpm
    
    // 1) #FC315A +
    // 2) #FB3259
    // 3) #FB3059
    
    @State private var xStart: Int = 1050
    @State private var xEnd: Int = 22470
    // Начало и окончание графика, определяются автоматически позднее
    
    @State private var yStart: Int = 8660
    @State private var yEnd: Int = 6710
    // Начало и окончание графика, определяются автоматически позднее
    
//    @State private var xProgress: Int = 0
    // для визуального отображения в ProgressView
    
    @State private var xCount: Int = 0
    // количество найденных на графике точек
    
    @State private var hrDate = Date()
    // Дата на изображении, определятеся с помощью Vision позднее, либо задается вручную
    
    let concurrentQueueStart = DispatchQueue(label: "get_xStart_xEnd", attributes: .concurrent)
    @State private var workStartPoint: DispatchWorkItem = DispatchWorkItem { }
    @State private var workEndPoint: DispatchWorkItem = DispatchWorkItem { }
    // Ускоряем обработку, ища начало и окончание графика одновременно
    
    let concurrentQueueAnalysis = DispatchQueue(label: "get_xStart_xEnd", attributes: .concurrent)
    @State private var firstHalf: DispatchWorkItem = DispatchWorkItem { }
    @State private var secondHalf: DispatchWorkItem = DispatchWorkItem { }
    // Ускоряем обработку, анализируя первую и вторую половины графика одновременно
    
//    @State var shouldHide = true
    // ProgressView скрыт до начала анализа
    
    @Environment(\.colorScheme) var colorScheme
    
    let queue = DispatchQueue.global()
    @State private var item: DispatchWorkItem = DispatchWorkItem { }
    
    @State private var getStartButton = false
    @State private var scanImagesButton = false
    @State private var exportToHealthButton = false
    
    func refresh() {
        mediaItems.items = []
        hrDate = Date()
        getStartButton = false
        scanImagesButton = false
        exportToHealthButton = false
        xStart = 0
        xEnd = 0
        yStart = 0
        yEnd = 0
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                ScrollView {
                    VStack {
                        
                        HeaderView(imageName: "bolt.heart", accentColor: .pink, additionalColor: .orange, isZooming: $isZooming, photoPickerIsPresented: $photoPickerIsPresented, mediaItems_Items_Count: $mediaItems.items.count, analyseAction: {
                            item = DispatchWorkItem {
                                GlobalVars.boImagesCount = mediaItems.items.count
                                print(GlobalVars.boImagesCount)
                                withAnimation(Animation.easeOut){
                                    showingModal = true
                                }
                                if item.isCancelled != true {
                                    for (index, item) in mediaItems.items.enumerated() {
                                        
                                        let croppeduiimage = cropImage(item.photo!, toRect: CGRect(x: 1000, y: 150, width: 400, height: 100), viewWidth: item.photo!.size.width, viewHeight: item.photo!.size.height)
                                        
                                        let sdate = detectTextWithVision(imageN: croppeduiimage!)
                                        
                                        print(sdate)
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "dd M yyyy"
                                        hrDate = dateFormatter.date(from: "\(sdate[0])")!
                                        print(hrDate)
                                        
                                        mediaItems.items[index].changeFirstValues(newDate: hrDate, newboLOwerBound: -1, newboHighestBound: -1, newboMaxLevel: -1)
                                    }
                                }
                                withAnimation(Animation.easeIn){
                                    showingModal = false
                                }
                            }
                            queue.async(execute: item)
                            
                            getStartButton = true
                        })
                        
                        //                    ProgressView("Progress", value: Double(xProgress), total: Double(xEnd))
                        //                        .accentColor(.pink)
                        //                        .padding([.top, .bottom])
                        //                        .opacity(shouldHide ? 0 : 1)
                        
                        if mediaItems.items.count > 0 {
                            TabView {
                                ForEach($mediaItems.items, id: \.id) { $item in
                                    VStack {
                                        GroupBoxViewHR(hrDate: $item.date, hrRateMin: $item.hrRateMin, hrRateMax: $item.hrRateMax, hrRateStart: $item.hrRateStart, hrRateEnd: $item.hrRateEnd)
                                        if colorScheme == .dark {
                                            ImageView(uiImage: item.photo ?? UIImage())
                                                .colorInvert()
                                        } else {
                                            ImageView(uiImage: item.photo ?? UIImage())
                                        }
                                        Text("Start (x: \(xStart); y:  \(yStart)); End (x: \(xEnd); y:  \(yEnd))\nCount = \(xEnd - xStart); Actually = \(xCount)")
                                    }
                                }
                            }
                            .tabViewStyle(.page)
                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                            .frame(height: 565)
                        }
                        
                        VStack {
                            if getStartButton {
                                Button ("Get Start & End Points", action: {
                                    
                                    workStartPoint = DispatchWorkItem {
                                        withAnimation(Animation.easeOut){
                                            showingModal = true
                                        }
                                        if item.isCancelled != true {
                                            for (index, item) in mediaItems.items.enumerated() {
                                                (xStart, yStart) = hr_getStartPoint(inputImage: item.photo!)
                                                mediaItems.items[index].changeFifthValues(newhrXStart: xStart, newhrYStart: yStart)
                                                
                                            }
                                        }
                                    }
                                    workEndPoint = DispatchWorkItem {
                                        if item.isCancelled != true {
                                            for (index, item) in mediaItems.items.enumerated() {
                                                (xEnd, yEnd) = hr_getEndPoint(inputImage: item.photo!)
                                                mediaItems.items[index].changeSixthValues(newhrXEnd: xEnd, newhrYEnd: yEnd)
                                            }
                                        }
                                    }
                                    concurrentQueueStart.async(execute: workStartPoint)
                                    concurrentQueueStart.async(execute: workEndPoint)
                                    
                                    scanImagesButton = true
                                    
                                    withAnimation(Animation.easeIn){
                                        showingModal = false
                                    }
                                })
                                    .buttonStyle(customButton(fillColor: Color("AccentColor")))
                            }
                            
                            if scanImagesButton {
                                Button ("Scan Images", action: {
                                    
//                                    shouldHide = false
                                    
                                    firstHalf = DispatchWorkItem {
                                        if item.isCancelled != true {
                                            for (index, item) in mediaItems.items.enumerated() {
                                                hr_getPixelsColors0(inputImage: item.photo!, xStart: item.hrXStart, yStart: item.hrYStart, xEnd: item.hrYEnd)
                                            }
                                        }
                                        
                                        
//                                        print("Task 1 started")
                                        //hr_getPixelsColors1(xStart: xStart)
                                        
//                                        print("Task 1 finished")
                                    }
//                                    secondHalf = DispatchWorkItem {
//                                        print("Task 2 started")
//                                        //hr_getPixelsColors2(xEnd: xEnd)
//                                        print("Task 2 finished")
//                                    }
                                                                        concurrentQueueAnalysis.async(execute: firstHalf)
                                    //    concurrentQueueAnalysis.async(execute: secondHalf)
                                    
                                    exportToHealthButton = true
                                })
                                    .buttonStyle(customButton(fillColor: Color("AccentColor")))
                            }
                        }
                        
                        if mediaItems.items.count > 0 {
                            ForEach(mediaItems.items, id: \.id) { item in
                                VStack {
                                    DisclosureView(hubArray: item.hiValues, DisclosureGroupName: "\(item.date.formatted(date: .long, time: .omitted))", accentColor: .pink, hiMin: item.hiMin, hiMax: item.hiMax)
                                }
                            }
                        }
                        
                        if exportToHealthButton {
                            ExportButtonView(accentColor: .pink, buttonAction: {
                                print("Export to Apple Health")
                                showingHealthView.toggle()
                            })
                        }
                        
                        Button("showing modal", action: {
                            withAnimation(Animation.easeInOut(duration: 0.25)){
                                GlobalVars.boImagesCount = mediaItems.items.count
                                print(GlobalVars.boImagesCount)
                                showingModal = true
                            }
                        })
                            .padding()
                    }
                    .padding()
                }
                .blur(radius: $showingModal.wrappedValue ? 2 : 0, opaque: false)
                .navigationTitle(LocalizedStringKey("HeartRate.Title"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    refresh()
                    mediaItems.append(item: PhotoPickerModel(photo: UIImage(named: "hrIMG")!))
                }, label: {
                    Text("Demo")
                })
                                        .opacity(showingModal ? 0 : 1)
                                    , trailing:
                                        Button(action: {
                    refresh()
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(Font.title2)
                        .foregroundColor(Color("AccentColor"))
                }
                                        .opacity(showingModal ? 0 : 1)
                )
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
                    HealthView(type: "Heart Rate", mediaItems: mediaItems)
                }
                
                if $showingModal.wrappedValue {
                    ZStack {
                        Color("ColorTransparentBlack")
                            .edgesIgnoringSafeArea(.all)
                     //   ModalView(showingModal: $showingModal)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRate()
        // .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
