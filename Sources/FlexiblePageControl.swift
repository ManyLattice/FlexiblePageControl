//
//  File.swift
//  FlexiblePageControl
//
//  Created by 島仁誠 on 2017/04/06.
//  Copyright © 2017年 jinsei shima. All rights reserved.
//

import UIKit

public class FlexiblePageControl: UIControl {
    
    //MARK: - Config
    
    public struct Config {
        public var displayCount: Int
        public var dotSize: CGFloat
        public var dotSpace: CGFloat
        public var smallDotSizeRatio: CGFloat
        public var mediumDotSizeRatio: CGFloat
        
        public init(displayCount: Int = 7,
                    dotSize: CGFloat = 6.0,
                    dotSpace: CGFloat = 4.0,
                    smallDotSizeRatio: CGFloat = 0.5,
                    mediumDotSizeRatio: CGFloat = 0.7) {
            self.displayCount = displayCount
            self.dotSize = dotSize
            self.dotSpace = dotSpace
            self.smallDotSizeRatio = smallDotSizeRatio
            self.mediumDotSizeRatio = mediumDotSizeRatio
        }
    }
    
    private enum Direction {
        case left
        case right
        case stay
    }
    
    //MARK: - Variable
    
    private var config = Config()
    
    public var currentPage: Int = 0 {
        didSet {
            guard (currentPage < numberOfPages && currentPage >= 0) else { return }
            scrollView.layer.removeAllAnimations()
            updateDot(at: currentPage, animated: true)
        }
    }
    
    public var numberOfPages: Int = 0 {
        didSet {
            scrollView.isHidden = (numberOfPages <= 1 && hidesForSinglePage)
            displayCount = min(config.displayCount, numberOfPages)
            update(currentPage: currentPage, config: config)
        }
    }
    
    public var pageIndicatorTintColor: UIColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1.00) {
        didSet {
            updateDotColor(currentPage: currentPage)
        }
    }
    
    public var currentPageIndicatorTintColor: UIColor = UIColor(red: 0.32, green: 0.59, blue: 0.91, alpha: 1.00) {
        didSet {
            updateDotColor(currentPage: currentPage)
        }
    }
    
    public var animateDuration: TimeInterval = 0.3
    
    public var hidesForSinglePage: Bool = false {
        didSet {
            scrollView.isHidden = (numberOfPages <= 1 && hidesForSinglePage)
        }
    }
    
    //MARK: - Variable
    
    private var itemSize: CGFloat {
        return config.dotSize + config.dotSpace
    }
    
    private var items: [ItemView] = []
    
    private var displayCount: Int = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    //MARK: - Private constant
    
    private let scrollView = UIScrollView()
    
    //MARK: - Init
    
    public init() {
        super.init(frame: .zero)
        
        setup()
        updateViewSize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
        updateViewSize()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: itemSize * CGFloat(displayCount), height: itemSize)
    }
    
    //MARK: - Functions

    public func updateViewSize() {
        self.bounds.size = intrinsicContentSize
    }
    
    public func setConfig(_ config: Config) {
        self.config = config
        
        invalidateIntrinsicContentSize()
        
        update(currentPage: currentPage, config: config)
    }
    
    //MARK: - Private functions
    
    private func setup() {
        backgroundColor = .clear
        
        scrollView.backgroundColor = .clear
        scrollView.isUserInteractionEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        
        addSubview(scrollView)
    }
    
    private func update(currentPage: Int, config: Config) {
        let itemConfig = ItemView.ItemConfig(dotSize: config.dotSize, itemSize: itemSize, smallDotSizeRatio: config.smallDotSizeRatio, mediumDotSizeRatio: config.mediumDotSizeRatio)
        
        if currentPage < displayCount {
            
            items = (-2..<(displayCount + 2))
                .map { ItemView(config: itemConfig, index: $0) }
        }
        else {
            
            guard let firstItem = items.first else { return }
            guard let lastItem = items.last else { return }
            items = (firstItem.index...lastItem.index)
                .map { ItemView(config: itemConfig, index: $0) }
        }
        
        scrollView.contentSize = .init(width: itemSize * CGFloat(numberOfPages), height: itemSize)
        
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        items.forEach { scrollView.addSubview($0) }
        
        let size: CGSize = .init(width: itemSize * CGFloat(displayCount), height: itemSize)
        
        scrollView.bounds.size = size
        
        if displayCount < numberOfPages {
            scrollView.contentInset = .init(top: 0, left: itemSize * 2, bottom: 0, right: itemSize * 2)
        }
        else {
            scrollView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        updateDot(at: currentPage, animated: false)
    }
    
    private func updateDot(at currentPage: Int, animated: Bool) {
        updateDotColor(currentPage: currentPage)
        
        if numberOfPages > displayCount {
            updateDotPosition(currentPage: currentPage, animated: animated)
            updateDotSize(currentPage: currentPage, animated: animated)
        }
    }
    
    private func updateDotColor(currentPage: Int) {
        items.forEach {
            $0.dotColor = ($0.index == currentPage) ?
                currentPageIndicatorTintColor : pageIndicatorTintColor
        }
    }
    
    private func updateDotPosition(currentPage: Int, animated: Bool) {
        let duration = animated ? animateDuration : 0
        
        if currentPage == 0 {
            let x = -scrollView.contentInset.left
            moveScrollView(x: x, duration: duration)
        }
        else if currentPage == numberOfPages - 1 {
            let x = scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.right
            moveScrollView(x: x, duration: duration)
        }
        else if CGFloat(currentPage) * itemSize <= scrollView.contentOffset.x + itemSize {
            let x = scrollView.contentOffset.x - itemSize
            moveScrollView(x: x, duration: duration)
        }
        else if CGFloat(currentPage) * itemSize + itemSize >=
            scrollView.contentOffset.x + scrollView.bounds.width - itemSize {
            let x = scrollView.contentOffset.x + itemSize
            moveScrollView(x: x, duration: duration)
        }
    }
    
    private func updateDotSize(currentPage: Int, animated: Bool) {
        let duration = animated ? animateDuration : 0
        
        items.forEach { item in
            item.animateDuration = duration
            if item.index == currentPage {
                item.state = .Normal
            }
                // outside of left
            else if item.index < 0 {
                item.state = .None
            }
                // outside of right
            else if item.index > numberOfPages - 1 {
                item.state = .None
            }
                // first dot from left
            else if item.frame.minX <= scrollView.contentOffset.x {
                item.state = .Small
            }
                // first dot from right
            else if item.frame.maxX >= scrollView.contentOffset.x + scrollView.bounds.width {
                item.state = .Small
            }
                // second dot from left
            else if item.frame.minX <= scrollView.contentOffset.x + itemSize {
                item.state = .Medium
            }
                // second dot from right
            else if item.frame.maxX >= scrollView.contentOffset.x + scrollView.bounds.width - itemSize {
                item.state = .Medium
            }
            else {
                item.state = .Normal
            }
        }
    }
    
    private func moveScrollView(x: CGFloat, duration: TimeInterval) {
        let direction = behaviorDirection(x: x)
        reusedView(direction: direction)
        UIView.animate(withDuration: duration, animations: { [unowned self] in
            self.scrollView.contentOffset.x = x
        })
    }
    
    private func behaviorDirection(x: CGFloat) -> Direction {
        switch x {
        case let x where x > scrollView.contentOffset.x:
            return .right
        case let x where x < scrollView.contentOffset.x:
            return .left
        default:
            return .stay
        }
    }
    
    private func reusedView(direction: Direction) {
        guard let firstItem = items.first else { return }
        guard let lastItem = items.last else { return }
        
        switch direction {
        case .left:
            
            lastItem.index = firstItem.index - 1
            lastItem.frame = CGRect(x: CGFloat(lastItem.index) * itemSize, y: 0, width: itemSize, height: itemSize)
            items.insert(lastItem, at: 0)
            items.removeLast()
            
        case .right:
            
            firstItem.index = lastItem.index + 1
            firstItem.frame = CGRect(x: CGFloat(firstItem.index) * itemSize, y: 0, width: itemSize, height: itemSize)
            items.insert(firstItem, at: items.count)
            items.removeFirst()
            
        case .stay:
            
            break
        }
    }
}

