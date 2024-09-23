using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Windows;
using System.Windows.Controls;
using MicrosoftExcel.Windows.UI;
using MicrosoftExcel.Windows.ViewModels;
using MicrosoftExcel.Core.Models;

namespace MicrosoftExcel.Tests.Windows
{
    [TestClass]
    public class WindowsUITests
    {
        public TestContext TestContext { get; set; }

        [TestMethod]
        public void MainWindowInitializationTest()
        {
            // Create a new instance of MainWindow
            var mainWindow = new MainWindow();

            // Assert that the MainWindow is not null
            Assert.IsNotNull(mainWindow);

            // Assert that the DataContext of MainWindow is an instance of MainWindowViewModel
            Assert.IsInstanceOfType(mainWindow.DataContext, typeof(MainWindowViewModel));

            // Verify that the initial state of the MainWindow is correct
            Assert.AreEqual("Microsoft Excel", mainWindow.Title);
            Assert.AreEqual(1024, mainWindow.Width);
            Assert.AreEqual(768, mainWindow.Height);
        }

        [TestMethod]
        public void RibbonControlTest()
        {
            // Create a new instance of RibbonControl
            var ribbonControl = new RibbonControl();

            // Assert that the RibbonControl is not null
            Assert.IsNotNull(ribbonControl);

            // Verify that all expected tabs are present in the Ribbon
            Assert.IsTrue(ribbonControl.HasTab("Home"));
            Assert.IsTrue(ribbonControl.HasTab("Insert"));
            Assert.IsTrue(ribbonControl.HasTab("Page Layout"));

            // Test tab switching functionality
            ribbonControl.SelectTab("Insert");
            Assert.AreEqual("Insert", ribbonControl.SelectedTab);

            // Verify that buttons in the Ribbon are properly bound to commands in the ViewModel
            var viewModel = (RibbonViewModel)ribbonControl.DataContext;
            Assert.IsNotNull(viewModel.CopyCommand);
            Assert.IsNotNull(viewModel.PasteCommand);
        }

        [TestMethod]
        public void WorksheetGridControlTest()
        {
            // Create a new instance of WorksheetGridControl
            var gridControl = new WorksheetGridControl();

            // Assert that the WorksheetGridControl is not null
            Assert.IsNotNull(gridControl);

            // Verify that the initial grid dimensions are correct
            Assert.AreEqual(1000, gridControl.RowCount);
            Assert.AreEqual(26, gridControl.ColumnCount);

            // Test cell selection functionality
            gridControl.SelectCell(0, 0);
            Assert.AreEqual("A1", gridControl.SelectedCellAddress);

            // Verify that cell values are properly displayed and editable
            gridControl.SetCellValue(0, 0, "Test");
            Assert.AreEqual("Test", gridControl.GetCellValue(0, 0));
        }

        [TestMethod]
        public void UIInteractionTest()
        {
            // Create a test workbook with sample data
            var workbook = new Workbook();
            var worksheet = workbook.AddWorksheet("Sheet1");
            worksheet.SetCellValue(0, 0, "Hello");
            worksheet.SetCellValue(0, 1, "World");

            // Load the test workbook into the MainWindow
            var mainWindow = new MainWindow();
            mainWindow.LoadWorkbook(workbook);

            // Simulate user interactions
            var ribbonControl = mainWindow.FindName("ribbonControl") as RibbonControl;
            ribbonControl.SelectTab("Home");

            var gridControl = mainWindow.FindName("worksheetGrid") as WorksheetGridControl;
            gridControl.SelectCell(0, 0);
            gridControl.SetCellValue(0, 0, "Updated");

            // Verify that the UI responds correctly to user inputs
            Assert.AreEqual("Home", ribbonControl.SelectedTab);
            Assert.AreEqual("A1", gridControl.SelectedCellAddress);

            // Check that changes are reflected in the underlying data model
            Assert.AreEqual("Updated", worksheet.GetCellValue(0, 0));
        }
    }
}