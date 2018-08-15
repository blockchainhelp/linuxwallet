//
//  BackupViewController.swift
//  Blockchain
//
//  Created by Sjors Provoost on 19-05-15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class BackupViewController: UIViewController, TransferAllPromptDelegate {
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var backupWalletButton: UIButton!
    @IBOutlet weak var explanation: UILabel!
    @IBOutlet weak var backupIconImageView: UIImageView!
    
    var wallet: Wallet?
    var app: RootService?
    var transferredAll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryLabel.font = UIFont(name: "Montserrat-SemiBold", size: Constants.FontSizes.ExtraExtraLarge)
        explanation.font = UIFont(name: "GillSans", size: Constants.FontSizes.MediumLarge)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backupWalletButton.setTitle(NSLocalizedString("BACKUP FUNDS", comment: ""), for: UIControlState())
        backupWalletButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backupWalletButton.contentHorizontalAlignment = .center
        backupWalletButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        backupWalletButton.clipsToBounds = true
        backupWalletButton.layer.cornerRadius = Constants.Measurements.BackupButtonCornerRadius
        backupWalletButton.center = CGPoint(x: view.center.x, y: backupWalletButton.center.y)

        backupIconImageView.center = CGPoint(x: view.center.x, y: backupIconImageView.center.y)

        if let image = backupIconImageView.image {
            backupIconImageView.image? = image.withRenderingMode(.alwaysTemplate)
            backupIconImageView.tintColor = Constants.Colors.WarningRed
        }
        
        summaryLabel.text = NSLocalizedString("Backup Needed", comment: "")
        summaryLabel.center = CGPoint(x: view.center.x, y: summaryLabel.center.y)
        explanation.text = String(format: "%@\n\n%@", NSLocalizedString("The following 12 word Recovery Phrase will give you access to your funds in case you lose your password.", comment: ""), NSLocalizedString("Be sure to write down your phrase on a piece of paper and keep it somewhere safe and secure.", comment: ""))
        backupWalletButton.setTitle(NSLocalizedString("START BACKUP", comment: ""), for: UIControlState())
        
        if wallet!.isRecoveryPhraseVerified() {
            summaryLabel.text = NSLocalizedString("Backup Complete", comment: "")
            explanation.text = NSLocalizedString("Use your Recovery Phrase to restore your funds in case of a lost password.  Anyone with access to your Recovery Phrase can access your bitcoin, so keep it offline somewhere safe and secure.", comment: "")
            backupIconImageView.image = UIImage(named: "success")?.withRenderingMode(.alwaysTemplate)
            backupIconImageView.tintColor = Constants.Colors.SuccessGreen
            backupWalletButton.setTitle(NSLocalizedString("BACKUP AGAIN", comment: ""), for: UIControlState())
            
            if wallet!.didUpgradeToHd() && wallet!.getTotalBalanceForSpendableActiveLegacyAddresses() >= wallet!.dust() && navigationController!.visibleViewController == self && !transferredAll {
                let alertToTransferAll = UIAlertController(title: NSLocalizedString("Transfer imported addresses?", comment: ""), message: NSLocalizedString("Imported addresses are not backed up by your Recovery Phrase. To secure these funds, we recommend transferring these balances to include in your backup.", comment: ""), preferredStyle: .alert)
                alertToTransferAll.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                alertToTransferAll.addAction(UIAlertAction(title: NSLocalizedString("Transfer all", comment: ""), style: .default, handler: { void in
                    let transferAllController = TransferAllFundsViewController()
                    transferAllController.delegate = self
                    let navigationController = BCNavigationController(rootViewController: transferAllController, title: NSLocalizedString("Transfer All Funds", comment: ""))
                    self.app?.transferAllFundsModalController = transferAllController
                    self.present(navigationController!, animated: true, completion: nil)
                }))
                present(alertToTransferAll, animated: true, completion: nil)
            }
        }
        
        explanation.sizeToFit()
        explanation.center = CGPoint(x: view.frame.width/2, y: explanation.center.y)
        changeYPosition(view.frame.size.height - 40 - backupWalletButton.frame.size.height, view: backupWalletButton)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transferredAll = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if wallet!.isRecoveryPhraseVerified() {
            backupWalletButton.setTitle(NSLocalizedString("BACKUP AGAIN", comment: ""), for: UIControlState())
        } else {
            backupWalletButton.setTitle(NSLocalizedString("START BACKUP", comment: ""), for: UIControlState())
        }
    }
    
    func changeYPosition(_ newY: CGFloat, view: UIView) {
        view.frame = CGRect(x: view.frame.origin.x, y: newY, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    @IBAction func backupWalletButtonTapped(_ sender: UIButton) {
        if backupWalletButton.titleLabel!.text == NSLocalizedString("VERIFY BACKUP", comment: "") {
            performSegue(withIdentifier: "verifyBackup", sender: nil)
        } else {
            performSegue(withIdentifier: "backupWords", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backupWords" {
            let vc = segue.destination as! BackupWordsViewController
            vc.wallet = wallet
        }
        else if segue.identifier == "verifyBackup" {
            let vc = segue.destination as! BackupVerifyViewController
            vc.wallet = wallet
            vc.isVerifying = true
        }
    }
    
    func didTransferAll() {
        transferredAll = true
    }
    
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func showSyncingView() {
        let backupNavigation = self.navigationController as? BackupNavigationViewController
        backupNavigation?.busyView?.fadeIn()
    }
}