//MARK: - ItemView

private class ItemView: UIView {
    
    struct ItemConfig {
        public var dotSize: CGFloat
        public var itemSize: CGFloat
        public var smallDotSizeRatio: CGFloat
        public var mediumDotSizeRatio: CGFloat
    }
    
    enum State {
        case None
        case Small
        case Medium
        case Normal
    }
    
    var index: Int
    
    var dotColor = UIColor.lightGray {
        didSet {
            dotView.backgroundColor = dotColor
        }
    }
    
    var state: State = .Normal {
        didSet {
            updateDotSize(state: state)
        }
    }
    
    var animateDuration: TimeInterval = 0.3
    
    init(config: ItemConfig, index: Int) {
        self.itemSize = config.itemSize
        self.dotSize = config.dotSize
        self.mediumSizeRatio = config.mediumDotSizeRatio
        self.smallSizeRatio = config.smallDotSizeRatio
        self.index = index
        
        let x = itemSize * CGFloat(index)
        let frame = CGRect(x: x, y: 0, width: itemSize, height: itemSize)
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        dotView.frame.size = CGSize(width: dotSize, height: dotSize)
        dotView.center = CGPoint(x: itemSize/2, y: itemSize/2)
        dotView.backgroundColor = dotColor
        dotView.layer.cornerRadius = dotSize/2
        dotView.layer.masksToBounds = true
        
        addSubview(dotView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: private
    
    private let dotView = UIView()
    
    private let itemSize: CGFloat
    
    private let dotSize: CGFloat
    
    private let mediumSizeRatio: CGFloat
    
    private let smallSizeRatio: CGFloat
    
    private func updateDotSize(state: State) {
        var _size: CGSize
        
        switch state {
        case .Normal:
            _size = CGSize(width: dotSize, height: dotSize)
        case .Medium:
            _size = CGSize(width: dotSize * mediumSizeRatio, height: dotSize * mediumSizeRatio)
        case .Small:
            _size = CGSize(
                width: dotSize * smallSizeRatio,
                height: dotSize * smallSizeRatio
            )
        case .None:
            _size = CGSize.zero
        }
        
        UIView.animate(withDuration: animateDuration, animations: { [unowned self] in
            self.dotView.layer.cornerRadius = _size.height / 2.0
            self.dotView.layer.bounds.size = _size
        })
    }
    
}

