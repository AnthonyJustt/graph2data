//
//  WeightManagment.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 26.05.2022.
//

import SwiftUI

struct WeightManagment: View {
    @SceneStorage("isZooming") var isZooming: Bool = false
    @State private var photoPickerIsPresented = false
    @StateObject var mediaItems = PickedMediaItems()
    @State private var errorText: String = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var exportToHealthButton = false
    @State private var showingHealthView = false
    @State var showingModal: Bool = false
    
    @State private var wmWM: Float = 0.0
    
    func refresh() {
        exportToHealthButton = false
        mediaItems.items = []
    }
    
    func wmAnalyseAction(mediaItems: PickedMediaItems) {
        
        print("wmAnalyseAction started")
        
        var croppeduiimage: UIImage
        
        for (index, item) in mediaItems.items.enumerated() {
            croppeduiimage = cropImage(item.photo!, toRect: CGRect(x: 350, y: 425, width: 400, height: 85), viewWidth: item.photo!.size.width, viewHeight: item.photo!.size.height)!
            let sdate = detectTextWithVision(imageN: croppeduiimage)
            
            croppeduiimage = cropImage(item.photo!, toRect: CGRect(x: 450, y: 520, width: 220, height: 80), viewWidth: item.photo!.size.width, viewHeight: item.photo!.size.height)!
            let stime = detectTextWithVision(imageN: croppeduiimage)
            let outFormatter = DateFormatter()
            outFormatter.dateFormat = "hh:mm a"
            let datess = outFormatter.date(from: stime[0])
            
            croppeduiimage = cropImage(item.photo!, toRect: CGRect(x: 300, y: 610, width: 500, height: 150), viewWidth: item.photo!.size.width, viewHeight: item.photo!.size.height)!
            let sweight = detectTextWithVision(imageN: croppeduiimage)
            
            var wmbmi: Float = 0.0
            var wmbfr: Float = 0.0
            var wmffm: Float = 0.0
            
            var wmbmr: Float = 0.0
            var wmbw: Float = 0.0
            var wmvf: Float = 0.0
            
            var wmbmc: Float = 0.0
            var wmp: Float = 0.0
            var wmsmm: Float = 0.0
            
            for i in stride(from: 50, through: 750, by: 350) {
                for j in stride(from: 1165, through: 1875, by: 355) {
                    croppeduiimage = cropImage(item.photo!, toRect: CGRect(x: i, y: j, width: 300, height: 115), viewWidth: item.photo!.size.width, viewHeight: item.photo!.size.height)!
                    if i == 50 && j == 1165 {
                        let sbmi = detectTextWithVision(imageN: croppeduiimage)
                        wmbmi = Float(sbmi[0].replacingOccurrences(of: ",", with: ".")) ?? -1
                    }
                    if i == 400 && j == 1165 {
                        let sbfr = detectTextWithVision(imageN: croppeduiimage)
                        wmbfr = Float(sbfr[0].components(separatedBy: " ")[0].replacingOccurrences(of: ",", with: ".")) ?? -1
                    }
                    if i == 750 && j == 1165 {
                        let sffm = detectTextWithVision(imageN: croppeduiimage)
                        wmffm = Float(sffm[0].components(separatedBy: " ")[0].replacingOccurrences(of: ",", with: ".")) ?? -1
                    }
                    
                    if i == 50 && j == 1520 {
                        let sbmr = detectTextWithVision(imageN: croppeduiimage)
                        wmbmr = Float(sbmr[0].replacingOccurrences(of: " kcal/d", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: ".")) ?? -1
                    }
                    if i == 400 && j == 1520 {
                        let sbw = detectTextWithVision(imageN: croppeduiimage)
                        wmbw = Float(sbw[0].components(separatedBy: " ")[0].replacingOccurrences(of: ",", with: ".")) ?? -1
                    }
                    if i == 750 && j == 1520 {
                        let svf = detectTextWithVision(imageN: croppeduiimage)
                        wmvf = Float(svf[0].components(separatedBy: " ")[0].replacingOccurrences(of: ",", with: ".")) ?? -1
                    }
                    
                    if i == 50 && j == 1875 {
                        let sbmc = detectTextWithVision(imageN: croppeduiimage)
                        wmbmc = Float(sbmc[0].components(separatedBy: " ")[0].replacingOccurrences(of: ",", with: ".")) ?? -1
                    }
                    if i == 400 && j == 1875 {
                        let smp = detectTextWithVision(imageN: croppeduiimage)
                        wmp = Float(smp[0].components(separatedBy: " ")[0].replacingOccurrences(of: ",", with: ".")) ?? -1
                    }
                    if i == 750 && j == 1875 {
                        let ssmm = detectTextWithVision(imageN: croppeduiimage)
                        wmsmm = Float(ssmm[0].components(separatedBy: " ")[0].replacingOccurrences(of: ",", with: ".")) ?? -1
                    }
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd M yyyy"
            let wmDate = dateFormatter.date(from: "\(sdate[0])")!
            mediaItems.items[index].changeCommonValues(newDate: wmDate)
            
            let wmweight = Float(sweight[0]
                .components(separatedBy: " ")[0]
                .replacingOccurrences(of: ",", with: ".")) ?? -1
            
            mediaItems.items[index].changeWMValues(
                newwmTime: datess!,
                newwmWeight: wmweight,
                newwmBMI: wmbmi,
                newwmBodyFatRate: wmbfr,
                newwmFatFreeMass: wmffm,
                newwmBasalMetabolicRate: wmbmr,
                newwmBodyWater: wmbw,
                newwmVisceralFat: wmvf,
                newwmBoneMineralContent: wmbmc,
                newwmProtein: wmp,
                newwmSkeletalMuscleMass: wmsmm)
        }
        
        print("wmAnalyseAction finished")
        
        exportToHealthButton = true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack {
                        HeaderView(
                            imageName: "lineweight",
                            accentColor: .purple,
                            additionalColor: .pink,
                            isZooming: $isZooming,
                            photoPickerIsPresented: $photoPickerIsPresented,
                            mediaItems_Items_Count: mediaItems.items.count,
                            analyseAction: { wmAnalyseAction(mediaItems: mediaItems) } ,
                            errorText: errorText)
                        
                        if mediaItems.items.count > 0 {
                            TabView {
                                ForEach($mediaItems.items, id: \.id) { $item in
                                    VStack {
                                        GroupBoxViewWM(
                                            wmDate: $item.date, wmTime: $item.wmTime,
                                            wmWeight: $item.wmWeight,
                                            wmBMI: $item.wmBMI,
                                            wmBFR: $item.wmBodyFatRate,
                                            wmFFM: $item.wmFatFreeMass,
                                            wmBMR: $item.wmBasalMetabolicRate,
                                            wmBW: $item.wmBodyWater,
                                            wmVFL: $item.wmVisceralFat,
                                            wmBMC: $item.wmBoneMineralContent,
                                            wmP: $item.wmProtein,
                                            wmSMM: $item.wmSkeletalMuscleMass)
                                        
                                        if colorScheme == .dark {
                                            ImageView(uiImage: item.photo ?? UIImage())
                                                .colorInvert()
                                        } else {
                                            ImageView(uiImage: item.photo ?? UIImage())
                                        }
                                    }
                                    .frame(height: 1430)
                                }
                            }
                            .tabViewStyle(.page)
                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                            .frame(height: 1435)
                        }
                        
                        if exportToHealthButton {
                            ExportButtonView(accentColor: .purple, buttonAction: {
                                print("Export to Apple Health")
                                showingHealthView.toggle()
                            })
                        }
                        
                    } // VSTACK
                    .padding()
                } // SCROLLVIEW
                .blur(radius: $showingModal.wrappedValue ? 2 : 0, opaque: false)
                .navigationTitle(LocalizedStringKey("WeightManagment.Title"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    refresh()
                    mediaItems.append(item: PhotoPickerModel(photo: UIImage(named: "wmIMG")!))
                }, label: {
                    Text("Demo")
                        .foregroundColor(.purple)
                })
                    .opacity(showingModal ? 0 : 1)
                                    , trailing:
                                        Button(action: {
                    refresh()
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(Font.title2)
                        .foregroundColor(.purple)
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
                    HealthView(type: "Weight Managment", mediaItems: mediaItems)
                }
                
                if $showingModal.wrappedValue {
                    ZStack {
                        Color("ColorTransparentBlack")
                            .edgesIgnoringSafeArea(.all)
                        ModalView(showingModal: $showingModal)
                    }
                }
            } // ZSTACK
        } // NAVIGATION VIEW
    }
}

struct WeightManagment_Previews: PreviewProvider {
    static var previews: some View {
        WeightManagment()
    }
}
