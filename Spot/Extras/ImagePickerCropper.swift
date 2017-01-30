//
//  ImagePickerCropper.swift
//  manueGE
//  https://gist.github.com/ManueGE/f1f3f34a8b3c7fab8d0b974a60011f60
//
//  Created by Manuel García-Estañ on 7/11/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//
import Foundation
import UIKit
import ImagePicker
import TOCropViewController

struct SpotPicker {
    typealias Completion = (Result) -> Void
    typealias SpotCreator = (UIImage) -> CameraSpotViewController
    
    enum Error: Swift.Error {
        case cancelPick
        case cancelCrop
    }
    
    enum Result {
        case success([UIImage])
        case cancelled(Error)
    }
    
    /// The picker used to select the image(s)
    let imagePicker: ImagePickerController
    
    /// The closure used to create the `CameraSpotViewController`
    let spotConfigurator: SpotCreator?
    
    /// Creates a new instance with the given picker and CameraSpotViewController configuration
    init(picker: ImagePickerController, spotConfigurator: SpotCreator? = nil) {
        self.imagePicker = picker
        self.spotConfigurator = spotConfigurator
    }
    
    /// Show the picker from the given controller.
    func show(from controller: UIViewController, animated: Bool = true, completion: @escaping Completion) {
        
        imagePicker.delegate = SpotPickerDelegate(baseController: controller,
                                                     spotPicker: self,
                                                     completion: completion)
        
        controller.present(imagePicker, animated: animated, completion: nil)
    }
}
/// The delegate which will handle the responses from picker and cropper
private class SpotPickerDelegate: NSObject {
    let baseController: UIViewController
    let spotPicker: SpotPicker
    let completion: SpotPicker.Completion
    
    fileprivate var pickedImages:   [UIImage] = []
    fileprivate var tagedImages:     [UIImage] = []
    
    fileprivate var retainCycle: AnyObject?
    
    init(baseController: UIViewController, spotPicker: SpotPicker, completion: @escaping SpotPicker.Completion) {
        
        self.baseController = baseController
        self.spotPicker = spotPicker
        self.completion = completion
        
        super.init()
        
        self.retainCycle = self
    }
    
    fileprivate func dismiss(with result: SpotPicker.Result) {
        completion(result)
        baseController.dismiss(animated: true, completion: nil)
        retainCycle = nil
    }
}

// MARK: Picker
extension SpotPickerDelegate: ImagePickerDelegate {
    
    // MARK: Protocol
    fileprivate func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        finishPicker(from: imagePicker, with: images)
    }
    
    fileprivate func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        finishPicker(from: imagePicker, with: [])
    }
    
    fileprivate func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        finishPicker(from: imagePicker, with: images)
    }
    
    // Finish
    private func finishPicker(from controller: ImagePickerController, with images: [UIImage]) {
        
        // If empty, we send cancel
        guard let firstImage = images.first else {
            dismiss(with: .cancelled(.cancelPick))
            return
        }
        
        if let _ = spotPicker.spotConfigurator {
            pickedImages = images
            showTagView(with: firstImage)
        }
            
        else {
            dismiss(with: SpotPicker.Result.success(images))
        }
    }
}
// MARK: Cropper
extension SpotPickerDelegate: CameraSpotViewControllerDelegate {
    
    fileprivate func sendResult() {
        dismiss(with: .success(tagedImages))
    }
    
    func showTagView(with image: UIImage) {
        
        guard  let configurator = spotPicker.spotConfigurator else {
            fatalError("Shouldn't be here without a cropper configurator")
        }
        
        let cameraSpotView = configurator(image)
        cameraSpotView.delegate = self
        
        let imagePicker = spotPicker.imagePicker
        if let _ = imagePicker.presentedViewController {
            imagePicker.dismiss(animated: true) {
                imagePicker.present(cameraSpotView, animated: true, completion: nil)
            }
        }
            
        else {
            imagePicker.present(cameraSpotView, animated: true, completion: nil)
        }
    }
    
    fileprivate func camerSpotViewController(cameraSpotViewController: CameraSpotViewController, image: UIImage) {
        tagedImages.append(image)
        
        if tagedImages.count == pickedImages.count {
            sendResult()
        }
        else {
            let nextIndex = tagedImages.count
            let nextImage = pickedImages[nextIndex]
            showTagView(with: nextImage)
        }
    }
    
    fileprivate func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        tagedImages.append(image)
        
