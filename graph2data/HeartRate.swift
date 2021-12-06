//
//  ContentView.swift
//  pixels
//
//  Created by Anton Krivonozhenkov on 18.09.2021.
//

import SwiftUI

struct HeartRate: View {
    
    @State private var rateMin = 48
    @State private var rateMax = 137
    // Минимальное и максимальное значения нужны, чтобы сузить прямоугольник поиска по изображению
    
    @State private var rateStart = 57
    @State private var rateEnd = 132
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
    
    @State private var xStart: Int = 105
    @State private var xEnd: Int = 2247
    // Начало и окончание графика, определяются автоматически позднее
    
    @State private var yStart: Int = 866
    @State private var yEnd: Int = 671
    // Начало и окончание графика, определяются автоматически позднее
    
    @State private var xProgress: Int = 0
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
    
    @State var shouldHide = true
    // ProgressView скрыт до начала анализа
    
    @State private var showingHealthView = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    
                    Image(systemName: "bolt.heart")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.orange, .pink)
                        .font(.system(size: 60))
                    
                    ProgressView("Progress", value: Double(xProgress), total: Double(xEnd))
                        .accentColor(.pink)
                        .padding([.top, .bottom])
                        .opacity(shouldHide ? 0 : 1)
                    
                    GroupBox {
                        DatePicker(selection: $hrDate, in: ...Date(), displayedComponents: .date) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                                    .font(.title2)
                                Text("Date")
                            }
                        }
                        
                        Divider()
                        Stepper(value: $rateMin) {
                            HStack {
                                Image(systemName: "arrow.down.heart")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.blue, .pink)
                                    .font(.title2)
                                Text("Min HR is \(rateMin) bpm")
                            }
                        }
                        Divider()
                        Stepper(value: $rateMax) {
                            HStack {
                                Image(systemName: "arrow.up.heart")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.purple, .pink)
                                    .font(.title2)
                                Text("Max HR is \(rateMax) bpm")
                            }
                        }
                        Divider()
                        Stepper(value: $rateStart) {
                            HStack {
                                Image(systemName: "heart.circle")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                Text("Start HR is \(rateStart) bpm")
                            }
                        }
                        Divider()
                        Stepper(value: $rateEnd) {
                            HStack {
                                Image(systemName: "heart.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                Text("End HR is \(rateEnd) bpm")
                            }
                        }
                    }
                    
                    if colorScheme == .dark {
                        Image("IMG")
                            .resizable()
                            .scaledToFit()
                            .colorInvert()
                    } else {
                        Image("IMG")
                            .resizable()
                            .scaledToFit()
                    }
                    
                    VStack {
                        HStack {
                            Button ("Get Start & End Points", action: {
                                workStartPoint = DispatchWorkItem {
                                    print("Task 1 started")
                                    (xStart, yStart) = hr_getStartPoint()
                                    print("Task 1 finished")
                                }
                                workEndPoint = DispatchWorkItem {
                                    print("Task 2 started")
                                    (xEnd, yEnd) = hr_getEndPoint()
                                    print("Task 2 finished")
                                }
                                concurrentQueueStart.async(execute: workStartPoint)
                                concurrentQueueStart.async(execute: workEndPoint)
                            })
                                .buttonStyle(customButton(fillColor: Color("AccentColor")))
                            
                            Button ("Analyse", action: {
                                
                                shouldHide = false
                                
                                firstHalf = DispatchWorkItem {
                                    print("Task 1 started")
                                    //hr_getPixelsColors1(xStart: xStart)
                                    hr_getPixelsColors0(xStart: xStart, yStart: yStart, xEnd: xEnd, yEnd: yEnd)
                                    print("Task 1 finished")
                                }
                                secondHalf = DispatchWorkItem {
                                    print("Task 2 started")
                                    //hr_getPixelsColors2(xEnd: xEnd)
                                    print("Task 2 finished")
                                }
                                concurrentQueueAnalysis.async(execute: firstHalf)
                                //    concurrentQueueAnalysis.async(execute: secondHalf)
                            })
                                .buttonStyle(customButton(fillColor: Color("AccentColor")))
                            
                        }
                        
                        Button("Get Date", action: {
//                            detectTextWithVision(imageName: "IMG",date: hrDate)
                        })
                            .accessibilityIdentifier("get_date")
                            .buttonStyle(customButton(fillColor: Color("AccentColor")))
                        
                        Divider()
                            .padding()
                    }
                    
                    VStack {
                        Text("Start: x = \(xStart) y = \(yStart)")
                        Text("End:  x = \(xEnd) y = \(yEnd)")
                        Text("Count = \(xEnd - xStart)")
                        Text("Actually = \(xCount)")
                        
                        Divider()
                            .padding()
                    }
                    
                    DisclosureView(hubArray: [healthItem(x: 0.0, y: 0.0, date: "00-00-0000", value: "")], DisclosureGroupName: "\(hrDate.formatted(date: .long, time: .omitted))")
                    
                    Divider()
                        .padding()
                    
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
                        .buttonStyle(customButton(fillColor: Color("AccentColor")))
                    
                }
                .padding()
            }
            .navigationTitle(LocalizedStringKey("HeartRate.Title"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingHealthView) {
                HealthView(date: hrDate, type: "Heart Rate", healthValues: [])
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
