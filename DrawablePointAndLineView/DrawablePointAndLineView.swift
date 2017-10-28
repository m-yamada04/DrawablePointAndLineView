//
//  DrawablePointAndLineView.swift
//  DrawablePointAndLineView
//
//  Created by Maika Yamada on 2017/06/11.
//  Copyright © 2017年 Maika Yamada. All rights reserved.
//

import UIKit

open class DrawablePointAndLineView: UIView {
    
    /// 点描画モード(true: 点を描画する / false: 点の描画はしない)
    open var drawPointMode = true
    
    /// 線描画モード(true: 線を描画する / false: 線の描画はしない)
    open var drawLineMode = true
    
    /// 点のサイズ
    open var pointSize: CGFloat = 5.0
    
    /// 点の色
    open var pointColor: UIColor = UIColor.red
    
    /// 点の透明度
    open var pointAlpha: CGFloat = 1.0
    
    /// 線の幅
    open var lineWidth: CGFloat = 3.0
    
    /// 線の色
    open var lineColor: UIColor = UIColor.red
    
    /// 線の透明度
    open var lineAlpha: CGFloat = 1.0
    
    /// 描画済みの点・線一覧
    fileprivate var drawnList = [DrawnLayerInfo]()
    
    /// delegate
    fileprivate var delegate: DrawablePointAndLineViewDelegate?
    
    /// タップ開始位置
    fileprivate var tapBeganPoint: CGPoint?
    
    /// シングルタップイベントの遅延発動用タイマー
    fileprivate var singleTapEventTimer: Timer?
    
    /// 描画中の線レイヤー
    fileprivate var drawingLine: CALayer?
    
    /// 移動中のレイヤー
    open var movingLayer: DrawnLayerInfo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func draw(_ rect: CGRect) {
        UIColor.clear.setFill()
        UIRectFill(rect)
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        self.tapBeganPoint = touch.location(in: self)
        
        // 2回目のタップイベントを検知時、シングルタップのイベントはキャンセル
        if touch.tapCount == 2 {
            self.singleTapEventTimer?.invalidate()
        }
        
    }
    
// MARK: override touches
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let previewPoint = self.tapBeganPoint!
        let point = touches.first!.location(in: self)
        
        if self.drawLineMode {
            // タップ開始位置から2point以上移動している場合のみ、描画を実行
            if !(previewPoint.x - 1..<previewPoint.x + 1 ~= point.x && previewPoint.y - 1..<previewPoint.y + 1 ~= point.y) {
                self.drawLine(began: previewPoint, end: point, save: false)
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        // 線の描画中だった場合、シングルタップイベントは発動させず描画していた線レイヤーのみ位置を確定して終了
        if let drawingLine = self.drawingLine {
            self.saveLine(end: touch.location(in: self), line: drawingLine)
            self.tapBeganPoint = nil
            self.drawingLine = nil
            return
        }
        if touch.tapCount == 1 && self.drawPointMode {
            // シングルタップイベントは若干遅延して発動させる
            self.singleTapEventTimer = Timer.scheduledTimer(
                timeInterval: 0.2, target: self, selector: #selector(DrawablePointAndLineView.singleTap(_:)), userInfo: touch, repeats: false)
            
        } else if touch.tapCount == 2 {
            // tapCountが0の場合はlongTap動作後なので、ダブルタップイベントはタップ2回検知時に限定する
            self.doubleTap(touch)
        } else if touch.tapCount == 0 && self.movingLayer != nil {
            // ロングタップでレイヤーの移動をしていた場合、移動先の座標を保存する
            if self.movingLayer is DrawnPoint {
                // 新しい位置の情報を保存し、前の位置の情報を削除
                let editPoint = self.movingLayer! as! DrawnPoint
                
                self.drawnList.append(DrawnPoint(
                    id: NSUUID().uuidString,
                    pointSize: editPoint.pointSize, pointColor: editPoint.pointColor, pointAlpha: editPoint.pointAlpha,
                    pointLocation: touch.location(in: self), layer: editPoint.layer
                    )
                )
                self.deleteDrawnAt(id: self.movingLayer!.id, deleteLayer: false)
                self.movingLayer = nil
            }
        }
    }
    
// MARK: open
    
    open func doubleTap(_ touch: UITouch) {
    }
    
    @objc open func singleTap(_ timer: Timer!) {
        let touch = timer.userInfo as! UITouch
        let location = touch.location(in: self)
        
        self.drawPoint(location: location)
    }
    
    open func drawPoint(location: CGPoint) {
        let layer = CAShapeLayer()
        layer.fillColor = self.pointColor.cgColor
        layer.frame = CGRect(x: location.x, y: location.y, width: self.pointSize, height: self.pointSize)
        layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.pointSize, height: self.pointSize), cornerRadius: 20).cgPath
        self.layer.addSublayer(layer)
        
        let drawPoint = DrawnPoint(
            id: NSUUID().uuidString,
            pointSize: self.pointSize, pointColor: self.pointColor, pointAlpha: self.pointAlpha,
            pointLocation: location, layer: layer
        )
        self.drawnList.append(drawPoint)
        delegate?.layerDidDrawn(layerInfo: drawPoint)
    }
    
