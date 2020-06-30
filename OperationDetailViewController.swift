//
//  OperationDetailViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.06.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import ReSwift
import Alamofire


protocol ScanDelegate{
    func passString(scandata: String)
}

class OperationDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ICellConfiguratorDelegate, DataEnteredDelegate {
    func userDidEnterInformation(array: [String]) {
        arrayData = array
    }
    
    var presenter: PaymentDetailsPresenter?
     var sourceConfigurations: [ICellConfigurator]?
     var destinationConfigurations: [ICellConfigurator]?
     var delegate: FreeDetailsViewControllerDelegate?
     var remittanceSourceView: RemittanceOptionView!
      var remittanceDestinationView: RemittanceOptionView!
    var sourceValue: Any?
    var sourceConfig: Any?
    var destinationConfig: Any?
    var destinationValue: Any?
    var scanDelegate: ScanDelegate?

 
    
    @IBAction func scanButton(_ sender: Any) {
       
    performSegue(withIdentifier: "scan", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan", let secondViewController = segue.destination as? ScannerViewController  {
               secondViewController.delegate = self
           }
       }
    @IBOutlet var ViewForCollectionView: UIView!
    func newState(state: VerificationCodeState) {
        guard state.isShown == true else {
            return
        }
    }
    
    @IBOutlet weak var sourcePagerView: PagerView!

    func didReciveNewValue(value: Any, from configurator: ICellConfigurator) {
            if let sourceConfig = sourceConfigurations?.filter({ $0 == configurator }).first {
                switch (sourceConfig, value) {
                case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                    delegate?.didChangeSource(paymentOption: .option(destinationOption))
                    break
                default:
                    break
                }
                self.sourceConfig = sourceConfig
             self.sourceValue = value
            } else if let destinationConfig = destinationConfigurations?.filter({ $0 == configurator }).first {
                switch (destinationConfig, value) {
                case (is PaymentOptionsPagerItem, let destinationOption as PaymentOption):
                    delegate?.didChangeDestination(paymentOption: .option(destinationOption))
                    break
                case (is CardNumberPagerItem, let destinationOption as String):
                    delegate?.didChangeDestination(paymentOption: .cardNumber(destinationOption))
                    break
                case (is PhoneNumberPagerItem, let destinationOption as String):
                    delegate?.didChangeDestination(paymentOption: .phoneNumber(destinationOption))
                    break
                case (is AccountNumberPagerItem, let destinationOption as String):
                    delegate?.didChangeDestination(paymentOption: .accountNumber(destinationOption))
                    break
                default:
                    break
                }
                self.destinationConfig = destinationConfig
                self.destinationValue = value
            }
        }
    
  
    @IBOutlet weak var titleLabel: UILabel!
    var operationList = OperationsDetails()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
              if navigationController == nil {
                  dismiss(animated: true, completion: nil)
              }
    }
    
    var arrayData = [String()]{
        didSet{
            if arrayData.count > 2{
                viewWillLayoutSubviews()
          
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(arrayData)")
        self.collectionView!.reloadData()
        self.collectionView!.setNeedsDisplay()
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let source = sourceConfigurations{
                                    sourcePagerView.setConfig(config: source)
                                  
                             }
        collectionView.register(UINib(nibName: "InputCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InputCollectionViewCell")
        titleLabel.text = operationList.nameList?[0].value
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return operationList.parameterList?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputCollectionViewCell", for: indexPath) as! InputCollectionViewCell
        cell.label.text = operationList.parameterList?[indexPath.row].title
        cell.textField.placeholder = operationList.parameterList?[indexPath.row].mask
        if arrayData.count > 2{
            cell.textField.text = arrayData[indexPath.row]
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: self.collectionView.bounds.height/5)
    }
    
    
    

}



