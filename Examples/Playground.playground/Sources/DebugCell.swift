import Foundation
import SpreadsheetView

public class DebugCell: Cell {
    var label = UILabel()

    public var indexPath: IndexPath! {
        didSet {
            label.text = "R\(indexPath.row)C\(indexPath.column)"
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.systemFont(ofSize: 8)
        label.textAlignment = .center
        contentView.addSubview(label)

        let bgView = UIView()
        bgView.backgroundColor = .white
        backgroundView = bgView

        let sbgView = UIView()
        sbgView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.2)
        selectedBackgroundView = sbgView
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
