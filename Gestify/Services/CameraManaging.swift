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
    var delegate: CameraManagerDelegate? { get set }
    func start()
    func stop()
}

protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManaging, didCapture pixelBuffer: CVPixelBuffer)
    func cameraManagerDidFailPermission(_ manager: CameraManaging)
}

final class CameraManager: NSObject, CameraManaging {
    let session = AVCaptureSession()

    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "camera.frame.queue")

    weak var delegate: CameraManagerDelegate?

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

    private func configureAndStart() {
        session.beginConfiguration()
        session.sessionPreset = .high

        // Front camera so the user can see their own hand while gesturing
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        videoOutput.setSampleBufferDelegate(self, queue: queue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        session.commitConfiguration()
        queue.async { self.session.startRunning() }
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
