//
//  ViewController.swift
//  magicRequestData
//
//  Created by bruno raupp kieling on 6/15/16.
//  Copyright © 2016 brunokieling. All rights reserved.
//

import UIKit


//dissmiss keyboard at any click on screen
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

//this work belive it
protocol DelegateProtocol {
    func didReceiveAMessage(_ message: String!)
    func didReceiveOtherMessage (message1: String!, message2: Double!)
    func didReceiveAlertMessage()
}

//i copy from somewhere 5 months ago, but it workis, this is what makes the url request and gets its html page... and its parsed (bad english, i know)
struct RemoteCenter{
    var delegate : DelegateProtocol?
    
    func findCard(_ cardName:String){
        
        // Define server side script URL
        let scriptUrl = "http://www.ligamagic.com.br/?view=cards%2Fsearch&card="
        var rewrite = ""
        let text = cardName.characters.split{$0 == " "}.map(String.init)
        for split in text {
            rewrite = rewrite + "+" + split
        }
        // Add one parameter
        let urlWithParams = scriptUrl + "\(rewrite)"
        
        // Create NSURL Ibject
        let myUrl = URL(string: urlWithParams);
        
        // Creaste URL Request
        let request = NSMutableURLRequest(url:myUrl!);
        
        // Set request HTTP method to GET. It could be POST as well
        request.httpMethod = "GET"
        //request.addValue("Token token=884288bae150b9f2f68d8dc3a932071d", forHTTPHeaderField: "Authorization")
        
        var testString = ""
        // Excute HTTP Request
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            testString = String(describing: responseString)
            
            let getPrice = Regex("(\\d+)\\,(\\d+)")
            let menorValor = Regex("VETprecoMenor\\[(\\d+)\\] = \"(\\d+)\\,(\\d+)\"")
            
            let getProblem = Regex("<title>Busca:")
            if (getProblem?.match(input: testString))!{

                self.delegate?.didReceiveAlertMessage()
                return
            }

            var vet = menorValor!.test(testString)
            
            
            
            var vet1 = [Double]()
            var menor = DBL_MAX
            for a in vet{
                let stringValue = getPrice!.test(a)
                for b in stringValue{
                    let replaced = String(b.characters.map {
                        $0 == "," ? "." : $0
                        })
                    print("valor: " + replaced)
                    let number = Double(replaced)!
                    vet1.append(number)
                    if number < menor {
                        menor = number
                    }
                }
            }
            
            let medioValor = Regex("VETprecoMedio\\[(\\d+)\\] = \"(\\d+)\\,(\\d+)\"")
            vet = medioValor!.test(testString)
            
            for a in vet{
                let stringValue = getPrice!.test(a)
                for b in stringValue{
                    let replaced = String(b.characters.map {
                        $0 == "," ? "." : $0
                        })
                    print(replaced)
                    let number = Double(replaced)!
                    vet1.append(number)
                }
            }
            let maiorValor = Regex("VETprecoMaior\\[(\\d+)\\] = \"(\\d+)\\,(\\d+)\"")
            vet = maiorValor!.test(testString)
            
            for a in vet{
                let stringValue = getPrice!.test(a)
                for b in stringValue{
                    let replaced = String(b.characters.map {
                        $0 == "," ? "." : $0
                        })
                    print(replaced)
                    let number = Double(replaced)!
                    vet1.append(number)
                }
            }
            
            let stringURL = Regex("VETimage\\[(\\d+)\\] = \".*\"")
            let imageURLvet = stringURL!.test(testString)
            var onlyImageUrl = [String]()
            for string in imageURLvet{
                let aux = Regex("http.*.jpg")
                //let aux = Regex("http:\/\/[a-zA-Z.\/0-9]+")
                let auxOnlyimage = aux!.test(string)
                print(auxOnlyimage)
                onlyImageUrl.append(auxOnlyimage[0])
            }
            if onlyImageUrl.count > 0{
                self.delegate?.didReceiveAMessage(onlyImageUrl[0])
            }

            self.delegate?.didReceiveOtherMessage(message1: cardName, message2: menor)
        }
        task.resume()
    }
    
}

// this should be okay
class ViewController: UIViewController, DelegateProtocol, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var valorTotal: UILabel!
    var valor = 0.0

    @IBOutlet weak var textField: UITextField!
    //@IBOutlet weak var imageView: UIImageView!
    var remote = RemoteCenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        let test = "https://upload.wikimedia.org/wikipedia/en/a/aa/Magic_the_gathering-card_back.jpg"
        let url = URL(string: test)
        let data = try? Data(contentsOf: url!)
        //imageView.image = UIImage(data: data!)
        remote.delegate = self
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchCard(_ sender: AnyObject) {
        let test = "https://upload.wikimedia.org/wikipedia/en/a/aa/Magic_the_gathering-card_back.jpg"
        let url = URL(string: test)
        let data = try? Data(contentsOf: url!)
        //self.imageView.image = UIImage(data: data!)
        remote.findCard(textField.text!)
        
    }
    
  
    @IBAction func calcularTotal(_ sender: Any) {
        print(vetPreco)
        valor = 0.0
        if vetName.count == 0 {
            return
        } else {
            print(vetPreco.count)
            for i in 0 ..< vetPreco.count{
                valor += vetPreco[i]
            }
        }
        
        valorTotal.text = "Total: \(valor)"
    }
    
    //all this messages works, belive it
    func didReceiveAMessage(_ message: String!) {
        
        let url = URL(string: message)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async(execute: {
                //self.imageView.image = UIImage(data: data!)
            });
        }
    }
    
    func didReceiveOtherMessage(message1 : String!, message2 : Double!){
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            //let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async(execute: {
                //menor = data!
                //self.imageView.image = UIImage(data: data!)
                self.addContentTableView(name: message1, price: message2)
                
            });
        }
    }
    
    func didReceiveAlertMessage() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            //let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async(execute: {
                let alert = UIAlertController(title: "Alert", message: "Carta não encontrada", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            });
        }
    }
    
    //this table sucks, but it works too
    
    @IBOutlet weak var tableView: UITableView!

    var vetName = [String!]()
    var vetPreco = [Double!]()
    
    func addContentTableView(name : String!, price : Double!){
        print("adicionou conteudo")
        vetName.append(name)
        vetPreco.append(price)
        DispatchQueue.main.async{

            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vetName.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print ("preenchendo tabela")
        
        let cell:Customcell = tableView.dequeueReusableCell(withIdentifier: "umaCelula") as! Customcell
        cell.labelText.text = vetName[indexPath.row]
        cell.labelPrice.text = String(vetPreco[indexPath.row])
        
        //print (cell.labelText.text)
        return cell
    }

}

/* para segurança dos usuários
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
 <key>NSExceptionDomains</key>
 <dict>
    <key>yourdomain.com</key>
    <dict>
        <key>NSIncludesSubdomains</key>
        <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
        <true/>
        <key>NSTemporaryExceptionMinimumTLSVersion</key>
        <string>TLSv1.1</string>
    </dict>
 </dict>
</dict>
 */
