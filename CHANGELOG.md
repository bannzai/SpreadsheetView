## Master

##### Breaking

* None.  

##### Enhancements

* None.  

##### Bug Fixes

* None.  

## 0.7.0 Release notes (2017-05-29)

##### Breaking

* None.  

##### Enhancements

* Make `contentOffset` and `scrollIndicatorInsets` public.  
  [#55](https://github.com/kishikawakatsumi/SpreadsheetView/pull/55)

##### Bug Fixes

* Fixed an issue that behavior when adding subviews to spreadsheet view directly is not intuitive.  
  https://github.com/kishikawakatsumi/SpreadsheetView/pull/57

* Reset talbe view frame when reloading.  
  https://github.com/kishikawakatsumi/SpreadsheetView/pull/60

## 0.6.4 Release notes (2017-05-25)

##### Breaking

* None.

##### Enhancements

* None.

##### Bug Fixes

* Reset column/row header view frame when reloading to fix a rendering issue after `reloadData()`.  
  [#54](https://github.com/kishikawakatsumi/SpreadsheetView/pull/54)

## 0.6.3 Release notes (2017-05-19)

##### Breaking

* Rename `Grids`/`Cell.grids` to `Gridlines`/`Cell.gridlines`. Old type and property are now deprecated.
  They will be removed in future version.  
  [#30](https://github.com/kishikawakatsumi/SpreadsheetView/pull/30)

##### Enhancements

* None.

##### Bug Fixes

* Fix a view on the cell cannot receive touch events.  
  [#42](https://github.com/kishikawakatsumi/SpreadsheetView/pull/42)
* Fix an issue that `reloadData()` doesn't reflect the latest state correctly.  
  [#37](https://github.com/kishikawakatsumi/SpreadsheetView/pull/37)

## 0.6.2 Release notes (2017-05-16)

##### Breaking

* None.

##### Enhancements

* None.

##### Bug Fixes

* Fix returning incorrect rect from `rectForItem(at:)`  
  [#13](https://github.com/kishikawakatsumi/SpreadsheetView/pull/13)
* Fix not working `flashScrollIndicators()` method.  
  [#14](https://github.com/kishikawakatsumi/SpreadsheetView/pull/14)

## 0.6.1 Release notes (2017-05-14)

##### Breaking

* None.

##### Enhancements

* None.

##### Bug Fixes

* Fix `scrollToItem(indexPath:scrollPosition:animated:)` generates incorrect results 
  when specified index path for merged cells.  
  [5aab179](https://github.com/kishikawakatsumi/SpreadsheetView/pull/2/commits/5aab179b37e69b67dc7285a2ce2bb80b23bae6b6)

## 0.6.0 Release notes (2017-05-11)

First Version!
