import Foundation
import AppKit
import UniformTypeIdentifiers
import MicrosoftExcel.Core.Interfaces
import MicrosoftExcel.Core.Models
import MicrosoftExcel.Core.DataStorage
import MicrosoftExcel.MacOS.Utils

class MacFileService: IFileService {
    private let cellManager: CellManager
    
    init(cellManager: CellManager) {
        self.cellManager = cellManager
    }
    
    func openFile() -> Workbook? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType.xlsx, UTType.xls, UTType.commaSeparatedText]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        
        guard openPanel.runModal() == .OK, let url = openPanel.url else {
            return nil
        }
        
        do {
            let fileContents = try Data(contentsOf: url)
            let workbook = try FileFormatConverter.convertToWorkbook(data: fileContents, fileType: url.pathExtension)
            cellManager.updateWithWorkbook(workbook)
            return workbook
        } catch {
            print("Error opening file: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveFile(workbook: Workbook) -> Bool {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.xlsx, UTType.xls, UTType.commaSeparatedText]
        savePanel.canCreateDirectories = true
        
        guard savePanel.runModal() == .OK, let url = savePanel.url else {
            return false
        }
        
        do {
            let fileData = try FileFormatConverter.convertToFileFormat(workbook: workbook, fileType: url.pathExtension)
            try fileData.write(to: url)
            return true
        } catch {
            print("Error saving file: \(error.localizedDescription)")
            return false
        }
    }
    
    func exportToPdf(workbook: Workbook) -> Bool {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.pdf]
        savePanel.canCreateDirectories = true
        
        guard savePanel.runModal() == .OK, let url = savePanel.url else {
            return false
        }
        
        do {
            let pdfData = try FileFormatConverter.convertToPdf(workbook: workbook)
            try pdfData.write(to: url)
            return true
        } catch {
            print("Error exporting to PDF: \(error.localizedDescription)")
            return false
        }
    }
    
    func importFromCsv() -> Bool {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType.commaSeparatedText]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        
        guard openPanel.runModal() == .OK, let url = openPanel.url else {
            return false
        }
        
        do {
            let csvContents = try String(contentsOf: url)
            let workbook = try FileFormatConverter.convertCsvToWorkbook(csvContents: csvContents)
            cellManager.updateWithWorkbook(workbook)
            return true
        } catch {
            print("Error importing CSV: \(error.localizedDescription)")
            return false
        }
    }
}