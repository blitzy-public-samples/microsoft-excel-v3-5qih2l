using System;
using System.IO;
using System.Threading.Tasks;
using System.Windows;
using Microsoft.Win32;
using MicrosoftExcel.Core.Interfaces;
using MicrosoftExcel.Core.Models;
using MicrosoftExcel.Core.DataStorage;
using MicrosoftExcel.Windows.Utils;

namespace MicrosoftExcel.Windows.Services
{
    public class WinFileService : IFileService
    {
        private readonly CellManager cellManager;

        public WinFileService(CellManager cellManager)
        {
            this.cellManager = cellManager ?? throw new ArgumentNullException(nameof(cellManager));
        }

        public async Task<Workbook> OpenFile()
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter = "Excel Files|*.xlsx;*.xls|CSV Files|*.csv|All Files|*.*",
                Title = "Open Excel File"
            };

            if (openFileDialog.ShowDialog() == true)
            {
                try
                {
                    string fileContent = await File.ReadAllTextAsync(openFileDialog.FileName);
                    var workbook = await FileFormatConverter.ConvertToWorkbook(fileContent, Path.GetExtension(openFileDialog.FileName));
                    
                    // Update CellManager with the new Workbook data
                    await cellManager.LoadWorkbook(workbook);

                    return workbook;
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error opening file: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }

            return null;
        }

        public async Task<bool> SaveFile(Workbook workbook)
        {
            var saveFileDialog = new SaveFileDialog
            {
                Filter = "Excel Files|*.xlsx|CSV Files|*.csv|All Files|*.*",
                Title = "Save Excel File"
            };

            if (saveFileDialog.ShowDialog() == true)
            {
                try
                {
                    string fileContent = await FileFormatConverter.ConvertToFileFormat(workbook, Path.GetExtension(saveFileDialog.FileName));
                    await File.WriteAllTextAsync(saveFileDialog.FileName, fileContent);
                    return true;
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error saving file: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }

            return false;
        }

        public async Task<bool> ExportToPdf(Workbook workbook)
        {
            var saveFileDialog = new SaveFileDialog
            {
                Filter = "PDF Files|*.pdf",
                Title = "Export to PDF"
            };

            if (saveFileDialog.ShowDialog() == true)
            {
                try
                {
                    byte[] pdfData = await FileFormatConverter.ConvertToPdf(workbook);
                    await File.WriteAllBytesAsync(saveFileDialog.FileName, pdfData);
                    return true;
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error exporting to PDF: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }

            return false;
        }

        public async Task<bool> ImportFromCsv()
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter = "CSV Files|*.csv",
                Title = "Import CSV File"
            };

            if (openFileDialog.ShowDialog() == true)
            {
                try
                {
                    string csvContent = await File.ReadAllTextAsync(openFileDialog.FileName);
                    var workbook = await FileFormatConverter.ConvertCsvToWorkbook(csvContent);
                    
                    // Update CellManager with the imported data
                    await cellManager.LoadWorkbook(workbook);

                    return true;
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error importing CSV: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }

            return false;
        }
    }
}