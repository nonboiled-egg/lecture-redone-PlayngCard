//
//  PlayingCardView.swift
//  Playng Card
//
//  Created by Manuarii Ken Tekau Dauphin on 5/28/18.
//  Copyright © 2018 Junya Murakami. All rights reserved.
//

import UIKit

@IBDesignable   //make it visible from the storyboard

class PlayingCardView: UIView {
    
    @IBInspectable  //make it editable from the view
    var rank: Int = 12 {didSet{setNeedsDisplay(); setNeedsLayout()}}
    @IBInspectable
    var suit: String = "❤️" {didSet{setNeedsDisplay(); setNeedsLayout()}}
    @IBInspectable
    var isFaceUp:Bool = true {didSet{setNeedsDisplay(); setNeedsLayout()}}

    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize {didSet{setNeedsDisplay()}}
    
    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer){
        switch recognizer.state {
        case .changed, .ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default:break            
        }
    }
    
    //attributed string
    private func centeredAttributedString(_ string: String, fontSize: CGFloat)->NSAttributedString{
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString (string: string, attributes: [NSAttributedStringKey.paragraphStyle :paragraphStyle, .font:font])
    }
    
    //string to be drawn
    private var cornerString: NSAttributedString{
        return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    //each label
    private lazy var upperLeftLabel = createCornerLabel()
    private lazy var lowerRightLabel =  createCornerLabel()
    
    //label to draw the string on
    private func createCornerLabel() -> UILabel{
        let label = UILabel()
        label.numberOfLines = 0 //uses as many line as needed
        addSubview(label)
        return label
    }
    
    //called when the slider is changed
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //conbination for redrawing
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    //configure label
    private func configureCornerLabel(_ label: UILabel){
        label.attributedText = cornerString //draw attributed string on the label
        label.frame.size = CGSize.zero      //make the frame dependant to the size(?)
        label.sizeToFit()                   //make it fit
        label.isHidden = !isFaceUp          //hide when face down
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //top right
        configureCornerLabel(upperLeftLabel)
        upperLeftLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        
        //bottom left
        configureCornerLabel(lowerRightLabel)
        lowerRightLabel.transform = CGAffineTransform.identity
            .translatedBy(x: lowerRightLabel.frame.size.width, y: lowerRightLabel.frame.size.height)
            .rotated(by: CGFloat.pi)
        lowerRightLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -lowerRightLabel.frame.size.width, dy: -lowerRightLabel.frame.size.height)
    }
    
    private func drawPips()
    {
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,2,2,2],[2,2,1,2,2],[2,2,2,2,2]]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        //redraw from attribute spector in storyboard
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()   //nothing outside of the bound
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp{
            if let faceCardImage = UIImage(named: rankString+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){ //draw image for face cards, extra arguments make pics visible from the storyboard
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            }else{
                drawPips()
            }
        }else{
            if let backCardImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
                backCardImage.draw(in: bounds)
            }
        }
    }
    

}

extension PlayingCardView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}

//GESTURE
