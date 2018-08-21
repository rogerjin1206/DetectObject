//
//  ViewController.swift
//  CameraObjectDetection
//
//  Created by Euijae Hong on 2018. 8. 10..
//  Copyright © 2018년 JAEJIN. All rights reserved.
//

import UIKit
import AVKit
import Vision


class ViewController: UIViewController {
    
    var shaperLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
        view.layer.addSublayer(self.shaperLayer)
        
    }

}

extension ViewController {
    
    // Setup Camera
    private func setupCamera() {
        
        let captureSesstion = AVCaptureSession()
        captureSesstion.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSesstion.addInput(input)
        captureSesstion.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSesstion)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        print("previewLayer :",previewLayer.frame)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSesstion.addOutput(dataOutput)
        
    }
    
}


//MARK:- AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectRectanglesRequest {[weak self] (req, error) in
            
            if let err = error { print(err.localizedDescription) }
            guard let results = req.results as? [VNRectangleObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            
            DispatchQueue.main.async {
                
                guard let width = self?.view.frame.width else { return }
                guard let height = self?.view.frame.height else { return }
                
                let rectangle = UIBezierPath()
                
                rectangle.move(to: CGPoint(x: width * firstObservation.topLeft.x, y: height * firstObservation.topLeft.y))
                rectangle.addLine(to: CGPoint(x: width * firstObservation.bottomLeft.x, y: height * firstObservation.bottomLeft.y))
                rectangle.addLine(to: CGPoint(x: width * firstObservation.bottomRight.x, y: height * firstObservation.bottomRight.y))
                rectangle.addLine(to: CGPoint(x: width * firstObservation.topRight.x, y: height * firstObservation.topRight.y))
                
                rectangle.close()
                
                self?.shaperLayer.path = rectangle.cgPath
                self?.shaperLayer.fillColor = UIColor.clear.cgColor
                self?.shaperLayer.strokeColor = UIColor.blue.cgColor
                
            }
            
        }
        
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    

    
}

