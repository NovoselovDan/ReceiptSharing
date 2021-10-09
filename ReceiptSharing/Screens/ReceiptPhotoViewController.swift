import AVFoundation
import UIKit

class ReceiptPhotoViewController: UIViewController {
    
    var previewView = UIView()
    var boxView: UIView!
    let captureButton: UIButton = UIButton()
    
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var captureDevice : AVCaptureDevice!
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.layer.masksToBounds = true
        previewView.layer.cornerCurve = .continuous
        previewView.layer.cornerRadius = 20
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        let layoutGuide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            previewView.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor),
            layoutGuide.bottomAnchor.constraint(equalTo: previewView.bottomAnchor),
            layoutGuide.rightAnchor.constraint(equalTo: previewView.rightAnchor)
        ])
        
        let maskImage = UIImage(named: "mask")!
        let imageView = UIImageView(image: maskImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerCurve = .continuous
        imageView.layer.cornerRadius = 20
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: previewView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: previewView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: previewView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: previewView.centerYAnchor)
        ])
        boxView = imageView
        
        let btnSize = CGSize(width: 84, height: 84)
        captureButton.addTarget(self, action: #selector(ditTapCapture), for: .touchUpInside)
        captureButton.layer.cornerRadius = btnSize.height / 2
        captureButton.layer.masksToBounds = true
        captureButton.backgroundColor = .white
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.widthAnchor.constraint(equalToConstant: btnSize.width),
            captureButton.heightAnchor.constraint(equalToConstant: btnSize.height),
            captureButton.centerXAnchor.constraint(equalTo: boxView.centerXAnchor),
            boxView.bottomAnchor.constraint(equalTo: captureButton.bottomAnchor, constant: 34)
        ])
        
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.setupAVCapture()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let previewLayer = self.previewLayer else { return }
        previewLayer.bounds = previewView.bounds
    }
    
    @objc
    private func ditTapCapture() {
        navigationController?.pushViewController(ReceiptSplitViewController(), animated: true)
    }
}

extension ReceiptPhotoViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func setupAVCapture(){
        session.sessionPreset = AVCaptureSession.Preset.high // .vga640x480
        guard let device = AVCaptureDevice
                .default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                         for: .video,
                         position: AVCaptureDevice.Position.back) else {
                    return
                }
        captureDevice = device
        beginSession()
    }
    
    func beginSession(){
        var deviceInput: AVCaptureDeviceInput!
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            guard deviceInput != nil else {
                print("error: cant get deviceInput")
                return
            }
            
            if self.session.canAddInput(deviceInput){
                self.session.addInput(deviceInput)
            }
            
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue)
            
            if session.canAddOutput(self.videoDataOutput){
                session.addOutput(self.videoDataOutput)
            }
            
            videoDataOutput.connection(with: .video)?.isEnabled = true
            
            previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            previewLayer.backgroundColor = UIColor.orange.cgColor
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            let rootLayer: CALayer = self.previewView.layer
            rootLayer.masksToBounds = true
            previewLayer.frame = rootLayer.bounds
            rootLayer.addSublayer(self.previewLayer)
            session.startRunning()
        } catch let error as NSError {
            deviceInput = nil
            print("error: \(error.localizedDescription)")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // do stuff here
    }
    
    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
    }
    
}
