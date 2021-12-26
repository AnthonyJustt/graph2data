//
//  PhotoPicker.swift
//  PHPickerDemo
//
//  Created by Gabriel Theodoropoulos.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    
    @ObservedObject var mediaItems: PickedMediaItems
    var didFinishPicking: (_ didSelectItems: Bool) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images])
        config.selectionLimit = 0
        config.preferredAssetRepresentationMode = .current
        
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    
    class Coordinator: PHPickerViewControllerDelegate {
        var photoPicker: PhotoPicker
        
        init(with photoPicker: PhotoPicker) {
            self.photoPicker = photoPicker
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            photoPicker.didFinishPicking(!results.isEmpty)
            
            guard !results.isEmpty else {
                return
            }
            
            for result in results {
                let itemProvider = result.itemProvider
                
                guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                      let utType = UTType(typeIdentifier)
                else { continue }
                
                if utType.conforms(to: .image) {
                    self.getPhoto(from: itemProvider, isLivePhoto: false)
                }
            }
        }
        
        
        private func getPhoto(from itemProvider: NSItemProvider, isLivePhoto: Bool) {
            let objectType: NSItemProviderReading.Type = !isLivePhoto ? UIImage.self : PHLivePhoto.self
            
            if itemProvider.canLoadObject(ofClass: objectType) {
                itemProvider.loadObject(ofClass: objectType) { object, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self.photoPicker.mediaItems.append(item: PhotoPickerModel(with: image, boLOwerBound: 0, boHighestBound: 0, boMaxLevel: 0))
                            }
                        }
                }
            }
            
        }
    }
}



////
////  PhotoPicker.swift
////  PHPhotoPickerSwiftUI
////
////  Created by Kristaps Grinbergs on 02/01/2021.
////
//
//import SwiftUI
//import PhotosUI
//
//struct PhotoPicker: UIViewControllerRepresentable {
//  @Binding var pickerResult: [UIImage]
//  @Binding var isPresented: Bool
//
//  func makeUIViewController(context: Context) -> some UIViewController {
//    var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
//      configuration.filter = .images // filter only to images
//    configuration.selectionLimit = 0 // 0 - ignore limit
//
//    let photoPickerViewController = PHPickerViewController(configuration: configuration)
//    photoPickerViewController.delegate = context.coordinator
//    return photoPickerViewController
//  }
//
//  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
//
//  func makeCoordinator() -> Coordinator {
//    Coordinator(self)
//  }
//
//  class Coordinator: PHPickerViewControllerDelegate {
//    private let parent: PhotoPicker
//
//    init(_ parent: PhotoPicker) {
//      self.parent = parent
//    }
//
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//      parent.pickerResult.removeAll()
//
//      for image in results {
//        if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
//          image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] newImage, error in
//            if let error = error {
//              print("Can't load image \(error.localizedDescription)")
//            } else if let image = newImage as? UIImage {
//              self?.parent.pickerResult.append(image)
//            }
//          }
//        } else {
//          print("Can't load asset")
//        }
//      }
//
//      parent.isPresented = false
//    }
//  }
//}
