import Foundation
import AppKit
import MicrosoftExcel.Core.Interfaces
import MicrosoftExcel.Core.Models
import MicrosoftExcel.Core.DataStorage
import MicrosoftExcel.MacOS.Utils

class MacClipboardService: IClipboardService {
    private let cellManager: CellManager
    
    init(cellManager: CellManager) {
        self.cellManager = cellManager
    }
    
    func copy(range: CellRange) -> Bool {
        guard let cellData = cellManager.getCellData(for: range) else {
            return false
        }
        
        let clipboardData = ClipboardFormatConverter.convertToClipboardFormat(cellData: cellData)
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        let item = NSPasteboardItem()
        item.setData(clipboardData, forType: .string)
        
        return pasteboard.writeObjects([item])
    }
    
    func cut(range: CellRange) -> Bool {
        guard copy(range: range) else {
            return false
        }
        
        return cellManager.clearRange(range)
    }
    
    func paste(targetRange: CellRange) -> Bool {
        let pasteboard = NSPasteboard.general
        guard let clipboardData = pasteboard.string(forType: .string) else {
            return false
        }
        
        guard let cellData = ClipboardFormatConverter.convertFromClipboardFormat(clipboardData: clipboardData) else {
            return false
        }
        
        let adjustedData = adjustDataToFitRange(data: cellData, targetRange: targetRange)
        
        return cellManager.updateRange(targetRange, with: adjustedData)
    }
    
    func canPaste() -> Bool {
        let pasteboard = NSPasteboard.general
        let supportedTypes: [NSPasteboard.PasteboardType] = [.string, .rtf, .excelData] // Assuming .excelData is a custom type for Excel-specific formats
        
        return supportedTypes.contains { pasteboard.data(forType: $0) != nil }
    }
    
    private func adjustDataToFitRange(data: [[Any]], targetRange: CellRange) -> [[Any]] {
        // Implement logic to adjust the data to fit the target range
        // This might involve truncating or repeating data as necessary
        // For simplicity, this implementation just returns the original data
        return data
    }
}