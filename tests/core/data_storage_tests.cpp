#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "../../src/core/data_storage/cell_manager.hpp"
#include "../../src/core/models/cell.hpp"
#include "../../src/core/models/worksheet.hpp"
#include "../../src/core/models/workbook.hpp"

class DataStorageTest : public ::testing::Test {
protected:
    std::shared_ptr<CellManager> cellManager;
    std::shared_ptr<Workbook> workbook;

    DataStorageTest() {
        cellManager = std::make_shared<CellManager>();
        workbook = std::make_shared<Workbook>();
    }

    void SetUp() override {
        cellManager->clear();
        workbook->reset();
        workbook->addWorksheet("Sheet1");
    }

    void TearDown() override {
        // Release any resources allocated during the test
    }
};

TEST_F(DataStorageTest, CellValueOperations) {
    auto sheet = workbook->getWorksheet("Sheet1");
    
    sheet->setCellValue("A1", 10);
    sheet->setCellValue("B2", "Hello");
    sheet->setCellValue("C3", true);

    EXPECT_EQ(sheet->getCellValue("A1"), 10);
    EXPECT_EQ(sheet->getCellValue("B2"), "Hello");
    EXPECT_EQ(sheet->getCellValue("C3"), true);
    EXPECT_TRUE(sheet->getCellValue("D4").empty());
}

TEST_F(DataStorageTest, CellRangeOperations) {
    auto sheet = workbook->getWorksheet("Sheet1");
    
    // Set values for a range of cells
    for (int row = 1; row <= 3; ++row) {
        for (int col = 1; col <= 3; ++col) {
            sheet->setCellValue(Cell::columnRowToString(col, row), row * col);
        }
    }

    // Retrieve the range and verify values
    auto range = sheet->getCellRange("A1:C3");
    EXPECT_EQ(range.size(), 9);
    EXPECT_EQ(range[0][0]->getValue(), 1);
    EXPECT_EQ(range[2][2]->getValue(), 9);

    // Perform a range operation (sum of A1:C3)
    int sum = 0;
    for (const auto& row : range) {
        for (const auto& cell : row) {
            sum += std::get<int>(cell->getValue());
        }
    }
    EXPECT_EQ(sum, 45);
}

TEST_F(DataStorageTest, WorksheetOperations) {
    EXPECT_EQ(workbook->getWorksheetCount(), 1);

    workbook->addWorksheet("Sheet2");
    EXPECT_EQ(workbook->getWorksheetCount(), 2);

    auto sheet2 = workbook->getWorksheet("Sheet2");
    sheet2->setCellValue("A1", "Test");
    EXPECT_EQ(sheet2->getCellValue("A1"), "Test");

    workbook->renameWorksheet("Sheet2", "NewSheet");
    EXPECT_EQ(workbook->getWorksheet("NewSheet")->getName(), "NewSheet");

    workbook->deleteWorksheet("NewSheet");
    EXPECT_EQ(workbook->getWorksheetCount(), 1);
    EXPECT_THROW(workbook->getWorksheet("NewSheet"), std::runtime_error);
}

TEST_F(DataStorageTest, WorkbookSaveLoad) {
    workbook->addWorksheet("Sheet2");
    auto sheet1 = workbook->getWorksheet("Sheet1");
    auto sheet2 = workbook->getWorksheet("Sheet2");

    sheet1->setCellValue("A1", 10);
    sheet2->setCellValue("B2", "Hello");

    std::string tempFile = "temp_workbook.xlsx";
    workbook->saveToFile(tempFile);

    auto loadedWorkbook = std::make_shared<Workbook>();
    loadedWorkbook->loadFromFile(tempFile);

    EXPECT_EQ(loadedWorkbook->getWorksheetCount(), 2);
    EXPECT_EQ(loadedWorkbook->getWorksheet("Sheet1")->getCellValue("A1"), 10);
    EXPECT_EQ(loadedWorkbook->getWorksheet("Sheet2")->getCellValue("B2"), "Hello");

    // Clean up the temporary file
    std::remove(tempFile.c_str());
}

// TODO: Implement additional test cases for complex data structures, performance, concurrency, data validation, undo/redo, file formats, and data integrity