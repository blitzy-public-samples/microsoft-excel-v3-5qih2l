using System;
using System.Windows;
using System.Windows.Interop;
using System.Runtime.InteropServices;
using MicrosoftExcel.Core.Interfaces;
using MicrosoftExcel.Core.Models;
using MicrosoftExcel.Core.DataStorage;
using MicrosoftExcel.Windows.Utils;

namespace MicrosoftExcel.Windows.Services
{
    public class WinClipboardService : IClipboardService
    {
        private readonly CellManager cellManager;

        public WinClipboardService(CellManager cellManager)
        {
            this.cellManager = cellManager ?? throw new ArgumentNullException(nameof(cellManager));
        }

        public bool Copy(CellRange range)
        {
            try
            {
                // Retrieve the cell data for the given range from cellManager
                var cellData = cellManager.GetRangeData(range);

                // Use ClipboardFormatConverter to convert the cell data to the appropriate clipboard format
                var clipboardData = ClipboardFormatConverter.ConvertToClipboardFormat(cellData);

                // Set the converted data to the Windows clipboard using Clipboard.SetDataObject
                Clipboard.SetDataObject(clipboardData, true);

                return true;
            }
            catch (Exception ex)
            {
                // Log the exception
                Console.WriteLine($"Error during copy operation: {ex.Message}");
                return false;
            }
        }

        public bool Cut(CellRange range)
        {
            // Call the Copy method with the given range
            if (Copy(range))
            {
                try
                {
                    // If Copy is successful, clear the cell data for the given range using cellManager.ClearRange
                    cellManager.ClearRange(range);
                    return true;
                }
                catch (Exception ex)
                {
                    // Log the exception
                    Console.WriteLine($"Error during cut operation: {ex.Message}");
                    return false;
                }
            }
            return false;
        }

        public bool Paste(CellRange targetRange)
        {
            try
            {
                // Retrieve the clipboard data using Clipboard.GetDataObject
                IDataObject clipboardData = Clipboard.GetDataObject();

                if (clipboardData != null)
                {
                    // Use ClipboardFormatConverter to convert the clipboard data to cell data
                    var cellData = ClipboardFormatConverter.ConvertFromClipboardFormat(clipboardData);

                    // Adjust the converted data to fit the targetRange if necessary
                    cellData = AdjustDataToTargetRange(cellData, targetRange);

                    // Update the cell data for the targetRange using cellManager.UpdateRange
                    cellManager.UpdateRange(targetRange, cellData);

                    return true;
                }
            }
            catch (Exception ex)
            {
                // Log the exception
                Console.WriteLine($"Error during paste operation: {ex.Message}");
            }
            return false;
        }

        public bool CanPaste()
        {
            // Check if the clipboard contains text data
            bool hasText = Clipboard.ContainsText();

            // Check if the clipboard contains Excel-specific formats
            bool hasExcelFormat = Clipboard.ContainsData("XML Spreadsheet") || 
                                  Clipboard.ContainsData("Biff12") || 
                                  Clipboard.ContainsData("Biff8") || 
                                  Clipboard.ContainsData("Biff5") || 
                                  Clipboard.ContainsData("Csv");

            // Return true if any supported format is available, false otherwise
            return hasText || hasExcelFormat;
        }

        private object AdjustDataToTargetRange(object data, CellRange targetRange)
        {
            // Implement logic to adjust the data to fit the target range
            // This might involve truncating or repeating the data to match the target range dimensions
            // For simplicity, this implementation just returns the original data
            // In a real implementation, you would need to handle different data types and sizes
            return data;
        }
    }
}