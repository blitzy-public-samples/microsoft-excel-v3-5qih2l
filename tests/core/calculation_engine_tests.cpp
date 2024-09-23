#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "../../src/core/calculation_engine/calculation_engine.hpp"
#include "../../src/core/data_storage/cell_manager.hpp"
#include "../../src/core/models/cell.hpp"
#include "../../src/core/models/worksheet.hpp"

class CalculationEngineTest : public ::testing::Test {
protected:
    std::shared_ptr<CalculationEngine> calculationEngine;
    std::shared_ptr<CellManager> cellManager;

    CalculationEngineTest() {
        cellManager = std::make_shared<CellManager>();
        calculationEngine = std::make_shared<CalculationEngine>(cellManager);
    }

    void SetUp() override {
        cellManager->clear();
        // Reset calculationEngine state if necessary
    }

    void TearDown() override {
        // Release any resources allocated during the test
    }
};

TEST_F(CalculationEngineTest, BasicArithmeticOperations) {
    cellManager->setCellValue("A1", 10);
    cellManager->setCellValue("A2", 5);
    cellManager->setCellFormula("A3", "=A1 + A2");
    cellManager->setCellFormula("A4", "=A1 - A2");
    cellManager->setCellFormula("A5", "=A1 * A2");
    cellManager->setCellFormula("A6", "=A1 / A2");

    calculationEngine->evaluateAll();

    EXPECT_EQ(cellManager->getCellValue("A3"), 15);
    EXPECT_EQ(cellManager->getCellValue("A4"), 5);
    EXPECT_EQ(cellManager->getCellValue("A5"), 50);
    EXPECT_EQ(cellManager->getCellValue("A6"), 2);
}

TEST_F(CalculationEngineTest, ComplexFormulas) {
    cellManager->setCellValue("A1", 10);
    cellManager->setCellValue("A2", 5);
    cellManager->setCellValue("A3", 2);
    cellManager->setCellFormula("B1", "=SUM(A1:A3)");
    cellManager->setCellFormula("B2", "=AVERAGE(A1:A3)");
    cellManager->setCellFormula("B3", "=IF(A1>A2, A1, A2)");

    calculationEngine->evaluateAll();

    EXPECT_EQ(cellManager->getCellValue("B1"), 17);
    EXPECT_NEAR(cellManager->getCellValue("B2"), 5.67, 0.01);
    EXPECT_EQ(cellManager->getCellValue("B3"), 10);
}

TEST_F(CalculationEngineTest, CircularReferences) {
    cellManager->setCellFormula("A1", "=A2 + 1");
    cellManager->setCellFormula("A2", "=A1 + 1");

    EXPECT_THROW(calculationEngine->evaluateAll(), std::runtime_error);
}

TEST_F(CalculationEngineTest, ErrorPropagation) {
    cellManager->setCellFormula("A1", "=1/0");
    cellManager->setCellFormula("A2", "=A1 + 1");

    calculationEngine->evaluateAll();

    EXPECT_EQ(cellManager->getCellValue("A1"), "#DIV/0!");
    EXPECT_EQ(cellManager->getCellValue("A2"), "#DIV/0!");
}

// TODO: Implement additional test cases for more complex Excel functions
// TODO: Add performance tests for large datasets and complex calculation chains
// TODO: Implement tests for multi-threaded calculation scenarios
// TODO: Add tests for handling different data types (string, boolean, date) in formulas
// TODO: Implement tests for array formulas and dynamic arrays
// TODO: Add tests for volatile functions (e.g., NOW(), RAND())
// TODO: Implement tests for external data references and real-time data feeds