    open func drawLine(began: CGPoint, end: CGPoint, save: Bool) {
        // 線を描画中の場合は、描画開始前に初期化
        if let drawingLine = self.drawingLine {
            drawingLine.removeFromSuperlayer()
            self.drawingLine = nil
        }
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = self.lineColor.cgColor
        let line = UIBezierPath()
        line.move(to: began)
        line.addLine(to: end)
        line.close()
        line.lineWidth = self.lineWidth
        layer.path = line.cgPath
        self.layer.addSublayer(layer)
        self.drawingLine = layer
        
        if save {
            self.saveLine(end: end, line: layer)
        }
    }
    
    open func getDrawnAt(index: Int) -> DrawnLayerInfo? {
        if !self.drawnList.isEmpty && self.drawnList.count > index {
            return self.drawnList[index]
        } else {
            return nil
        }
    }
    
    open func searchNearPoint(location: CGPoint, allowDiff: CGFloat = 10) -> DrawnLayerInfo? {
        if !self.drawnList.isEmpty {
            let points: [DrawnPoint] = self.drawnList.filter({$0 is DrawnPoint}) as! [DrawnPoint]
            if !points.isEmpty {
                var near: DrawnPoint?
                
                for point in points {
                    let targetDiff = abs(point.pointLocation.x - location.x) + abs(point.pointLocation.y - location.y)
                    if targetDiff > allowDiff {
                        continue
                    } else if let nearPoint = near {
                        let nearDiff = abs(nearPoint.pointLocation.x - location.x) + abs(nearPoint.pointLocation.y - location.y)
                        if nearDiff > targetDiff {
                            near = point
                        }
                    } else {
                        near = point
                    }
                }
                if near != nil {
                    return near!
                }
            }
        }
        return nil
    }
    
    open func searchMovePoint(location: CGPoint, allowDiff: CGFloat = 10) -> DrawnPoint? {
        if let moving = self.movingLayer as? DrawnPoint {
            return moving
        } else if let nearPoint = self.searchNearPoint(location: location, allowDiff: allowDiff) as? DrawnPoint {
            return nearPoint
        } else {
            return nil
        }
    }

    // TODO
//    open func searchNearLine() -> DrawnLine? {
//        if !self.drawnList.isEmpty {
//            let lines = self.drawnList.filter({$0 is DrawnLine})
//            if !lines.isEmpty {
//
//                //for line in lines {
//                //}
//            }
//        }
//        return nil
//    }
    
    open func movePoint(targetPoint: DrawnPoint, moving: CGPoint) {
        self.movingLayer = targetPoint
        let oldPosition = targetPoint.pointLocation
        
        // 新しい位置へ更新
        targetPoint.layer.position = moving
        
        let boundsAnimation = CABasicAnimation(keyPath: "position")
        boundsAnimation.fromValue = oldPosition
        boundsAnimation.toValue = moving
        boundsAnimation.duration = 10
    }
    
    // TODO
//    open func moveLine(targetLine: DrawnLine, moving: CGPoint) {
//    }
    
    open func deletePreviewDrawn() {
        if !self.drawnList.isEmpty {
            let deleteLayer = self.drawnList.last?.layer
            deleteLayer?.removeFromSuperlayer()
            self.drawnList.remove(at: self.drawnList.count - 1)
        }
    }
    
    open func deleteDrawnAt(id: String, deleteLayer: Bool = true) {
        if !self.drawnList.isEmpty {
            // 指定されたIDが存在した場合、削除
            var deleteIndex: Int?
            for (index, drawn) in self.drawnList.enumerated() {
                if drawn.id == id {
                    if deleteLayer {
                        let deleteLayer = drawn.layer
                        deleteLayer.removeFromSuperlayer()
                    }
                    deleteIndex = index
                    break
                }
            }
            if let deletad = deleteIndex {
                self.drawnList.remove(at: deletad)
            }
        }
    }

    
// MARK: fileprivate
    
    fileprivate func saveLine(began: CGPoint? = nil, end: CGPoint, line: CALayer) {
        let drawLine = DrawnLine(
            id: NSUUID().uuidString,
            lineWidth: self.lineWidth,
            lineColor: self.lineColor,
            lineAlpha: self.lineAlpha,
            lineLocation: (began ?? self.tapBeganPoint!, end),
            layer: line
        )
        self.drawnList.append(drawLine)
        delegate?.layerDidDrawn(layerInfo: drawLine)
    }
}

// MARK: DrawablePointAndLineViewDelegate

public protocol DrawablePointAndLineViewDelegate: NSObjectProtocol {
    
    func layerDidDrawn(layerInfo: DrawnLayerInfo)
}
