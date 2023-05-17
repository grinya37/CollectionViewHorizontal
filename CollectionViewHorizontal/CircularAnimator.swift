//
//  CircularAnimator.swift
//  CollectionViewHorizontal
//
//  Created by Николай Гринько on 17.05.2023.
//

import UIKit

final class CircularAnimator: NSObject {
    
    
    enum TransitionMode {
        case present
        case dismiss
        case none
    }
    
    private var circle: UIView!
    
    private var transitionMode: TransitionMode = .none
    private let duration: CGFloat
    private var startingPoint: CGPoint = .zero
    private let circleColor: UIColor
    private let selectedCellSnapshot: UIView?
    
    init(duration: CGFloat,
         circleColor: UIColor,
         selectedCellSnapshot: UIView? = nil
    ) {
        self.duration = duration
        self.circleColor = circleColor
        self.selectedCellSnapshot = selectedCellSnapshot
    }
    
    func setup(
        usingTransitionMode transitionMode: TransitionMode,
        andStartingPoint startingPoint: CGPoint
    ) {
        self.transitionMode = transitionMode
        self.startingPoint = startingPoint
    }
    
    private func frameForCircle(
        vithViewCenter viewCenter: CGPoint,
    viewSize:CGSize,
    startPoint: CGPoint
    ) -> CGRect {
        
        let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
        let yLength = fmax(startPoint.y, viewSize.width - startPoint.y)
        
        let offsetVector = sqrt(xLength * xLength + yLength * yLength) * 2
        let size = CGSize(width: offsetVector, height: offsetVector)
        
        return CGRect(origin: .zero, size: size)
    }
    
}


extension CircularAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerview = transitionContext.containerView
        
        switch self.transitionMode {
        case .present:
            guard let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
                transitionContext.completeTransition(false)
                return
            }
            
            let viewCenter = presentedView.center
            let viewSize = presentedView.frame.size
            let circleFrame = self.frameForCircle(vithViewCenter: viewCenter,
                                                  viewSize: viewSize,
                                                  startPoint: self.startingPoint)
            
            self.circle = UIView(frame: circleFrame)
            self.circle.layer.cornerRadius = self.circle.frame.height / 2
            self.circle.center = self.startingPoint
            self.circle.backgroundColor = self.circleColor
            
            let circleTransform: CGAffineTransform
            if let selectedCellSnapshot = self.selectedCellSnapshot {
                let scaleX = selectedCellSnapshot.frame.size.width / self.circle.frame.size.width
                let scaleY = selectedCellSnapshot.frame.size.height / self.circle.frame.size.height
                circleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            } else {
                circleTransform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }
            self.circle.transform = circleTransform
            containerview.addSubview(self.circle)
            
            let delta = CGPoint(
                x: (presentedView.frame.size.width / 2) - self.startingPoint.x,
                y: (presentedView.frame.size.height / 2) - self.startingPoint.y
            )
            
            presentedView.center = CGPoint(
                x: (circleFrame.size.width / 2) + delta.x,
                y: (circleFrame.size.height / 2) + delta.y
            )
            presentedView.alpha = 0
            
            containerview.addSubview(self.circle)
            
            UIView.animate(withDuration: self.duration) {
                
                presentedView.alpha = 1
                self.circle.transform = CGAffineTransform.identity
                
            } completion: { finished in
                transitionContext.completeTransition(finished)
            }

        case .dismiss:
            guard let dismissedView = transitionContext.view(forKey: UITransitionContextViewKey.from)
            else {
                transitionContext.completeTransition(false)
                return
            }
            
            let viewCenter = dismissedView.center
            let viewSize = dismissedView.frame.size
            
            let circleTransform: CGAffineTransform
                if let selectedCellSnapshot = self.selectedCellSnapshot {
                    let scaleX = selectedCellSnapshot.frame.size.width / self.circle.frame.size.width
                    let scaleY = selectedCellSnapshot.frame.size.height / self.circle.frame.size.height
                    circleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                } else {
                    circleTransform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                }
            self.circle.frame = self.frameForCircle(
                vithViewCenter: viewCenter,
                viewSize: viewSize,
                startPoint: self.startingPoint)
            
            
            containerview.addSubview(dismissedView)
            
            UIView.animate(withDuration: self.duration) {
                dismissedView.alpha = 0
                self.circle.transform = circleTransform
            } completion: { finished in
                dismissedView.removeFromSuperview()
                self.circle = nil
                transitionContext.completeTransition(finished)
            }
        case .none:
            transitionContext.completeTransition(false)
        }
    }
    
}
 
