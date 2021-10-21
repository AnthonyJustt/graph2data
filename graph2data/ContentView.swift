//
//  ContentView.swift
//  pixels
//
//  Created by Anton Krivonozhenkov on 18.09.2021.
//

import SwiftUI
import Vision

struct ContentView: View {
    
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
    
    @State private var rateDate = Date()
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
                        DatePicker(selection: $rateDate, in: ...Date(), displayedComponents: .date) {
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
                                    (xStart, yStart) = getStartPoint()
                                    print("Task 1 finished")
                                }
                                workEndPoint = DispatchWorkItem {
                                    print("Task 2 started")
                                    (xEnd, yEnd) = getEndPoint()
                                    print("Task 2 finished")
                                }
                                concurrentQueueStart.async(execute: workStartPoint)
                                concurrentQueueStart.async(execute: workEndPoint)
                            })
                                .buttonStyle(customButton())
                            
                            Button ("Analyse", action: {
                                
                                shouldHide = false
                                
                                firstHalf = DispatchWorkItem {
                                    print("Task 1 started")
                                    //getPixelsColors1(xStart: xStart)
                                    getPixelsColors0(xStart: xStart, yStart: yStart, xEnd: xEnd, yEnd: yEnd)
                                    print("Task 1 finished")
                                }
                                secondHalf = DispatchWorkItem {
                                    print("Task 2 started")
                                    getPixelsColors2(xEnd: xEnd)
                                    print("Task 2 finished")
                                }
                                concurrentQueueAnalysis.async(execute: firstHalf)
                                //    concurrentQueueAnalysis.async(execute: secondHalf)
                            })
                                .buttonStyle(customButton())
                            
                        }
                        
                        Button("Get Date", action: {
                            detectTextWithVision()
                        })
                            .buttonStyle(customButton())
                        
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
                    
                    DisclosureView(hubArray: [heartRateItem(date: "11", hr: "22"), heartRateItem(date: "33", hr: "44")], DisclosureGroupName: "\(rateDate.formatted(date: .long, time: .omitted))")
                    
                    Divider()
                        .padding()
                    
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
                        .buttonStyle(customButton())
                    
                }
                .padding()
            }
            .navigationTitle(LocalizedStringKey("MainView.Title"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func detectTextWithVision() {
        // Для распознавания текста на изображении
        // Из распознанного берем только [1] строчку - дату
        
        guard let cgImage = UIImage(named: "IMG")?.cgImage else {
            fatalError("could not get cgimage")
        }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest {  request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                      return
                  }
            
            let text = observations.compactMap({
                $0.topCandidates(1).first!.string
            })//.joined(separator: ", ")
            
            DispatchQueue.main.async {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMM y"
                rateDate = dateFormatter.date(from: text[1])!
            }
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func hexStringFromColor(color: UIColor) -> String {
        // Для преобразования полученного цвета пикселя в hex
        
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    private func getStartPoint() -> (Int, Int) {
        // Поиск начальной точки графика
        
        var point = CGPoint(x: 0, y: 0)
        var uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
        var colorCode = self.hexStringFromColor(color: uiColor)
        var xStart = 0
        var yStart = 0
        
    outerLoop: for i in 104...Int(UIImage(named: "IMG")?.size.width ?? 0) {
        print(i)
        for j in 0...Int(UIImage(named: "IMG")?.size.height ?? 0) {
            point = CGPoint(x: i, y: j)
            uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
            colorCode = self.hexStringFromColor(color: uiColor)
            if colorCode == "#FC315A" {
                xStart = i
                yStart = j
                print("xStart = \(i) yStart = \(j)")
                break outerLoop
            }
        }
    }
        return (xStart, yStart)
    }
    
    private func getEndPoint() -> (Int, Int) {
        // Поиск конечной точки графика
        
        var point = CGPoint(x: 0, y: 0)
        var uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
        var colorCode = self.hexStringFromColor(color: uiColor)
        var xEnd = 0
        var yEnd = 0
        
    outerLoop: for i in stride(from: Int(UIImage(named: "IMG")?.size.width ?? 0) - 188, to: 2240, by: -1) {
        print(i)
        for j in 0...Int(UIImage(named: "IMG")?.size.height ?? 0) {
            point = CGPoint(x: i, y: j)
            uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
            colorCode = self.hexStringFromColor(color: uiColor)
            if colorCode == "#FC315A" {
                xEnd = i
                yEnd = j
                print("xEnd = \(i) yEnd = \(j)")
                break outerLoop
            }
        }
    }
        return (xEnd, yEnd)
    }
    
    private func getPixelsColors0(xStart: Int, yStart: Int, xEnd: Int, yEnd: Int) {
        
        var point = CGPoint(x: 0, y: 0)
        //  var uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
        var uiColor = UIColor.black
        // var colorCode = self.hexStringFromColor(color: uiColor)
        var yChange = yStart
        var jj = 0
        
        let UIColorToCompare = hexStringToUIColor(hex: "#FC315A")
        
        print("getPixelsColors0 was started")
        
        for i in xStart...xEnd {
            // print(i)
            for j in yChange-20...yChange+20 {
                jj = j
                //print(j)
                point = CGPoint(x: i, y: j)
                uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
                //      colorCode = self.hexStringFromColor(color: uiColor)
                //       if colorCode == "#FC315A" {
                if uiColor == UIColorToCompare {
                    //       print("x: \(point.x), y: \(point.y) - \(colorCode)")
                    print("x: \(point.x), y: \(point.y)")
                    yChange = jj
                    xCount += 1
                    break
                }
            }
            xProgress = i
        }
        print("getPixelsColors0: count = \(xCount)")
    }
    
    private func getPixelsColors1(xStart: Int) {
        // Анализ первой половины изображения
        
        var point = CGPoint(x: 0, y: 0)
        var uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
        var colorCode = self.hexStringFromColor(color: uiColor)
        let xEnd = Int((UIImage(named: "IMG")?.size.width ?? 0) / 2)
        
        for n in xStart...xEnd {
            for m in 640...900 {
                point = CGPoint(x: n, y: m)
                uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
                colorCode = self.hexStringFromColor(color: uiColor)
                if colorCode == "#FC315A" {
                    print("x: \(point.x), y: \(point.y) - \(colorCode)")
                    break
                }
            }
            xProgress = xProgress + 20
        }
    }
    
    private func getPixelsColors2(xEnd: Int) {
        // Анализ второй половины изображения
        
        var point = CGPoint(x: 0, y: 0)
        var uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
        var colorCode = self.hexStringFromColor(color: uiColor)
        let xStart = Int((UIImage(named: "IMG")?.size.width ?? 0) / 2)
        
        for n in xStart...xEnd {
            for m in 640...900 {
                point = CGPoint(x: n, y: m)
                uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
                colorCode = self.hexStringFromColor(color: uiColor)
                if colorCode == "#FC315A" {
                    print("x: \(point.x), y: \(point.y) - \(colorCode)")
                    break
                }
            }
        }
    }
    
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        // Получение информации о пикселе
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}

struct customButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 15)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("AccentColor"))
                    .opacity(0.1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color("AccentColor"))
                    )
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//            .preferredColorScheme(.dark)
//            .environment(\.locale, .init(identifier: "ru"))
    }
}
