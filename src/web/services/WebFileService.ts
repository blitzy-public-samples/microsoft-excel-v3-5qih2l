import { Excel } from '@microsoft/office-js';
import { IFileService } from '../interfaces/IFileService';
import { Workbook } from '../models/Workbook';
import { FileFormatConverter } from '../utils/FileFormatConverter';

export class WebFileService implements IFileService {
    constructor() {
        // No specific initialization steps required for web implementation
    }

    async openFile(): Promise<Workbook> {
        try {
            return await Excel.run(async (context) => {
                const workbook = context.workbook;
                workbook.load('worksheets');
                await context.sync();

                const excelWorkbook = workbook.toJSON();
                const convertedWorkbook = await FileFormatConverter.convertToWorkbook(excelWorkbook);
                return convertedWorkbook;
            });
        } catch (error) {
            console.error('Error opening file:', error);
            throw error;
        }
    }

    async saveFile(workbook: Workbook): Promise<boolean> {
        try {
            return await Excel.run(async (context) => {
                const excelWorkbook = await FileFormatConverter.convertFromWorkbook(workbook);
                const currentWorkbook = context.workbook;

                // Apply changes to the current Excel.Workbook
                // This is a simplified example, you'd need to implement the actual update logic
                currentWorkbook.worksheets.load('items');
                await context.sync();

                excelWorkbook.worksheets.forEach((sheet, index) => {
                    if (index < currentWorkbook.worksheets.items.length) {
                        const currentSheet = currentWorkbook.worksheets.items[index];
                        currentSheet.name = sheet.name;
                        // Update other properties and cell values
                    }
                });

                await context.sync();
                return true;
            });
        } catch (error) {
            console.error('Error saving file:', error);
            return false;
        }
    }

    async exportToPdf(workbook: Workbook): Promise<boolean> {
        try {
            return await Excel.run(async (context) => {
                const pdf = await context.workbook.convertToPdf();
                
                // Trigger download of the PDF file
                const blob = new Blob([pdf], { type: 'application/pdf' });
                const link = document.createElement('a');
                link.href = window.URL.createObjectURL(blob);
                link.download = 'exported_workbook.pdf';
                link.click();

                return true;
            });
        } catch (error) {
            console.error('Error exporting to PDF:', error);
            return false;
        }
    }

    async importFromCsv(csvFile: File): Promise<boolean> {
        try {
            const csvContent = await this.readFileContent(csvFile);
            const workbook = await FileFormatConverter.convertCsvToWorkbook(csvContent);

            return await Excel.run(async (context) => {
                const currentWorkbook = context.workbook;
                currentWorkbook.worksheets.load('items');
                await context.sync();

                // Apply the converted data to the current Excel.Workbook
                // This is a simplified example, you'd need to implement the actual import logic
                workbook.worksheets.forEach((sheet, index) => {
                    let currentSheet;
                    if (index < currentWorkbook.worksheets.items.length) {
                        currentSheet = currentWorkbook.worksheets.items[index];
                    } else {
                        currentSheet = currentWorkbook.worksheets.add();
                    }
                    currentSheet.name = sheet.name;
                    // Import cell values and other properties
                });

                await context.sync();
                return true;
            });
        } catch (error) {
            console.error('Error importing CSV:', error);
            return false;
        }
    }

    private async readFileContent(file: File): Promise<string> {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = (event) => resolve(event.target?.result as string);
            reader.onerror = (error) => reject(error);
            reader.readAsText(file);
        });
    }
}