import UIKit

extension CGPath {
  private enum BezierCalulation: Int, CaseIterable {
    case upperLeft, right, lowerLeft
  }

  static func createTriangleWithVertices(upperLeftCorner: CGPoint,
                                         rightCorner: CGPoint,
                                         lowerLeftCorner: CGPoint,
                                         cornerRadius radius: CGFloat) -> (path: CGPath, firstBezierEndPointXSpacing: CGFloat) {
    let path = CGMutablePath()
    let points = [lowerLeftCorner, upperLeftCorner, rightCorner]
    var firstBezierEndPointXSpacing: CGFloat = 0

    for bezierCalculation in BezierCalulation.allCases {
      let i = bezierCalculation.rawValue
      let firstIndex = i
      let secondIndex = mod(i + 1, points.count)
      let thirdIndex = mod(i + 2, points.count)

      let from = points[firstIndex]
      let via = points[secondIndex]
      let to = points[thirdIndex]

      let fromAngle = atan2f(Float(via.y - from.y), Float(via.x - from.x))
      let toAngle = atan2f(Float(to.y - via.y), Float(to.x - via.x))
      let fromOffset = CGVector(dx: CGFloat(-sinf(fromAngle)) * radius, dy: CGFloat(cosf(fromAngle)) * radius)
      let toOffset = CGVector(dx: CGFloat(-sinf(toAngle)) * radius, dy: CGFloat(cosf(toAngle)) * radius)

      let x1 = from.x + fromOffset.dx
      let y1 = from.y + fromOffset.dy
      let x2 = via.x + fromOffset.dx
      let y2 = via.y + fromOffset.dy
      let x3 = via.x + toOffset.dx
      let y3 = via.y + toOffset.dy
      let x4 = to.x + toOffset.dx
      let y4 = to.y + toOffset.dy

      let intersectionX = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
      let intersectionY = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))

      let arcCenter = CGPoint(x: floor(intersectionX), y: floor(intersectionY))
      let startAngle = fromAngle - (.pi / 2.0)

      let createCubicBezierFromArc: (_ angle: CGFloat, _ rotationOffset: CGFloat) -> (start: CGPoint, end: CGPoint, c1: CGPoint, c2: CGPoint) = { angle, rotationOffset in
        assert(angle <= .pi / 2.0, "Only for arcs until 90°. Divide input into smaller arcs.")

        let start = CGPoint(x: radius, y: 0)
        let k: CGFloat = 4.0 / 3.0 * tan(angle / 4.0)
        let c1 = CGPoint(x: radius, y: k * radius)
        let c2 = CGPoint(x: radius * (cos(angle) + k * sin(angle)), y: radius * (sin(angle) - k * cos(angle)))
        let end = CGPoint(x: radius * cos(angle), y: radius * sin(angle))
        let rotationAngle = CGFloat(startAngle) + rotationOffset

        let rotatedStart = CGPoint(
          x: cos(rotationAngle) * (start.x) - sin(rotationAngle) * (start.y) + arcCenter.x,
          y: sin(rotationAngle) * (start.x) + cos(rotationAngle) * (start.y) + arcCenter.y
        )
        let rotatedC1 = CGPoint(
          x: cos(rotationAngle) * (c1.x) - sin(rotationAngle) * (c1.y) + arcCenter.x,
          y: sin(rotationAngle) * (c1.x) + cos(rotationAngle) * (c1.y) + arcCenter.y
        )
        let rotatedC2 = CGPoint(
          x: cos(rotationAngle) * (c2.x) - sin(rotationAngle) * (c2.y) + arcCenter.x,
          y: sin(rotationAngle) * (c2.x) + cos(rotationAngle) * (c2.y) + arcCenter.y
        )
        let rotatedEnd = CGPoint(
          x: cos(rotationAngle) * (end.x) - sin(rotationAngle) * (end.y) + arcCenter.x,
          y: sin(rotationAngle) * (end.x) + cos(rotationAngle) * (end.y) + arcCenter.y
        )

        return (start: rotatedStart, end: rotatedEnd, c1: rotatedC1, c2: rotatedC2)
      }

