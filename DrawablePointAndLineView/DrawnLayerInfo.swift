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
}

/// 描画済みの点情報
public struct DrawnPoint: DrawnLayerInfo {
    public var id: String
    public var pointSize: CGFloat
    public var pointColor: UIColor
    public var pointAlpha: CGFloat
    public var pointLocation: CGPoint
    public var layer: CALayer
}

/// 描画済みの線情報
public struct DrawnLine: DrawnLayerInfo {

    public var id: String
    public var lineWidth: CGFloat
    public var lineColor: UIColor
    public var lineAlpha: CGFloat
    public var lineLocation: (CGPoint, CGPoint)
    public var layer: CALayer
}

/// 描画済みの点に基づいて引かれた線情報
public struct DrawnLineBasedOnPoints: DrawnLayerInfo {
    public var id: String
    public var lineWidth: CGFloat
    public var lineColor: UIColor
    public var lineAlpha: CGFloat
    public var basedPointIds: [String]
    public var layer: CALayer
}

///
