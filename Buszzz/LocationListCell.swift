//
//  LocationListCell.swift
//  Buszzz
//
//  Created by Calios on 15/03/2017.
//  Copyright © 2017 Calios. All rights reserved.
//

import UIKit

// LocationListCellIdentifier
// rgb(254, 191, 76)
let BzThemeColor: UIColor = #colorLiteral(red: 1, green: 0.7896828055, blue: 0.3670255542, alpha: 1)
let BzOrangeColor: UIColor = #colorLiteral(red: 0.9921568627, green: 0.4980392157, blue: 0.137254902, alpha: 1)
let BzDarkGrayColor : UIColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
let BzLightGrayColor : UIColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)


class LocationListCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var headingLine: UIView!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    
    @IBOutlet weak var locationImgView: UIImageView!
    @IBOutlet weak var distanceImgView: UIImageView!
    @IBOutlet weak var frequencyImgView: UIImageView!
    
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var startSwitch: UISwitch!
    
    var onSwitchClick: ((Bool) -> ())?
    var onSettingPressed: (() -> ())?
    
    override func awakeFromNib() {
        bgView.layer.shadowOffset = CGSize.zero
        bgView.layer.shadowOpacity = 0.3
        bgView.layer.shadowRadius = 1
        bgView.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func startSwitchValueChanged(_ sender: UISwitch) {
        onSwitchClick?(sender.isOn)
    }
    
    @IBAction func settingBtnPressed(_ sender: UIButton) {
        onSettingPressed?()
    }

    public func configureCell(location: Location) {
        configureText(location: location)
        configureCellStatus(status: location.isDetecting)
    }
    
    // Set text.
    private func configureText(location: Location) {
        memoLabel.text = location.memo
        locationLabel.text = location.address
        distanceLabel.text = String(distanceNames[location.distanceIndex]) + "m"
        intervalLabel.text = String(intervalNames[location.intervalIndex]) + "s"
    }
    
    // Set color and image.
    private func configureCellStatus(status: Bool) {
        headingLine.backgroundColor = status ? BzThemeColor : BzLightGrayColor
        memoLabel.textColor      = status ? BzOrangeColor : BzLightGrayColor
        locationLabel.textColor  = status ? BzDarkGrayColor : BzLightGrayColor
        distanceLabel.textColor  = status ? BzDarkGrayColor : BzLightGrayColor
        intervalLabel.textColor = status ? BzDarkGrayColor : BzLightGrayColor
        
        locationImgView.image    = status ? #imageLiteral(resourceName: "location_orange") : #imageLiteral(resourceName: "location_gray")
        distanceImgView.image    = status ? #imageLiteral(resourceName: "distance_orange") : #imageLiteral(resourceName: "distance_gray")
        frequencyImgView.image   = status ? #imageLiteral(resourceName: "time_orange") : #imageLiteral(resourceName: "time_gray")
        
        startSwitch.isOn         = status
        settingButton.isEnabled  = !status
        let img = status ? #imageLiteral(resourceName: "setting_gray") : #imageLiteral(resourceName: "setting_orange")
        settingButton.setImage(img, for: .normal)
    }
}
