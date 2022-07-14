//
//  ViewController.swift
//  DemoPlot2
//
//  Created by aravinthan t on 07/06/22.
//
//"http://52.8.144.110:7300/voni_iot/ecg_data_list_by_id/1"
import UIKit
import Alamofire
import ObjectMapper
import CorePlot

class ViewController: UIViewController {
    
    
   
    var eventvariable = 0
    var obj : DataModel?
    var correctdata = [Double]()
  //  var xarray = [String]()
    var xarray: String = ""

    
    @IBOutlet weak var heightCN: NSLayoutConstraint!
   
    
    var plotData = [Double](repeating: 0.0, count: 1000)
    var point = 0.0
    var plot: CPTScatterPlot!
    
    var  widthSize:CGFloat = 0.0
    var  heightSize:CGFloat = 0.0
    
    
    var maxDataPoints = 100
    var frameRate = 5.0
    var alphaValue = 0.25
    var timer : Timer?
    var timer2: Timer?
    var currentIndex: Int!
    var timeDuration:Double = 0.00000001
    
    @IBOutlet var bpmText: UILabel!
    
    @IBOutlet var hostView: CPTGraphHostingView!
    
    @IBOutlet var dataButton: UIView!
    @IBOutlet var xValue: UILabel!
    @IBOutlet var yValue: UILabel!
    
    @IBOutlet weak var stopButton: UIButton!
    
    // let width = self.hostView.frame.(forAlignmentRect: .width)
     private let sizeWidth : CGFloat = 393
      private let sizeHeight : CGFloat  = 435
    
    func getdata() {
        AF.request("http://52.8.144.110:7300/voni_iot/ecg_data_list_by_id/1").responseJSON { response in
            switch response.result {
                
            case .success(let value):
                if  let value = value as? [String:Any] {
                    self.obj = Mapper<DataModel>().map(JSON: value)
    
                    self.xarray.append(contentsOf: self.obj!.data)
                    
                    self.correctedValue()
                    
                }
                
            case .failure(let error):
                    print(error)

            }
            
        }
    }
    func correctedValue() {
//        for i in  0...xarray.count-1{
//            let str1 = xarray[i]
            let str2 = xarray.replacingOccurrences(of: "[",with: "")
            let str3 = str2.replacingOccurrences(of: "]",with: "")
            //print(str3)
            var str4 = get_number(stringtext: str3)
           // let str5 = str4.remove(at: str4.count-1)
            
            correctdata.append(contentsOf: str4)
            
   // }
        print(correctdata.count)
        print(correctdata)
    }
    
    func get_number(stringtext:String) -> [Double]
       {
           let StringRecorded = stringtext.components(separatedBy: ", ")
           return StringRecorded.map { Double($0) ?? 0.0}
          
       }
    
    
    @IBOutlet weak var heightCon: NSLayoutConstraint!
    @IBOutlet weak var widthCon: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getdata()
        
        widthSize = hostView.frame.width
        heightSize = hostView.frame.height
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        dataButton.addGestureRecognizer(tap)
        
        //addGestureTap()
        //addGesturePinch()
        //   self.plot.doubleTapToZoomEnabled = false
        //        self.hostView?.pinchZoomEnabled = false
        //        hostView.dragEnabled = false
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        addGesturePinch()
        
