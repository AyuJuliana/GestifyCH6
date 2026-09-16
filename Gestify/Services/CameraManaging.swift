//
//  CameraManaging.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import AVFoundation
import CoreVideo
import UIKit

protocol CameraManaging: AnyObject {
    var session: AVCaptureSession { get }
    var position: AVCaptureDevice.Position { get }
    var delegate: CameraManagerDelegate? { get set }
    func start()
    func stop()
    func switchCamera()
}

protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManaging, didCapture pixelBuffer: CVPixelBuffer)
    func cameraManagerDidFailPermission(_ manager: CameraManaging)
}

final class CameraManager: NSObject, CameraManaging {
    let session = AVCaptureSession()
    private(set) var position: AVCaptureDevice.Position = .front

    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "camera.frame.queue")
    private var currentInput: AVCaptureDeviceInput?

    weak var delegate: CameraManagerDelegate?

    func switchCamera() {
        queue.sync {
            let newPosition: AVCaptureDevice.Position = self.position == .front ? .back : .front
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: device) else { return }

            self.session.beginConfiguration()
            if let old = self.currentInput { self.session.removeInput(old) }

            guard self.session.canAddInput(newInput) else {
                if let old = self.currentInput, self.session.canAddInput(old) {
                    self.session.addInput(old)
                }
                self.session.commitConfiguration()
                return
            }
            self.session.addInput(newInput)
            self.currentInput = newInput
            self.position = newPosition
            self.session.commitConfiguration()
        }
    }

    private func configureAndStart() {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        currentInput = input

        videoOutput.setSampleBufferDelegate(self, queue: queue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        session.commitConfiguration()
        queue.async { self.session.startRunning() }
    }

    func start() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    self?.delegate?.cameraManagerDidFailPermission(self!)
                    return
                }
                self?.configureAndStart()
            }
        case .denied, .restricted:
            delegate?.cameraManagerDidFailPermission(self)
        @unknown default:
            break
        }
    }

    func stop() {
        queue.async { self.session.stopRunning() }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                        didOutput sampleBuffer: CMSampleBuffer,
                        from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        delegate?.cameraManager(self, didCapture: pixelBuffer)
    }
}
