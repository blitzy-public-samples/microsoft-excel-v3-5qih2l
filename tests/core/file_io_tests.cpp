#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include <fstream>
#include <filesystem>
#include "../../src/core/file_io/file_reader.hpp"
#include "../../src/core/file_io/file_writer.hpp"
#include "../../src/core/models/workbook.hpp"
#include "../../src/core/models/worksheet.hpp"
#include "../../src/core/models/cell.hpp"

class FileIOTest : public ::testing::Test {
protected:
    std::unique_ptr<FileReader> fileReader;
    std::unique_ptr<FileWriter> fileWriter;
    std::shared_ptr<Workbook> testWorkbook;
    std::string testFilePath;

    FileIOTest() {
        fileReader = std::make_unique<FileReader>();
        fileWriter = std::make_unique<FileWriter>();
        testWorkbook = std::make_shared<Workbook>();
        testFilePath = std::filesystem::temp_directory_path() / "test_workbook";
    }

    void SetUp() override {
        testWorkbook->clear();
        auto worksheet = testWorkbook->addWorksheet("Sheet1");
        worksheet->setCellValue(0, 0, "Test");
        worksheet->setCellValue(0, 1, 42);
        worksheet->setCellFormula(1, 0, "=A1&B1");
    }

    void TearDown() override {
        if (std::filesystem::exists(testFilePath)) {
            std::filesystem::remove(testFilePath);
        }
    }
};

TEST_F(FileIOTest, WriteReadXLSX) {
    std::string xlsxPath = testFilePath + ".xlsx";
    
    ASSERT_NO_THROW(fileWriter->writeXLSX(*testWorkbook, xlsxPath));
    
    auto loadedWorkbook = std::make_shared<Workbook>();
    ASSERT_NO_THROW(fileReader->readXLSX(xlsxPath, *loadedWorkbook));
    
    ASSERT_EQ(testWorkbook->getWorksheetCount(), loadedWorkbook->getWorksheetCount());
    
    auto originalSheet = testWorkbook->getWorksheet(0);
    auto loadedSheet = loadedWorkbook->getWorksheet(0);
    
    ASSERT_EQ(originalSheet->getCellValue(0, 0), loadedSheet->getCellValue(0, 0));
    ASSERT_EQ(originalSheet->getCellValue(0, 1), loadedSheet->getCellValue(0, 1));
    ASSERT_EQ(originalSheet->getCellFormula(1, 0), loadedSheet->getCellFormula(1, 0));
}

TEST_F(FileIOTest, WriteReadCSV) {
    std::string csvPath = testFilePath + ".csv";
    
    ASSERT_NO_THROW(fileWriter->writeCSV(*testWorkbook, csvPath));
    
    auto loadedWorkbook = std::make_shared<Workbook>();
    ASSERT_NO_THROW(fileReader->readCSV(csvPath, *loadedWorkbook));
    
    ASSERT_EQ(1, loadedWorkbook->getWorksheetCount());
    
    auto originalSheet = testWorkbook->getWorksheet(0);
    auto loadedSheet = loadedWorkbook->getWorksheet(0);
    
    ASSERT_EQ(originalSheet->getCellValue(0, 0), loadedSheet->getCellValue(0, 0));
    ASSERT_EQ(originalSheet->getCellValue(0, 1), loadedSheet->getCellValue(0, 1));
    ASSERT_EQ("", loadedSheet->getCellFormula(1, 0)); // Formulas are not preserved in CSV
}

TEST_F(FileIOTest, LargeFileHandling) {
    const int ROWS = 10000;
    const int COLS = 100;
    
    auto largeWorkbook = std::make_shared<Workbook>();
    auto sheet = largeWorkbook->addWorksheet("LargeSheet");
    
    for (int i = 0; i < ROWS; ++i) {
        for (int j = 0; j < COLS; ++j) {
            sheet->setCellValue(i, j, i * COLS + j);
        }
    }
    
    std::string largePath = testFilePath + "_large.xlsx";
    
    auto start = std::chrono::high_resolution_clock::now();
    ASSERT_NO_THROW(fileWriter->writeXLSX(*largeWorkbook, largePath));
    auto writeEnd = std::chrono::high_resolution_clock::now();
    
    auto loadedWorkbook = std::make_shared<Workbook>();
    ASSERT_NO_THROW(fileReader->readXLSX(largePath, *loadedWorkbook));
    auto readEnd = std::chrono::high_resolution_clock::now();
    
    auto writeDuration = std::chrono::duration_cast<std::chrono::milliseconds>(writeEnd - start);
    auto readDuration = std::chrono::duration_cast<std::chrono::milliseconds>(readEnd - writeEnd);
    
    std::cout << "Write time: " << writeDuration.count() << "ms" << std::endl;
    std::cout << "Read time: " << readDuration.count() << "ms" << std::endl;
    
    ASSERT_EQ(ROWS, loadedWorkbook->getWorksheet(0)->getRowCount());
    ASSERT_EQ(COLS, loadedWorkbook->getWorksheet(0)->getColumnCount());
    
    // Check a few random cells
    ASSERT_EQ(largeWorkbook->getWorksheet(0)->getCellValue(1000, 50), 
              loadedWorkbook->getWorksheet(0)->getCellValue(1000, 50));
    ASSERT_EQ(largeWorkbook->getWorksheet(0)->getCellValue(5000, 75), 
              loadedWorkbook->getWorksheet(0)->getCellValue(5000, 75));
}

TEST_F(FileIOTest, ErrorHandling) {
    // Attempt to read a non-existent file
    auto nonExistentWorkbook = std::make_shared<Workbook>();
    ASSERT_THROW(fileReader->readXLSX("non_existent_file.xlsx", *nonExistentWorkbook), std::runtime_error);
    
    // Attempt to write to a read-only location (this might need to be adjusted based on the system)
    std::string readOnlyPath = "/read_only_directory/test.xlsx";
    ASSERT_THROW(fileWriter->writeXLSX(*testWorkbook, readOnlyPath), std::runtime_error);
    
    // Attempt to read a corrupted XLSX file
    std::string corruptedPath = testFilePath + "_corrupted.xlsx";
    std::ofstream corruptedFile(corruptedPath);
    corruptedFile << "This is not a valid XLSX file content";
    corruptedFile.close();
    
    auto corruptedWorkbook = std::make_shared<Workbook>();
    ASSERT_THROW(fileReader->readXLSX(corruptedPath, *corruptedWorkbook), std::runtime_error);
    
    // Attempt to read a file with an unsupported format
    std::string unsupportedPath = testFilePath + ".unsupported";
    std::ofstream unsupportedFile(unsupportedPath);
    unsupportedFile << "Some content";
    unsupportedFile.close();
    
    auto unsupportedWorkbook = std::make_shared<Workbook>();
    ASSERT_THROW(fileReader->readXLSX(unsupportedPath, *unsupportedWorkbook), std::runtime_error);
}

// TODO: Implement tests for additional file formats (e.g., ODS, HTML)
// TODO: Add tests for preserving and reading complex Excel features (e.g., charts, pivot tables)
// TODO: Implement tests for concurrent file access scenarios
// TODO: Add performance benchmarks for file I/O operations with various file sizes
// TODO: Implement tests for handling different character encodings in CSV files
// TODO: Add tests for auto-recovery of partially corrupted files
// TODO: Implement tests for backwards compatibility with older Excel file formats