        initPlot()
        
        
    }
    
    @objc func doubleTap(gesture: UITapGestureRecognizer)
    {
        print("double tap called")
        print(widthSize)
        
        if hostView.frame.width == widthSize
        {
            heightCon.constant = 501
            widthCon.constant = 398+150
        
            hostView.frame = CGRect(x: 0, y: 0, width: widthSize + 150, height: heightSize + 50)
        }else
        {
            heightCon.constant = 451
            widthCon.constant = 398
            
            hostView.frame = CGRect(x: 0, y: 0, width: widthSize, height: heightSize)
        }
        
        hostView.center = view.center
        
    }
    
    
    
    @objc func addGesturePinch()
    {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        hostView.addGestureRecognizer(pinchGesture)
    }
   
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer)
    {
        if gesture.state == .changed
        {
            let scale = gesture.scale
            //let frame = hostView.frame
            heightCon.constant = heightSize * scale
            widthCon.constant = widthSize * scale
            hostView.frame = CGRect(x: 0, y: 0, width: widthSize * scale, height: heightSize * scale)
            hostView.center = view.center
        }
    }
    
    
    
    //    @objc func addGestureTap()
    //    {
    //        let TapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
    //        hostView.addGestureRecognizer(TapGesture)
    //    }
    //
    //    @objc func didTap(_ gesture: UITapGestureRecognizer){
    //        if gesture.state == .changed {
    //            //let scale = gesture.scale
    //            //let frame = hostView.frame
    //
    //            hostView.frame = CGRect(x: 0, y: 0, width: 500, height: heightSize * 565)
    //            hostView.center = view.center
    //        }
    //    }
    //
    //
    
    func initPlot()
    {
        configureGraphtView()
        configureGraphAxis()
        configurePlot()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil)
    {
        eventvariable  = 0
        if eventvariable  == 0
        {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: self.timeDuration, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        }
        else
        {
            
        }
        
        
    }
    
    @objc func fireTimer()
    {
        if eventvariable == 0
        {
            let graph = self.hostView.hostedGraph
            
            let plot = graph?.plot(withIdentifier: "mindful-graph" as NSCopying)
            if((plot) != nil)
            {
                if(self.plotData.count >= maxDataPoints)
                {
                    self.plotData.removeFirst()
                    
                    plot?.deleteData(inIndexRange:NSRange(location: 0, length: 1))
                }
            }
            guard let plotSpace = graph?.defaultPlotSpace as? CPTXYPlotSpace else { return }
            
            let location: NSInteger
            if self.currentIndex >= maxDataPoints
           
            {
                location = self.currentIndex - maxDataPoints + 2
            }
            else
            {
                location = 0
            }
            
            let range: NSInteger
            
            if location > 0 {
                range = location-1
            } else {
                range = 0
            }
            
            let oldRange =  CPTPlotRange(locationDecimal: CPTDecimalFromDouble(Double(range)), lengthDecimal: CPTDecimalFromDouble(Double(maxDataPoints-2)))

            let newRange =  CPTPlotRange(locationDecimal: CPTDecimalFromDouble(Double(location)), lengthDecimal: CPTDecimalFromDouble(Double(maxDataPoints-2)))

            CPTAnimation.animate(plotSpace, property: "xRange", from: oldRange, to: newRange, duration:0.000001)

            
            self.currentIndex += 1;
            
            if correctdata.indices.contains(currentIndex) {
                 point = correctdata[currentIndex]
            }
            else {
                eventvariable = 1
            }
                self.plotData.append(point)
            
                xValue.text = #"X: \#(String(format:"%.2f",Double(self.plotData.last!)))"#
                yValue.text = #"Y: \#(UInt(self.currentIndex!)) Sec"#
                
                plot?.insertData(at: UInt(self.plotData.count-1), numberOfRecords: 1)
            
        }
    }
    
    func configureGraphtView()
    {
        hostView.allowPinchScaling = true

        self.plotData.removeAll()
        self.currentIndex = 0
    }
    
    func configureGraphAxis()
    {
        
        let graph = CPTXYGraph(frame: hostView.bounds)
        
        graph.plotAreaFrame?.masksToBorder = false
        hostView.hostedGraph = graph
        graph.backgroundColor = UIColor.black.cgColor
        graph.paddingBottom = 40.0
        graph.paddingLeft = 40.0
        graph.paddingTop = 30.0
        graph.paddingRight = 15.0
        
        
        //Set title for graph
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.white()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 20.0
        titleStyle.textAlignment = .center
        graph.titleTextStyle = titleStyle
        
        let title = "ECG CorePlot"
        graph.title = title
        graph.titlePlotAreaFrameAnchor = .top
        graph.titleDisplacement = CGPoint(x: 0.0, y: 0.0)
        
        let axisSet = graph.axisSet as! CPTXYAxisSet
        
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.white()
        axisTextStyle.fontName = "HelveticaNeue-Bold"
        axisTextStyle.fontSize = 10.0
        axisTextStyle.textAlignment = .center
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor.white()
        lineStyle.lineWidth = 5
        let gridLineStyle = CPTMutableLineStyle()
        gridLineStyle.lineColor = CPTColor.gray()
        gridLineStyle.lineWidth = 0.5
        
        
        if let x = axisSet.xAxis
        {
            x.majorIntervalLength   = 100
            x.minorTicksPerInterval = 20
            x.labelTextStyle = axisTextStyle
            x.minorGridLineStyle = gridLineStyle
            x.axisLineStyle = lineStyle
            x.axisConstraints = CPTConstraints(lowerOffset: 0.0)
            x.delegate = self
        }
        
        if let y = axisSet.yAxis
        {
            y.majorIntervalLength   = 150
            y.minorTicksPerInterval = 10
            y.minorGridLineStyle = gridLineStyle
            y.labelTextStyle = axisTextStyle
            y.alternatingBandFills = [CPTFill(color: CPTColor.init(componentRed: 255, green: 255, blue: 255, alpha: 0.03)),CPTFill(color: CPTColor.black())]
            y.axisLineStyle = lineStyle
            y.axisConstraints = CPTConstraints(lowerOffset: 0.0)
            y.delegate = self
        }
        
        // Set plot space
        let xMin = 40.0
        let xMax = 100.0
        let yMin = 500.0
        let yMax = 2000.0
        
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
        
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
        
    }
    
    func configurePlot()
    {
        plot = CPTScatterPlot()
        
        let plotLineStile = CPTMutableLineStyle()
        plotLineStile.lineJoin = .round
        plotLineStile.lineCap = .round
        plotLineStile.lineWidth = 2
        plotLineStile.lineColor = CPTColor.green()
        plot.dataLineStyle = plotLineStile
        plot.curvedInterpolationOption = .catmullCustomAlpha
        plot.interpolation = .curved
        plot.identifier = "mindful-graph" as NSCoding & NSCopying & NSObjectProtocol
       
        guard let graph = hostView.hostedGraph else { return }
        plot.dataSource = (self as CPTPlotDataSource)
        plot.delegate = (self as CALayerDelegate)
        graph.add(plot, to: graph.defaultPlotSpace)
    }
    
    
    @IBAction func stopEvent(_ sender: Any) {
        self.eventvariable = 1
        
    }
    
}

extension ViewController: CPTScatterPlotDataSource, CPTScatterPlotDelegate
{
    func numberOfRecords(for plot: CPTPlot) -> UInt
    {
        return UInt(self.plotData.count)
    }
    
    func scatterPlot(_ plot: CPTScatterPlot, plotSymbolWasSelectedAtRecord idx: UInt, with event: UIEvent)
    {
    }
    
    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
        
        switch CPTScatterPlotField(rawValue: Int(field))!
        {
            
        case .X:
            return NSNumber(value: Int(record) + self.currentIndex-self.plotData.count)
            
        case .Y:
            return self.plotData[Int(record)] as NSNumber
            
        default:
            return 0
            
        }
        
    }
}

