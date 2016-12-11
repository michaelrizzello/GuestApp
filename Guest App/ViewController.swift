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
    
    var locationPin : MKAnnotation? = nil
    
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapView.delegate = self
    
        self.timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true);

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
                    
                    self.updateMapLocation(orderID: (DataManager.sharedInstance.currentOrder?.orderID)!)
                    
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
    
    private func updateMapLocation(orderID : Int)
    {
        APIManager.sharedInstance.trackOrder(orderID: orderID, callback:{ (success, response) in
            if (success)
            {
                if let response = response
                {
                    print(response)
                    self.isTracking = true
                    if DataManager.sharedInstance.currentOrder != nil
                    {
                        DataManager.sharedInstance.currentOrder?.orderLocation = OrderLocation.init(locationObj: response)
                        
                        OperationQueue.main.addOperation {
                            if let currentOrder = DataManager.sharedInstance.currentOrder
                            {
                                if let orderLocation = currentOrder.orderLocation
                                {
                                    //Add pin for location
                                    
                                    // self.centerMapOnLocation(location: orderLocation.orderLocation)
                                    
                                    
                                    self.locationPin = CustomAnnotation.init(coord: orderLocation.orderLocation)
                                    //                                    self.locationPin?.coordinate = orderLocation.orderLocation!
                                    //                                    self.locationPin?.title = "Order #\(currentOrder.orderID) Location"
                                    self.mapView.addAnnotation(self.locationPin!)
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
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

