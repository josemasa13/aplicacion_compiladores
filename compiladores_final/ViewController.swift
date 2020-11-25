//
//  ViewController.swift
//  compiladores_final
//
//  Created by Jose Alberto Marcial Sánchez on 24/11/20.
//  Copyright © 2020 José Alberto Marcial Sánchez. All rights reserved.
//

import UIKit
import Foundation

var vSpinner : UIView?
 
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

struct prog: Codable {
    var program: String
}

struct inputprog: Codable {
    var program: String
    var input: [String]
}


func sendProgram(newProg : prog) -> String{
    let url = URL(string: "https://tfd2onld3g.execute-api.us-east-1.amazonaws.com/dev/main")
    
    guard let requestUrl = url else { fatalError() }
    // Prepare URL Request Object
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
     
    // HTTP Request Parameters which will be sent in HTTP Request Body
    
    let jsonData = try! JSONEncoder().encode(newProg)
    var str : String="";

    // Set HTTP Request Body
    request.httpBody = jsonData;
    // Perform HTTP Request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
     
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let fdata = dataString.data(using: .utf8)!
                let json = try? JSONSerialization.jsonObject(with: fdata, options: [])

                if let dictionary = json as? [String: Any] {
                    let output : [Any] = dictionary["output"] as! [Any]
                    
                    for i in 0 ..< output.count{
                        str += "\(output[i])" + "\n"
                    }
                  
                    
                        
                }
            }
    }
    task.resume()
    return str;
}

class ViewController: UIViewController {

    @IBOutlet weak var textBox: UITextView!
    
    @IBOutlet weak var executeBut: UIButton!
    
    
    @IBOutlet weak var outputBox: UITextView!
    
    @IBOutlet weak var cleaner: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func sendRequest(_ sender: UIButton) {
        self.outputBox.text = "";
        self.showSpinner(onView: self.view)
        let newProg = prog(program: textBox.text!)
        let url = URL(string: "https://wsgrniiwba.execute-api.us-east-1.amazonaws.com/dev/main")
        
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        
        var jsonData = try! JSONEncoder().encode(newProg)
        // Set HTTP Request Body
        request.httpBody = jsonData;
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                var inputs = [String]()
                var statusCode = -1
                if let httpResponse = response as? HTTPURLResponse {
                    statusCode = httpResponse.statusCode
                    if statusCode == 202{
                            DispatchQueue.main.async {
                                //1. Create the alert controller.
                                let alert = UIAlertController(title: "Input", message: "Proporcione su entrada", preferredStyle: .alert)

                                //2. Add the text field. You can configure it however you need.
                                alert.addTextField { (textField) in
                                    textField.text = ""
                                }

                                // 3. Grab the value from the text field, and print it when the user clicks OK.
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                                    let textField = alert?.textFields![0].text // Force unwrapping because we know it exists.
                                    inputs.append(textField!);
                                    let newProgInput = inputprog(program: self.textBox.text!, input: inputs)
                                    
                                    jsonData = try! JSONEncoder().encode(newProgInput)
                                    
                                    request.httpBody = jsonData;
                                    let task2 = URLSession.shared.dataTask(with: request) { (data2, response2, error2) in
                                        self.removeSpinner()
                                        if let error = error2 {
                                            print("Error took place \(error)")
                                            return
                                        }
                                        
                                        
                                        if let httpResponse2 = response2 as? HTTPURLResponse {
                                            statusCode = httpResponse2.statusCode
                                            print("newStatus", statusCode)
                                            if(statusCode == 300){
                                                self.removeSpinner()
                                                if let data = data2, let dataString = String(data: data, encoding: .utf8) {
                                                    print("Hubo error")
                                                    DispatchQueue.main.async {
                                                        self.outputBox.text = dataString;
                                                    }
                                                }
                                                
                                            // input needs to be provided
                                            } else if(statusCode == 202){
                                                if let data = data2, let dataString = String(data: data, encoding: .utf8) {
                                                    self.removeSpinner()
                                                    let fdata = dataString.data(using: .utf8)!
                                                    let json = try? JSONSerialization.jsonObject(with: fdata, options: [])

                                                    if let dictionary = json as? [String: Any] {
                                                        let output : String = dictionary["output"] as! String
                                                        print(output)
                                                        
                                                        
                                                        DispatchQueue.main.async {
                                                            self.outputBox.text += output;
                                                        }
                                                
                                                        
                                                    }
                                                }
                                            } else{
                                                print("Flujo de ejecución normal")
                                                 if let data = data2, let dataString = String(data: data, encoding: .utf8) {
                                                     self.removeSpinner()
                                                    let fdata = dataString.data(using: .utf8)!
                                                    let json = try? JSONSerialization.jsonObject(with: fdata, options: [])

                                                    if let dictionary = json as? [String: Any] {
                                                        let output : String = dictionary["output"] as! String
                                                        
                                                        DispatchQueue.main.async {
                                                            self.outputBox.text += output;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    task2.resume()
                                }))

                                // 4. Present the alert.
                                self.present(alert, animated: true, completion: nil)

                            }
                            
                        
                    } else if(statusCode == 300){
                        if let data = data, let dataString = String(data: data, encoding: .utf8) {
                            print("Hubo error")
                            self.removeSpinner()
                            DispatchQueue.main.async {
                                self.outputBox.text = dataString;
                            }
                        }
                    } else{
                        print("Flujo de ejecución normal")
                        if let data = data, let dataString = String(data: data, encoding: .utf8) {
                            self.removeSpinner()
                           let fdata = dataString.data(using: .utf8)!
                           let json = try? JSONSerialization.jsonObject(with: fdata, options: [])

                           if let dictionary = json as? [String: Any] {
                               let output : String = dictionary["output"] as! String
                               print(output)
                               
                               DispatchQueue.main.async {
                                   self.outputBox.text = output;
                               }
                           }
                       }
                    }
            }
        }
        task.resume()
    }
    
    @IBAction func cleanOutput(_ sender: Any) {
        outputBox.text = "";
    }
    

}

