import Foundation
import UIKit
import UniformTypeIdentifiers
import MicrosoftExcel.Core.Interfaces
import MicrosoftExcel.Core.Models
import MicrosoftExcel.Core.DataStorage
import MicrosoftExcel.iOS.Utils

class iOSFileService: IFileService {
    private let cellManager: CellManager
    private let presentingViewController: UIViewController
    
    init(cellManager: CellManager, presentingViewController: UIViewController) {
        self.cellManager = cellManager
        self.presentingViewController = presentingViewController
    }
    
    func openFile() -> Workbook? {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.xlsx, UTType.xls, UTType.commaSeparatedText])
        documentPicker.delegate = self
        
        var selectedWorkbook: Workbook?
        let semaphore = DispatchSemaphore(value: 0)
        
        documentPicker.completionHandler = { urls in
            guard let url = urls.first else {
                semaphore.signal()
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                let workbook = try FileFormatConverter.convertToWorkbook(data: data)
                self.cellManager.updateWorkbook(workbook)
                selectedWorkbook = workbook
            } catch {
                print("Error opening file: \(error)")
            }
            
            semaphore.signal()
        }
        
        presentingViewController.present(documentPicker, animated: true)
        semaphore.wait()
        
        return selectedWorkbook
    }
    
    func saveFile(workbook: Workbook) -> Bool {
        guard let data = try? FileFormatConverter.convertToFileFormat(workbook: workbook) else {
            return false
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_workbook.xlsx")
        do {
            try data.write(to: tempURL)
        } catch {
            print("Error creating temporary file: \(error)")
            return false
        }
        
        let documentInteractionController = UIDocumentInteractionController(url: tempURL)
        documentInteractionController.delegate = self
        
        let success = documentInteractionController.presentOptionsMenu(from: presentingViewController.view.bounds, in: presentingViewController.view, animated: true)
        
        // Clean up temporary file
        try? FileManager.default.removeItem(at: tempURL)
        
        return success
    }
    
    func exportToPdf(workbook: Workbook) -> Bool {
        guard let pdfData = try? FileFormatConverter.convertToPdf(workbook: workbook) else {
            return false
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_workbook.pdf")
        do {
            try pdfData.write(to: tempURL)
        } catch {
            print("Error creating temporary PDF file: \(error)")
            return false
        }
        
        let documentInteractionController = UIDocumentInteractionController(url: tempURL)
        documentInteractionController.delegate = self
        
        let success = documentInteractionController.presentOptionsMenu(from: presentingViewController.view.bounds, in: presentingViewController.view, animated: true)
        
        // Clean up temporary file
        try? FileManager.default.removeItem(at: tempURL)
        
        return success
    }
    
    func importFromCsv() -> Bool {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.commaSeparatedText])
        documentPicker.delegate = self
        
        var success = false
        let semaphore = DispatchSemaphore(value: 0)
        
        documentPicker.completionHandler = { urls in
            guard let url = urls.first else {
                semaphore.signal()
                return
            }
            
            do {
                let csvData = try Data(contentsOf: url)
                let workbook = try FileFormatConverter.convertCsvToWorkbook(csvData: csvData)
                self.cellManager.updateWorkbook(workbook)
                success = true
            } catch {
                print("Error importing CSV: \(error)")
            }
            
            semaphore.signal()
        }
        
        presentingViewController.present(documentPicker, animated: true)
        semaphore.wait()
        
        return success
    }
}

extension iOSFileService: UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate {
    // Implement delegate methods if needed
}