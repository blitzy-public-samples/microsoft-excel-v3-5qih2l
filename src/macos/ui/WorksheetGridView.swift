import AppKit
import SwiftUI
import MicrosoftExcel.MacOS.ViewModels
import MicrosoftExcel.Core.Models
import MicrosoftExcel.Core.DataStorage
import MicrosoftExcel.MacOS.Utils

class WorksheetGridView: NSView {
    var viewModel: WorksheetGridViewModel
    var scrollView: NSScrollView
    var tableView: NSTableView
    var formulaBar: NSTextField
    var rowCount: Int
    var columnCount: Int
    
    init(frame: NSRect, viewModel: WorksheetGridViewModel) {
        self.viewModel = viewModel
        self.scrollView = NSScrollView()
        self.tableView = NSTableView()
        self.formulaBar = NSTextField()
        self.rowCount = 1000 // Default value
        self.columnCount = 26 // Default value
        
        super.init(frame: frame)
        
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Configure formula bar
        formulaBar.placeholderString = "Enter formula"
        addSubview(formulaBar)
        
        // Configure scroll view
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        addSubview(scrollView)
        
        // Configure table view
        tableView.gridStyleMask = .solidHorizontalGridLineMask.union(.solidVerticalGridLineMask)
        tableView.intercellSpacing = NSSize(width: 1, height: 1)
        tableView.backgroundColor = .white
        tableView.headerView = nil
        tableView.dataSource = self
        tableView.delegate = self
        scrollView.documentView = tableView
        
        // Add column headers
        for column in 0..<columnCount {
            let columnIdentifier = NSUserInterfaceItemIdentifier(String(column))
            let tableColumn = NSTableColumn(identifier: columnIdentifier)
            tableColumn.width = 100 // Default width
            tableView.addTableColumn(tableColumn)
        }
        
        // Set up auto layout constraints
        formulaBar.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            formulaBar.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            formulaBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            formulaBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            formulaBar.heightAnchor.constraint(equalToConstant: 24),
            
            scrollView.topAnchor.constraint(equalTo: formulaBar.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // Implement bindings between UI elements and view model
    }
}

extension WorksheetGridView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rowCount
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableView.tableColumns.firstIndex(of: tableColumn!) else { return nil }
        
        let cellData = viewModel.getCellData(row: row, column: column)
        let cellView = NSTextField()
        
        CellFormatter.formatCell(cellView, with: cellData)
        
        cellView.target = self
        cellView.action = #selector(cellEdited(_:))
        
        return cellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        let row = tableView.selectedRow
        let column = tableView.selectedColumn
        
        viewModel.selectCell(row: row, column: column)
        formulaBar.stringValue = viewModel.getSelectedCellFormula() ?? ""
        
        // Highlight the selected cell
        tableView.reloadData()
    }
    
    @objc func cellEdited(_ sender: NSTextField) {
        guard let row = tableView.row(for: sender), let column = tableView.column(for: sender) else { return }
        
        viewModel.updateCellValue(row: row, column: column, value: sender.stringValue)
        // Trigger recalculation and UI update
        tableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
        // Implement column resizing logic
        return tableView.tableColumns[column].width
    }
}