        if tagedImages.count == pickedImages.count {
            sendResult()
        }
        else {
            let nextIndex = tagedImages.count
            let nextImage = pickedImages[nextIndex]
            showTagView(with: nextImage)
        }
    }
    
    fileprivate func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(with: .cancelled(.cancelCrop))
    }
}


/*
 * ImagePickerCropper
 */
/// A image picker that can crop the image after selecting it
struct ImagePickerCropper {
    
    typealias Completion = (Result) -> Void
    typealias CropperCreator = (UIImage) -> TOCropViewController
    
    enum Error: Swift.Error {
        case cancelPick
        case cancelCrop
    }
    
    enum Result {
        case success([UIImage])
        case cancelled(Error)
    }
    
    /// The picker used to select the image(s)
    let imagePicker: ImagePickerController
    
    /// The closure used to create the `TOCropViewController`
    let cropperConfigurator: CropperCreator?
    
    /// Creates a new instance with the given picker and cropper configuration
    init(picker: ImagePickerController, cropperConfigurator: CropperCreator? = nil) {
        self.imagePicker = picker
        self.cropperConfigurator = cropperConfigurator
    }
    
    /// Show the picker from the given controller.
    func show(from controller: UIViewController, animated: Bool = true, completion: @escaping Completion) {
        
        imagePicker.delegate = PickerCropperDelegate(baseController: controller,
                                                     pickerCropper: self,
                                                     completion: completion)
        
        controller.present(imagePicker, animated: animated, completion: nil)
    }
}

/// The delegate which will handle the responses from picker and cropper
private class PickerCropperDelegate: NSObject {
    let baseController: UIViewController
    let pickerCropper: ImagePickerCropper
    let completion: ImagePickerCropper.Completion
    
    fileprivate var pickedImages: [UIImage] = []
    fileprivate var croppedImages: [UIImage] = []
    
    fileprivate var retainCycle: AnyObject?
    
    init(baseController: UIViewController, pickerCropper: ImagePickerCropper, completion: @escaping ImagePickerCropper.Completion) {
        
        self.baseController = baseController
        self.pickerCropper = pickerCropper
        self.completion = completion
        
        super.init()
        
        self.retainCycle = self
    }
    
    fileprivate func dismiss(with result: ImagePickerCropper.Result) {
        completion(result)
        baseController.dismiss(animated: true, completion: nil)
        retainCycle = nil
    }
}

// MARK: Picker
extension PickerCropperDelegate: ImagePickerDelegate {
    
    // MARK: Protocol
    fileprivate func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        finishPicker(from: imagePicker, with: images)
    }
    
    fileprivate func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        finishPicker(from: imagePicker, with: [])
    }
    
    fileprivate func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        finishPicker(from: imagePicker, with: images)
    }
    
    // Finish
    private func finishPicker(from controller: ImagePickerController, with images: [UIImage]) {
        
        // If empty, we send cancel
        guard let firstImage = images.first else {
            dismiss(with: .cancelled(.cancelPick))
            return
        }
        
        if let _ = pickerCropper.cropperConfigurator {
            pickedImages = images
            showCropper(with: firstImage)
        }
            
        else {
            dismiss(with: ImagePickerCropper.Result.success(images))
        }
    }
}

// MARK: Cropper
extension PickerCropperDelegate: TOCropViewControllerDelegate {
    
    fileprivate func sendResult() {
        dismiss(with: .success(croppedImages))
    }
    
    func showCropper(with image: UIImage) {
        
        guard  let configurator = pickerCropper.cropperConfigurator else {
            fatalError("Shouldn't be here without a cropper configurator")
        }
        
        let cropper = configurator(image)
        cropper.delegate = self
        
        let imagePicker = pickerCropper.imagePicker
        if let _ = imagePicker.presentedViewController {
            imagePicker.dismiss(animated: true) {
                imagePicker.present(cropper, animated: true, completion: nil)
            }
        }
            
        else {
            imagePicker.present(cropper, animated: true, completion: nil)
        }
    }
    
    fileprivate func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        croppedImages.append(image)
        
        if croppedImages.count == pickedImages.count {
            sendResult()
        }
        else {
            let nextIndex = croppedImages.count
            let nextImage = pickedImages[nextIndex]
            showCropper(with: nextImage)
        }
    }
    
    fileprivate func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(with: .cancelled(.cancelCrop))
    }
}
