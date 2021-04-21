//
//  ViewController.swift
//  QRCodeReader
//
//  Created by Adriano Rodrigues Vieira on 21/04/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var openPageButton: UIButton!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var page: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Esse cara eh o dispositivo fisico
        configure()
    }
    
    func configure() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            let input: AnyObject? = try? AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input as! AVCaptureInput)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            qrCodeFrameView = UIView()
            qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView?.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView!)
            view.bringSubviewToFront(qrCodeFrameView!)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func openPageButtonPressed(_ sender: UIButton) {        
        self.configure()
        self.openInSafari()
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
                    
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj ) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds
            
            if metadataObj.stringValue != nil {
                self.page = metadataObj.stringValue
                view.bringSubviewToFront(self.openPageButton)
                // self.openInSafari(url: metadataObj.stringValue)
            }
        }
    }
    
    private func openInSafari() {
        if let safeStringUrl = page {
            if let safeUrl = URL(string: safeStringUrl) {
                UIApplication.shared.open(safeUrl)
            }
        }
    }
}


