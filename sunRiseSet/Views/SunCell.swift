//
//  SunCell.swift
//  sunRiseSet
//
//  Created by David Chester on 1/29/22.
//


import UIKit

class SunCell : UITableViewCell {
    
    static let identifier = "SunCell"

    let mainView = MainView()
    
     var sunInfo: SunModel? {
        didSet {
            sunCellImage.image = sunInfo?.image
            sunTimeLabel.text = sunInfo?.time
            }
        }

    var moonInfo: MoonModel? {
        didSet {
            sunCellImage.image = moonInfo?.image
            sunTimeLabel.text = moonInfo?.time
            }
    }

    private let sunCellImage : UIImageView = {
        let sunImgView = UIImageView()
        sunImgView.contentMode = .scaleAspectFit
        sunImgView.clipsToBounds = true
        sunImgView.translatesAutoresizingMaskIntoConstraints = false
        return sunImgView
    }()
    
    private let sunTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "futura", size: 24)
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(sunCellImage)
        contentView.addSubview(sunTimeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sunCellImage.frame = CGRect(x: 5, y: 5, width: 100, height: contentView.frame.size.height - 10)
        sunTimeLabel.frame = CGRect(x: 150, y: 5, width: 200, height: contentView.frame.size.height - 10)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        self.selectionStyle = .gray
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected == true {
            self.layer.opacity = 1.0
        } else {
            self.layer.opacity = 0.2
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
