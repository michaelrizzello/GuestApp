//
//  ViewController.swift
//  Guest App
//
//  Created by Michael Rizzello on 2016-12-09.
//  Copyright © 2016 Michael Rizzello. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    private var isTracking : Bool = false;
    
    let regionRadius: CLLocationDistance = 1000
    
    var locationPin : CustomAnnotation? = nil
    
    @IBOutlet weak var createOrderButton: UIButton!
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let caraBlue = UIColor.init(red: 0, green: 91/255, blue: 171/255, alpha: 0)
        
        self.navigationItem.title = "Cara Guest App"
        self.navigationController?.navigationBar.tintColor = caraBlue
        self.navigationController?.navigationBar.backgroundColor = caraBlue
        self.navigationController?.navigationBar.barTintColor = caraBlue
        self.navigationController?.navigationBar.isOpaque = false;
        self.navigationController?.navigationBar.isTranslucent = false;

        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white
        ]
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default;
        
        self.mapView.delegate = self
    
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true);

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createOrder(_ sender: Any)
    {
        APIManager.sharedInstance.createOrder(callback: { (success, response) in
            if (success)
            {
                if let response = response
                {
                    DataManager.sharedInstance.currentOrder = Order.init(orderObj: response)
                    
                    self.isTracking = true
                    
                    OperationQueue.main.addOperation {
                        if let currentOrder = DataManager.sharedInstance.currentOrder
                        {
                            self.orderIdLabel.text = "\(currentOrder.orderID)"
                        }
                    }
                }
            }
            
            
        }, errorCallback: { (error) in
            if let error = error
            {
                print(error)
            }
        })
    }
    
    func update() -> Void
    {
        if (self.isTracking == false)
        {
            return
        }
        
        if let order = DataManager.sharedInstance.currentOrder
        {
            updateMapLocation(orderID: order.orderID)
        }
    }
    
    //MKAnnotation Delegate Method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is CustomAnnotation)
        {
            return nil
        }

        let reuseId = "driverPin"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            anView?.annotation = annotation
        }
        
        anView?.image = UIImage(named:"taxi-other")
        return anView
    }
    
    private func updateMapLocation(orderID : Int)
    {
        APIManager.sharedInstance.trackOrder(orderID: orderID, callback:{ (success, response) in
            if (success)
            {
                if let response = response
                {
                    self.isTracking = true
                    if DataManager.sharedInstance.currentOrder != nil
                    {
                        DataManager.sharedInstance.currentOrder?.orderLocation = OrderLocation.init(locationObj: response)
                        
                        OperationQueue.main.addOperation {
                            if let currentOrder = DataManager.sharedInstance.currentOrder
                            {
                                if let orderLocation = currentOrder.orderLocation
                                {
                                    if (self.locationPin == nil)
                                    {
                                        self.locationPin = CustomAnnotation.init(coord: orderLocation.orderLocation)
                                        self.mapView.addAnnotation(self.locationPin!)
                                        self.centerMapOnLocation(location: orderLocation.orderLocation)
                                    }
                                    else {
                                        self.centerMapOnLocation(location: orderLocation.orderLocation)
                                        self.locationPin?.coordinate = orderLocation.orderLocation
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            
        }, errorCallback: { (error) in
            if let error = error
            {
                print(error)
            }
        })
    }
    
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

