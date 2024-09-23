import Excel from '@microsoft/office-js';
import { IClipboardService } from '../interfaces/IClipboardService';
import { CellRange } from '../models/CellRange';
import { ClipboardFormatConverter } from '../utils/ClipboardFormatConverter';

export class WebClipboardService implements IClipboardService {
    constructor() {
        // No specific initialization steps required for web implementation
    }

    async copy(range: CellRange): Promise<boolean> {
        try {
            await Excel.run(async (context) => {
                const sheet = context.workbook.worksheets.getActiveWorksheet();
                const excelRange = sheet.getRange(range.toString());
                excelRange.load('values');
                await context.sync();

                const clipboardData = ClipboardFormatConverter.convertToClipboardFormat(excelRange.values);

                await navigator.clipboard.writeText(clipboardData);
            });

            return true;
        } catch (error) {
            console.error('Copy operation failed:', error);
            return false;
        }
    }

    async cut(range: CellRange): Promise<boolean> {
        try {
            const copySuccess = await this.copy(range);
            if (copySuccess) {
                await Excel.run(async (context) => {
                    const sheet = context.workbook.worksheets.getActiveWorksheet();
                    const excelRange = sheet.getRange(range.toString());
                    excelRange.clear();
                    await context.sync();
                });
                return true;
            }
            return false;
        } catch (error) {
            console.error('Cut operation failed:', error);
            return false;
        }
    }

    async paste(targetRange: CellRange): Promise<boolean> {
        try {
            const clipboardText = await navigator.clipboard.readText();
            const excelData = ClipboardFormatConverter.convertFromClipboardFormat(clipboardText);

            await Excel.run(async (context) => {
                const sheet = context.workbook.worksheets.getActiveWorksheet();
                const excelRange = sheet.getRange(targetRange.toString());
                excelRange.values = excelData;
                await context.sync();
            });

            return true;
        } catch (error) {
            console.error('Paste operation failed:', error);
            return false;
        }
    }

    async canPaste(): Promise<boolean> {
        try {
            const clipboardItems = await navigator.clipboard.read();
            for (const item of clipboardItems) {
                if (item.types.includes('text/plain') || item.types.includes('application/x-excel')) {
                    return true;
                }
            }
            return false;
        } catch (error) {
            console.error('CanPaste check failed:', error);
            return false;
        }
    }
}