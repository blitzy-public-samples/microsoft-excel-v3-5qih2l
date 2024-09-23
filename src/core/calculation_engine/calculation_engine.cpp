#include <vector>
#include <unordered_map>
#include <string>
#include <memory>
#include "formula_parser.hpp"
#include "function_library.hpp"
#include "dependency_graph.hpp"
#include "../data_storage/cell_manager.hpp"

const int MAX_ITERATION_COUNT = 1000;
const double EPSILON = 1e-10;

class CalculationEngine {
private:
    std::shared_ptr<FormulaParser> m_formulaParser;
    std::shared_ptr<FunctionLibrary> m_functionLibrary;
    std::shared_ptr<DependencyGraph> m_dependencyGraph;
    std::shared_ptr<CellManager> m_cellManager;
    std::unordered_map<std::string, double> m_resultCache;

public:
    CalculationEngine(std::shared_ptr<CellManager> cellManager)
        : m_cellManager(cellManager) {
        m_formulaParser = std::make_shared<FormulaParser>();
        m_functionLibrary = std::make_shared<FunctionLibrary>();
        m_dependencyGraph = std::make_shared<DependencyGraph>();
    }

    double evaluateFormula(const std::string& formula, const std::string& cellReference) {
        // Check if the result is already in cache
        if (m_resultCache.find(cellReference) != m_resultCache.end()) {
            return m_resultCache[cellReference];
        }

        std::vector<std::string> tokens = m_formulaParser->parse(formula);
        m_dependencyGraph->addDependency(cellReference, tokens);

        double result = 0.0;
        std::vector<double> stack;

        for (const auto& token : tokens) {
            if (m_functionLibrary->isFunction(token)) {
                // Handle function execution
                int argCount = m_functionLibrary->getArgCount(token);
                std::vector<double> args(argCount);
                for (int i = argCount - 1; i >= 0; --i) {
                    args[i] = stack.back();
                    stack.pop_back();
                }
                double functionResult = m_functionLibrary->executeFunction(token, args);
                stack.push_back(functionResult);
            } else if (isCellReference(token)) {
                // Fetch cell value from CellManager
                double cellValue = m_cellManager->getCellValue(token);
                stack.push_back(cellValue);
            } else {
                // Assume it's a number
                stack.push_back(std::stod(token));
            }
        }

        result = stack.back();
        m_resultCache[cellReference] = result;
        return result;
    }

    void recalculate(const std::string& range = "") {
        std::vector<std::string> cellsToRecalculate;
        if (range.empty()) {
            cellsToRecalculate = m_dependencyGraph->getAllCells();
        } else {
            cellsToRecalculate = m_cellManager->getCellsInRange(range);
        }

        // Sort cells based on dependencies
        m_dependencyGraph->sortCellsByDependency(cellsToRecalculate);

        for (const auto& cell : cellsToRecalculate) {
            std::string formula = m_cellManager->getCellFormula(cell);
            double newValue = evaluateFormula(formula, cell);
            m_cellManager->updateCellValue(cell, newValue);
        }
    }

    void clearCache() {
        m_resultCache.clear();
    }
};

bool isCircularReference(const std::string& cellReference, const std::vector<std::string>& dependencies) {
    return DependencyGraph::detectCircularReference(cellReference, dependencies);
}

// Helper function to check if a token is a cell reference
bool isCellReference(const std::string& token) {
    // Implement logic to determine if the token is a valid cell reference
    // For example, check if it matches a pattern like "A1", "B2", etc.
    return false; // Placeholder implementation
}

// TODO: Implement error handling for division by zero and other mathematical errors
// TODO: Optimize performance for large datasets by implementing parallel calculation where possible
// TODO: Add support for custom functions defined by users or add-ins
// TODO: Implement a more sophisticated caching mechanism to improve performance for frequently used formulas