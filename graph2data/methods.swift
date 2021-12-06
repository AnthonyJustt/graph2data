//
//  methods.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 03.12.2021.
//

import SwiftUI
import Vision

// MARK: Common Methods

struct healthItem: Identifiable {
    var id = UUID()
    var x: CGFloat
    var y: CGFloat
    var date: String
    var value: String
}

struct ImageView: View {
    var uiImage: UIImage
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
    }
}

func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
{
    let imageViewScale = max(inputImage.size.width / viewWidth,
                             inputImage.size.height / viewHeight)
    
    // Scale cropRect to handle images larger than shown-on-screen size
    let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                          y:cropRect.origin.y * imageViewScale,
                          width:cropRect.size.width * imageViewScale,
                          height:cropRect.size.height * imageViewScale)
    
    // Perform cropping in Core Graphics
    guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
    else {
        return nil
    }
    
    // Return image to UIImage
    let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
    return croppedImage
}

func detectTextWithVision(imageN: UIImage) -> [String] {
    var s: [String] = []
    
    guard let cgImage = imageN.cgImage else {
        fatalError("could not get cgimage")
    }
    
    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
    let request = VNRecognizeTextRequest {  request, error in
        guard let observations = request.results as? [VNRecognizedTextObservation],
              error == nil else {
                  return
              }
        
        let text = observations.compactMap({$0.topCandidates(1).first!.string}) //.joined(separator: ", ")
        s = text
       // print(text)
    }
    
    do {
        try requestHandler.perform([request])
    } catch {
        print(error)
    }
    
    return s
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

extension UIImage {
    
    func getPixelColor(pos: CGPoint) -> UIColor {
        // Получение информации о пикселе
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo+0]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}


// MARK: Blood Oxygen Methods

private let bo_YStart = 860 // положение нижнего серого бара = минимальное значение
private let bo_minBar = 800 // на этой высоте начинаем искать зеленые бары

func bo_minutesToTime(mins: Int) -> String {
    let seconds = mins * 60
    let dcf = DateComponentsFormatter()
    dcf.allowedUnits = [.hour, .minute, .second]
    dcf.unitsStyle = .positional
    dcf.zeroFormattingBehavior = .pad
    let dcfstring = dcf.string(from: TimeInterval(seconds))
    // print(dcfstring ?? "nil")
    return dcfstring ?? "nil"
}

func bo_getStartAndEndPoints(inputImage: UIImage) -> (Float, Int, Int) {
    // определяем положение нижней границы - шкалы времени (сейчас она находится на высоте в bo_YStart px)
    // рассчитываем коэффициенты для перевода координат в значения
    
    print("bo_getStartAndEndPoints was started")
    print("image size: \(inputImage.size.width) x \(inputImage.size.height)")
    
    var point = CGPoint(x: 0, y: 0)
    var uiColor = inputImage.getPixelColor(pos: point) //?? .black
    let UIColorToCompare = hexStringToUIColor(hex: "#EEEEEE")
    var bo_start = 0
    var bo_end = 0
    var bo_koef: Float = 0.0
    
    
    
    point = CGPoint(x: 207, y: bo_YStart)
    uiColor = inputImage.getPixelColor(pos: point)
    print(uiColor)
    print(hexStringFromColor(color: uiColor))
    
    
    
    for i in 0...Int(inputImage.size.width /* ?? 0 */) {
        point = CGPoint(x: i, y: bo_YStart)
        uiColor = inputImage.getPixelColor(pos: point) //?? .black
        if uiColor == UIColorToCompare {
            bo_start = i
            print("bo_start = \(bo_start)")
            break
        }
    }
    
    //    point = CGPoint(x: 2190, y: bo_YStart)
    //    uiColor = UIImage(named: "IMG2")?.getPixelColor(pos: point) ?? .black
    //    print(hexStringFromColor(color: uiColor))
    
    // 1440 минут в 2192-207 пикселей = 1985 пикселей
    // 1985 / 1440 = 1,3784722222
    
    //255-207 = 48 пикселей
    // 48 / 1,378_4722222 ~~ 0 часов 35 минут
    
    
    // 2166-207 = 1959
    // 1959 / 1,378_4722222 ~~ 1421 минута ~~ 23 часа 41 минута
    
    for i in stride(from: Int(inputImage.size.width /* ?? 0 */), to: 0, by: -1) {
        point = CGPoint(x: i, y: bo_YStart)
        uiColor = inputImage.getPixelColor(pos: point) //?? .black
        if uiColor == UIColorToCompare {
            bo_end = i
            print("bo_end = \(bo_end)")
            break
        }
    }
    
    bo_koef = (Float(bo_end - bo_start)) / Float(1440)
    
    print("bo_koef = \(bo_koef)")
    print("bo_getStartAndEndPoints was finished")
    
    return (bo_koef, bo_start, bo_end)
}

func bo_getBloodOxygen(inputImage: UIImage, bo_start: Int, bo_koef: Float) -> [ healthItem ] {
    
    //    var point = CGPoint(x: 911, y: 500)
    //    var uiColor = UIImage(named: "IMG2")?.getPixelColor(pos: point)
    //    print(hexStringFromColor(color: uiColor ?? .black))
    // #66B651
    
    //!!!
    // #65B751
    // #66B651
    
    print("bo_getBloodOxygen was started")
    
    var sss: String = ""
    var ssss: String = ""
    var point = CGPoint(x: 0, y: 0)
    var uiColor = inputImage.getPixelColor(pos: point) //?? .black
    
    var x_prev: Int = 0
    
    var bo_values: [healthItem] = []
    
    //    var uiColor = UIColor.black
    //
    //let UIColorToCompare = hexStringToUIColor(hex: "#65B751")
    //
    
    //
    for i in 0...Int(inputImage.size.width /* ?? 0 */) {
        point = CGPoint(x: i, y: bo_minBar)
        uiColor = inputImage.getPixelColor(pos: point) //?? .black
        
        
        
        sss = hexStringFromColor(color: uiColor)
        ssss = String(sss.prefix(upTo: sss.index(sss.startIndex, offsetBy: 4)))
        
        
        if ssss == "#64B" || ssss == "#65B" || ssss == "#66B"{
            if Int(point.x)-x_prev > 4 {
                // следующее значение должно быть минимум через 4 пикселя от полученного на предыдущей итерации
                
                print("x: \(point.x), y: \(point.y) - \(bo_minutesToTime(mins: Int(Float(Int(point.x) - bo_start) / bo_koef)))")
                
                bo_values.append(healthItem(
                    x: point.x,
                    y: point.y,
                    date: bo_minutesToTime(mins: Int(Float(Int(point.x) - bo_start) / bo_koef)),
                    value: ""))
                
                x_prev = Int(point.x)
            }
        }
        
        //        let UIColorToCompare = hexStringToUIColor(hex: "#FFFFFF")
        //        if uiColor != UIColorToCompare {
        //                    print("x: \(point.x), y: \(point.y), \(hexStringFromColor(color: uiColor))")
        //                    //break
        //                }
    }
    
    print("bo_barsCount = \(bo_values.count)")
    
    print("bo_getBloodOxygen was finished")
    
    return bo_values
}

func bo_scanBars(inputImage: UIImage, bo_values: [healthItem], boLOwerBound: Int, boHighestBound: Int) -> [String] {
    
    print("bo_scanBars was started")
    
    var point = CGPoint(x: 0, y: 0)
    var uiColor = inputImage.getPixelColor(pos: point) //?? .black
    
    var sss: String = ""
    var ssss: String = ""
    
    var arrayY: [Int] = []
    var arrayRes: [String] = []
    var yres: Int = 0
    
    for value_item in bo_values {
        for i in 0...Int(inputImage.size.height /* ?? 0 */) {
            point = CGPoint(x: Int(value_item.x), y: i)
            uiColor = inputImage.getPixelColor(pos: point) //?? .black
            
            sss = hexStringFromColor(color: uiColor)
            ssss = String(sss.prefix(upTo: sss.index(sss.startIndex, offsetBy: 4)))
            if ssss == "#64B" || ssss == "#65B" || ssss == "#66B" {
                print("\(i), \(bo_YStart - i)")
                arrayY.append(bo_YStart - i)
                break
            }
        }
    }
    
    let maxValue = arrayY.max() ?? 0
    print("maxValue = \(maxValue)")
    
    // bo_YStart = 860 - минимум - boLOwerBound = 75
    // maxValue = 526 - максимум - boHighestBound или boMaxLevel = 100
    
    let koef: Float = Float(maxValue) / Float(boHighestBound - boLOwerBound)
    print("koef = \(koef)")
    
    // 526 / (100-75) = 21,04
    // 526 / 21,04 = 25 + 75 = 100
    
    // 524 - 99,9049429658 - должно быть 100
    // 525 - 99,9524714829 - должно быть 100
    
    // 511 - 99,2870722433 - 99 - ок
    
    // 435 / 21,04 + 75 = Int(95,674904943)
    // 441 / 21,04 + 75 = Int(95,96)
    
    for bo in arrayY {
        if maxValue - bo <= 3 {
            print(100)
            arrayRes.append("100")
        } else {
            yres = Int(Float(bo)/koef + Float(boLOwerBound))
            print(yres)
            arrayRes.append(String(yres))
        }
    }
    
    print("bo_scanBars was finished")
    
    return arrayRes
    
}


// MARK: HeartRate Methods

func hr_getStartPoint() -> (Int, Int) {
    // Поиск начальной точки графика
    
    var point = CGPoint(x: 0, y: 0)
    var uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
    var colorCode = hexStringFromColor(color: uiColor)
    var xStart = 0
    var yStart = 0
    
outerLoop: for i in 104...Int(UIImage(named: "IMG")?.size.width ?? 0) {
    print(i)
    for j in 0...Int(UIImage(named: "IMG")?.size.height ?? 0) {
        point = CGPoint(x: i, y: j)
        uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
        colorCode = hexStringFromColor(color: uiColor)
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

func hr_getEndPoint() -> (Int, Int) {
    // Поиск конечной точки графика
    
    var point = CGPoint(x: 0, y: 0)
    var uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
    var colorCode = hexStringFromColor(color: uiColor)
    var xEnd = 0
    var yEnd = 0
    
outerLoop: for i in stride(from: Int(UIImage(named: "IMG")?.size.width ?? 0) - 188, to: 2240, by: -1) {
    print(i)
    for j in 0...Int(UIImage(named: "IMG")?.size.height ?? 0) {
        point = CGPoint(x: i, y: j)
        uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
        colorCode = hexStringFromColor(color: uiColor)
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

func hr_getPixelsColors0(xStart: Int, yStart: Int, xEnd: Int, yEnd: Int) {
    
    var point = CGPoint(x: 0, y: 0)
    //  var uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
    var uiColor = UIColor.black
    // var colorCode = self.hexStringFromColor(color: uiColor)
    var yChange = yStart
    var jj = 0
    
    var xCount: Int = 0
    var xProgress: Int = 0
    
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

//    private func hr_getPixelsColors1(xStart: Int) {
//        // Анализ первой половины изображения
//
//        var point = CGPoint(x: 0, y: 0)
//        var uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
//        var colorCode = hexStringFromColor(color: uiColor)
//        let xEnd = Int((UIImage(named: "IMG")?.size.width ?? 0) / 2)
//
//        for n in xStart...xEnd {
//            for m in 640...900 {
//                point = CGPoint(x: n, y: m)
//                uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
//                colorCode = hexStringFromColor(color: uiColor)
//                if colorCode == "#FC315A" {
//                    print("x: \(point.x), y: \(point.y) - \(colorCode)")
//                    break
//                }
//            }
//            xProgress = xProgress + 20
//        }
//    }
//
//    private func hr_getPixelsColors2(xEnd: Int) {
//        // Анализ второй половины изображения
//
//        var point = CGPoint(x: 0, y: 0)
//        var uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
//        var colorCode = hexStringFromColor(color: uiColor)
//        let xStart = Int((UIImage(named: "IMG")?.size.width ?? 0) / 2)
//
//        for n in xStart...xEnd {
//            for m in 640...900 {
//                point = CGPoint(x: n, y: m)
//                uiColor = UIImage(named: "IMG")?.getPixelColor(pos: point) ?? .black
//                colorCode = hexStringFromColor(color: uiColor)
//                if colorCode == "#FC315A" {
//                    print("x: \(point.x), y: \(point.y) - \(colorCode)")
//                    break
//                }
//            }
//        }
//    }
