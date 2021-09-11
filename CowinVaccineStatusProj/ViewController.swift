//
//  ViewController.swift
//  CowinVaccineStatusProj
//
//  Created by Sandeep Kumar on 11/09/21.
//

import UIKit

class ViewController: UIViewController {
    var txnId: String = ""
    
    private let nameField: UITextField = {
        let field = UITextField(frame: .zero)
        field.backgroundColor = .systemGray6
        field.placeholder = "Enter Full Name..."
        return field
    }()
    
    private let mobileNumberField: UITextField = {
        let field = UITextField(frame: .zero)
        field.backgroundColor = .white
        field.backgroundColor = .systemGray6
        field.placeholder = "Enter mobile number..."
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField(frame: .zero)
        field.backgroundColor = .white
        field.backgroundColor = .systemGray6
        field.placeholder = "Enter email..."
        return field
    }()
    
    private let getVaccineStatusBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .purple
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.cornerRadius = 5
        btn.setTitle("Get Vaccine Status", for: .normal)
        
        btn.addTarget(self, action: #selector(getVaccineStatusTapped), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vaccination Status API"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .systemBackground
        view.addSubview(nameField)
        view.addSubview(mobileNumberField)
        view.addSubview(emailField)
        view.addSubview(getVaccineStatusBtn)
        
        nameField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        let btnWidth: CGFloat = 280.0
        let btnHeight: CGFloat = 50.0
        let btnLeft: CGFloat = (view.width - btnWidth)/2
        
        let textFieldWidth: CGFloat = 320.0
        let textFieldHeight: CGFloat = 40.0
        let textFieldBottomPadding: CGFloat = 20.0
        let textFieldLeft = (view.width - textFieldWidth)/2
        
        nameField.frame = CGRect(x: textFieldLeft, y: view.height/3.5, width: textFieldWidth, height: textFieldHeight)
        mobileNumberField.frame = CGRect(x: textFieldLeft, y: nameField.bottom + textFieldBottomPadding , width: textFieldWidth, height: textFieldHeight)
        emailField.frame = CGRect(x: textFieldLeft, y: mobileNumberField.bottom + textFieldBottomPadding, width: textFieldWidth, height: textFieldHeight)
        
        getVaccineStatusBtn.frame = CGRect(x: btnLeft, y: emailField.bottom + textFieldBottomPadding,width: btnWidth,height: btnHeight)
    }
    
}
extension ViewController {
    @objc private func getVaccineStatusTapped() {
        
        // you should check for other things like if mobile number is only consisting of digits, email is valid etc.
        guard let name = nameField.text, let email = emailField.text, let number = mobileNumberField.text,
              !name.isEmpty, !email.isEmpty, !number.isEmpty
        else {
            self.throwInvalidInputError(with: "Please fill in all the fields")
            return
        }
        
        WebService.shared.getOtp(for: email,name, number,expecting: GetOtpResult.self) { res in
            DispatchQueue.main.async {
                switch res {
                case .failure:
                    self.throwInvalidInputError(with: "Info provided by you is incorrect")
                    break
                case .success(let res):
                    if res.txnId != nil {
                        self.txnId = res.txnId!
                        self.presetGetOTPAlert()
                        return
                    }
                    self.throwInvalidInputError(with: "Info provided by you is incorrect")
                    break
                }
            }
        }
    }
}

extension ViewController {
    func presetGetOTPAlert() {
        let alert = UIAlertController.init(title: "please provide the otp",
                                           message: "Needed to determine the vaccine status", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter OTP"
            textField.textContentType = .oneTimeCode
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submit = UIAlertAction(title: "Confirm", style: .default) {[weak self] action in
            guard let self = self, !self.txnId.isEmpty
            else {
                return
            }
            
            let textField = alert.textFields![0] as UITextField
            guard let otp = textField.text, !otp.isEmpty
            else {
                // you should consider giving a haptic here
                return
            }
            
            self.getVaccineStatusFromOtp(txnId: self.txnId, otp: otp)
            self.txnId = ""
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(submit)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getVaccineStatusFromOtp(txnId: String, otp: String) {
        WebService.shared.getVaccinationStatus(with: txnId,
                                               otp: otp,
                                               expecting: VaccineStatusResult.self) {[weak self] res in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                switch res {
                case .success(let vaccinationStatusObj):
                    for i in 0...2 {
                        if i == vaccinationStatusObj.vaccination_status {
                            self.showOkayAlert(with: "Success", msg: "You have taken the following number of vaccines: \(i)")
                            self.resetAll()
                            return
                        }
                    }
                    break
                case .failure:
                    break
                }
            }
        }
    }
}

extension ViewController {
    func throwInvalidInputError(with msg: String) {
        showOkayAlert(with: "Something's Wrong", msg: msg)
    }
    
    func showOkayAlert(with title:String, msg: String) {
        let alert = UIAlertController(title:title,
                                      message: msg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay",
                                      style: .cancel,
                                      handler:  nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetAll() {
        emailField.text = ""
        nameField.text = ""
        mobileNumberField.text = ""
        txnId = ""
    }
}

