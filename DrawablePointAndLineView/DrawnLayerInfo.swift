//
//  DrawnLayerInfo.swift
//  DrawablePointAndLineView
//
//  Created by Maika Yamada on 2017/06/11.
//  Copyright © 2017年 Maika Yamada. All rights reserved.
//

/// レイヤー情報用プロトコル
public protocol DrawnLayerInfo {
    var id: String { get }
    var layer: CALayer { get }
    
    mutating func editWidth(width: CGFloat)
    
    mutating func editColor(color: UIColor)
    
    mutating func editAlpha(alpha: CGFloat)
    
    mutating func replaceLayer(layer: CALayer)
}

/// 描画済みの点情報
public struct DrawnPoint: DrawnLayerInfo {
    public var id: String
    public var pointSize: CGFloat
    public var pointColor: UIColor
    public var pointAlpha: CGFloat
    public var pointLocation: CGPoint
    public var layer: CALayer
    
    mutating public func editWidth(width: CGFloat) {
        self.pointSize = width
    }
    
    mutating public func editColor(color: UIColor) {
        self.pointColor = color
    }
    
    mutating public func editAlpha(alpha: CGFloat) {
        self.pointAlpha = alpha
    }
    
    mutating func editPointLocation(location: CGPoint) {
        self.pointLocation = location
    }
    
    mutating public func replaceLayer(layer: CALayer) {
        self.layer = layer
    }
}

/// 描画済みの線情報
public struct DrawnLine: DrawnLayerInfo {

    public var id: String
    public var lineWidth: CGFloat
    public var lineColor: UIColor
    public var lineAlpha: CGFloat
    public var lineLocation: (CGPoint, CGPoint)
    public var layer: CALayer
    
    mutating public func editWidth(width: CGFloat) {
        self.lineWidth = width
    }
    
    mutating public func editColor(color: UIColor) {
        self.lineColor = color
    }
    
    mutating public func editAlpha(alpha: CGFloat) {
        self.lineAlpha = alpha
    }
    
    mutating public func replaceLayer(layer: CALayer) {
        self.layer = layer
    }
}