      let arcAngle1: CGFloat
      let arcAngle2: CGFloat

      switch bezierCalculation {
      case .upperLeft:
        arcAngle1 = CGFloat(.pi / 2.0)
        arcAngle2 = CGFloat(abs(toAngle - fromAngle)) - arcAngle1

      case .right:
        arcAngle1 = CGFloat(abs(toAngle - fromAngle)) / 2.0
        arcAngle2 = arcAngle1

      case .lowerLeft:
        arcAngle1 = CGFloat(abs(3.0 / 2.0 * .pi - fromAngle)) - CGFloat(.pi / 2.0)
        arcAngle2 = CGFloat(.pi / 2.0)
      }

      let firstBezier = createCubicBezierFromArc(arcAngle1, 0)
      let secondBezier = createCubicBezierFromArc(arcAngle2, arcAngle1)

      switch bezierCalculation {
      case .upperLeft:
        path.move(to: firstBezier.start)
        path.addCurve(to: firstBezier.end, control1: firstBezier.c1, control2: firstBezier.c2)
        path.addCurve(to: secondBezier.end, control1: secondBezier.c1, control2: secondBezier.c2)

      case .right:
        path.addLine(to: firstBezier.start)
        path.addCurve(to: firstBezier.end, control1: firstBezier.c1, control2: firstBezier.c2)
        path.addLine(to: secondBezier.start)
        path.addCurve(to: secondBezier.end, control1: secondBezier.c1, control2: secondBezier.c2)

      case .lowerLeft:
        path.addLine(to: firstBezier.start)
        path.addCurve(to: firstBezier.end, control1: firstBezier.c1, control2: firstBezier.c2)
        path.addCurve(to: secondBezier.end, control1: secondBezier.c1, control2: secondBezier.c2)
      }

      if i == 0 {
        firstBezierEndPointXSpacing = secondBezier.end.x - secondBezier.start.x
      }
    }

    path.closeSubpath()
    return (path, firstBezierEndPointXSpacing)
  }

  func printDebugDescription() {
    var segmentCount = 1

    apply(info: &segmentCount) { (info, elementProvider) in
      let segmentCount = info?.bindMemory(to: Int.self, capacity: 0).pointee ?? 0
      defer { info?.bindMemory(to: Int.self, capacity: 0).pointee = segmentCount + 1 }

      let element = elementProvider.pointee
      let command: String
      let pointCount: Int

      switch element.type {
      case .moveToPoint: command = "moveTo"; pointCount = 1
      case .addLineToPoint: command = "lineTo"; pointCount = 1
      case .addQuadCurveToPoint: command = "quadCurveTo"; pointCount = 2
      case .addCurveToPoint: command = "curveTo"; pointCount = 3
      case .closeSubpath: command = "close"; pointCount = 0
      @unknown default: command = "unknown"; pointCount = 0
      }
      let points = Array(UnsafeBufferPointer(start: element.points, count: pointCount))

      switch pointCount {
      case 0:
        print("\(segmentCount). \(command)")
      case 1:
        print("\(segmentCount). \(command) \(points[0])")
      case 2:
        print("\(segmentCount). \(command) \(points[2]), control point \(points[0])")
      case 3:
        print("\(segmentCount). \(command) \(points[2]), control points \(points.prefix(2))")
      default:
        break
      }
    }
  }
}

func mod(_ a: Int, _ n: Int) -> Int {
  precondition(n > 0, "modulus must be positive")
  let r = a % n
  return r >= 0 ? r : r + n
}

func deg2rad(_ number: Double) -> CGFloat {
  CGFloat(number * .pi / 180)
}

func rad2deg(_ number: Double) -> Double {
  number * 180 / .pi
}
