import UIKit
import QuartzCore

class ViewController: UIViewController {
    
    var markers: [UILabel] = [];
    var chart: UIView = UIView();
    var selector: UISegmentedControl = UISegmentedControl(items: ["LineDash", "Fill"])
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    /*
    override init() {
        super.init()
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = self.dynamicType.color(5)
        
        self.createSliders()
        self.createSelector()
        self.createChart()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 円の割合を変更するスライダーを作成する
    func createSliders() {
        
        for i in 0..<4 {
            var slider: UIView = self.createSlider(self.dynamicType.color(i));
            slider.center = CGPointMake(160, (CGFloat)(50 * (i + 1)))
            slider.tag = i;
        }
    }
    
    func createSlider(color: UIColor) -> UIView {
        
        let slider: UIView = UIView(frame: CGRectMake(0, 0, 280, 40))
        slider.backgroundColor = UIColor.clearColor()
        self.view.addSubview(slider)
        
        let bar: UIView = UIView(frame: CGRectMake(0, 15, 280, 10))
        bar.backgroundColor = UIColor.lightGrayColor()
        slider.addSubview(bar)
        
        let marker: UILabel = UILabel(frame: CGRectMake(120, 0, 40, 40))
        marker.backgroundColor = color
        marker.text = "50"
        marker.font = UIFont(name: "Futura-CondensedExtraBold", size: 20)
        marker.textAlignment = NSTextAlignment.Center
        marker.textColor = self.dynamicType.color(4)
        marker.userInteractionEnabled = true
        
        slider.addSubview(marker)
        
        let pan: UIPanGestureRecognizer =
        UIPanGestureRecognizer(target: self, action: Selector("slide:"))
        marker.addGestureRecognizer(pan)
        
        self.markers.append(marker)
        
        return slider
    }
    
    // スライダーのイベントを受け取る
    func slide(panGr :UIPanGestureRecognizer) {
        
        // ラベルの数値変更
        var p: CGPoint = panGr.locationInView(panGr.view?.superview)
        let marker: UILabel = panGr.view! as! UILabel
        
        if (p.x < 20) {
            p.x = 20
        } else if (260 < p.x) {
            p.x = 260
        }
        
        marker.center = CGPointMake(p.x, marker.center.y)
        
        let labelNum: Int32 = 100 * (Int32(p.x) - 20) / 240
        marker.text = "\(labelNum)"
        
        // チャートの再作成
        self.chart.removeFromSuperview()
        self.createChart()
    }
    
    // 円チャートの作成
    func createChart() {
        
        let chartSize: CGFloat = 200.0
        self.chart = UIView(frame: CGRectMake(60, 250, chartSize, chartSize))
        //        self.chart.backgroundColor = UIColor.blackColor()
        self.chart.backgroundColor = UIColor.clearColor()
        //        chart.layer.cornerRadius = 100
        self.view.addSubview(self.chart)
        
        var red: CGFloat    = CGFloat(Int(self.markers[0].text!)!)
        var blue: CGFloat   = CGFloat(Int(self.markers[1].text!)!)
        var green: CGFloat  = CGFloat(Int(self.markers[2].text!)!)
        var orange: CGFloat = CGFloat(Int(self.markers[3].text!)!)
        var total = red + blue + green + orange
        
        if (total != 0) {
            
            // 円のどれだけに表示するか計算
            red     = red / total * 2 * CGFloat(M_PI);
            blue    = blue / total * 2 * CGFloat(M_PI);
            green   = green / total * 2 * CGFloat(M_PI);
            orange  = orange / total * 2 * CGFloat(M_PI);
        } else {
            
            red     = CGFloat(M_PI) / 2.0;
            blue    = CGFloat(M_PI) / 2.0;
            green   = CGFloat(M_PI) / 2.0;
            orange  = CGFloat(M_PI) / 2.0;
        }
        
        let ratios: [CGFloat] = [red, blue, green, orange]
        let chartCenter: CGFloat = chartSize / 2.0
        
        // チャート作成関数の切り替え
        var chartFunc: (chartCenter: CGFloat, i: Int, start: CGFloat, end: CGFloat) -> ()
        if(self.selector.selectedSegmentIndex == 0) {
            
            chartFunc = self.strokeChart
        } else {
            
            chartFunc = self.fillChart
        }
        
        var start: CGFloat = 0.0
        for i in 0..<4 {
            
            var end: CGFloat = start + ratios[i]
            chartFunc(chartCenter: chartCenter, i: i, start: start, end: end)
            start = end
        }
    }
    
    // 塗りつぶしでグラフを描画します
    func fillChart(chartCenter: CGFloat, i: Int, start: CGFloat, end: CGFloat) {
        
        var path: UIBezierPath = UIBezierPath();
        
        path.moveToPoint(CGPointMake(chartCenter, chartCenter))
        path.addArcWithCenter(CGPointMake(chartCenter, chartCenter),
            radius: 100,
            startAngle: start - CGFloat(M_PI) / 2.0,
            endAngle: end - CGFloat(M_PI) / 2.0,
            clockwise: true)
        
        //=====
        var sl: CAShapeLayer = CAShapeLayer()
        sl.fillColor = self.dynamicType.color(i).CGColor
        sl.path = path.CGPath
        //=====
        
        self.chart.layer.addSublayer(sl)
        
        var mask: UIView = UIView(frame: CGRectMake(0, 0, 140, 140))
        mask.layer.cornerRadius = 70
        mask.center = CGPointMake(chartCenter, chartCenter)
        mask.backgroundColor = self.dynamicType.color(5)
        chart.addSubview(mask)
    }
    
    // 点線でグラフを描画します。
    func strokeChart(chartCenter: CGFloat, i: Int, start: CGFloat, end: CGFloat) {
        
        var path: UIBezierPath = UIBezierPath();
        
        path.addArcWithCenter(CGPointMake(chartCenter, chartCenter),
            radius: 100,
            startAngle: start - CGFloat(M_PI) / 2.0,
            endAngle: end - CGFloat(M_PI) / 2.0,
            clockwise: true)
        
        //=====
        var sl: CAShapeLayer = CAShapeLayer()
        sl.fillColor = UIColor.clearColor().CGColor
        sl.strokeColor = self.dynamicType.color(i).CGColor
        sl.lineWidth = 30
        
        // 点線をセット
        var dashPattern:[CGFloat] = [1, 4]
        sl.lineDashPattern = dashPattern
        sl.path = path.CGPath
        //=====
        
        self.chart.layer.addSublayer(sl)
        
    }
    
    //　セグメンテッドコントロールを作成
    func createSelector() {
        
        self.selector.frame = CGRectMake(60, 500, 200, 44)
        self.selector.selectedSegmentIndex = 0
        self.selector.addTarget(self, action: "selected:", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(self.selector)
        
    }
    
    func selected(sender: UISegmentedControl) {
        // チャートの再作成
        self.chart.removeFromSuperview()
        self.createChart()
    }
    
    class func color(num: Int) -> UIColor {
        
        switch num {
            
        case 0: return ViewController.uiColorHex(0xF24495)
        case 1: return ViewController.uiColorHex(0x04BFBF)
        case 2: return ViewController.uiColorHex(0xB2F252)
        case 3: return ViewController.uiColorHex(0xF2CB05)
        case 4: return ViewController.uiColorHex(0xE9F2DF)
        case 5: return UIColor(white: 0.8, alpha: 1.0)
            
        default:
            break
        }
        
        return UIColor.blackColor()
    }
    
    class func uiColorHex(rgbValue: UInt32) -> UIColor {
        
        //        println("------------")
        //        println("rgbValue :\(rgbValue)")
        //        println("red      :\((CGFloat)((rgbValue & 0xFF0000) >> 16) / 255)")
        //        println("green    :\((CGFloat)((rgbValue & 0x00FF00) >> 8) / 255)")
        //        println("blue     :\((CGFloat)(rgbValue & 0x0000FF) / 255)")
        //
        //        let red: CGFloat    = ((CGFloat)((rgbValue & 0xFF0000) >> 16) / 255)
        //        let green: CGFloat  = ((CGFloat)((rgbValue & 0x00FF00) >> 8) / 255)
        //        let blue: CGFloat   = ((CGFloat)(rgbValue & 0x0000FF) / 255)
        //        return UIColor(red: red, green: green,blue: blue, alpha: 1.0)
        
        return UIColor(red: CGFloat(((rgbValue & 0xFF0000) >> 16)) / 255.0,
            green: CGFloat(((rgbValue & 0x00FF00) >> 8)) / 255.0,
            blue: CGFloat((rgbValue & 0x0000FF)) / 255.0,
            alpha: 1.0)
    }
}
