#include <vector>
#include <unordered_map>
#include <string>
#include <cmath>
#include <algorithm>
#include <stdexcept>
#include "function_library.hpp"
#include "../data_storage/cell_manager.hpp"

const int MAX_ARGS = 255;

FunctionLibrary::FunctionLibrary(std::shared_ptr<CellManager> cellManager)
    : m_cellManager(cellManager) {
    registerBuiltInFunctions();
}

double FunctionLibrary::executeFunction(const std::string& functionName, const std::vector<double>& args) {
    auto it = m_functions.find(functionName);
    if (it != m_functions.end()) {
        return it->second(args);
    }
    throw std::invalid_argument("Function not found: " + functionName);
}

void FunctionLibrary::registerBuiltInFunctions() {
    // Mathematical functions
    m_functions["SUM"] = sum;
    m_functions["AVERAGE"] = average;
    m_functions["MIN"] = [](const std::vector<double>& args) { return *std::min_element(args.begin(), args.end()); };
    m_functions["MAX"] = [](const std::vector<double>& args) { return *std::max_element(args.begin(), args.end()); };

    // Statistical functions
    m_functions["COUNT"] = [](const std::vector<double>& args) { return static_cast<double>(args.size()); };
    
    // Logical functions
    m_functions["IF"] = if_func;

    // TODO: Implement more functions for each category
    // Text functions
    // Date and time functions
    // Lookup and reference functions
    // Financial functions
    // Information functions
}

double sum(const std::vector<double>& args) {
    double result = 0;
    for (const auto& arg : args) {
        result += arg;
    }
    return result;
}

double average(const std::vector<double>& args) {
    if (args.empty()) {
        throw std::invalid_argument("AVERAGE function requires at least one argument");
    }
    return sum(args) / args.size();
}

double if_func(const std::vector<double>& args) {
    if (args.size() < 2) {
        throw std::invalid_argument("IF function requires at least two arguments");
    }
    
    bool condition = args[0] != 0;
    if (condition) {
        return args[1];
    } else if (args.size() > 2) {
        return args[2];
    }
    return 0;
}