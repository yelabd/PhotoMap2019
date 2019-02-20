//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cameraButton: UIButton!

    var pickedImage: UIImage!
    var fullScreenImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraButton.layer.cornerRadius = cameraButton.frame.height/2

        // San Francisco Lat, Long = latitude: 37.783333, longitude: -122.416667
        let mapCenter = CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667)
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: mapCenter, span: mapSpan)

        // Set animated property to true to animate the transition to the region
        mapView.setRegion(region, animated: false)
        mapView.delegate = self
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullImageSegue" {
            let fullScreenImageViewController = segue.destination as! FullImageViewController
            fullScreenImageViewController.image = self.fullScreenImage
        } else if segue.identifier == "tagSegue" {
            let locationsViewController = segue.destination as!LocationsViewController
            locationsViewController.delegate = self
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }

        self.present(vc, animated: true, completion: {
            self.performSegue(withIdentifier: "tagSegue", sender: nil)
        })
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage

        self.pickedImage = editedImage

        // Dismiss UIImagePickerController to go back to PhotoMapViewController
        dismiss(animated: true, completion: nil)
    }

    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
        }

        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo

        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView

        // Add the image you stored from the image picker
        imageView.image = thumbnail

        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? PhotoAnnotation {
            self.fullScreenImage = annotation.photo
            self.performSegue(withIdentifier: "fullImageSegue", sender: nil)
        }
    }

    // MARK: - LocationsViewControllerDelegate

    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {

        let annotation = PhotoAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        annotation.photo = self.pickedImage

        mapView.addAnnotation(annotation)
    }
}
