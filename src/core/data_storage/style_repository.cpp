#include <unordered_map>
#include <string>
#include <memory>
#include "style_repository.hpp"
#include "../models/style.hpp"

const std::string DEFAULT_STYLE_ID = "default";

StyleRepository::StyleRepository() {
    // Create a default style
    auto defaultStyle = std::make_shared<Style>();
    
    // Add the default style to m_styles with the key DEFAULT_STYLE_ID
    m_styles[DEFAULT_STYLE_ID] = defaultStyle;
}

void StyleRepository::addStyle(const std::string& styleId, const Style& style) {
    // Check if the styleId already exists in m_styles
    auto it = m_styles.find(styleId);
    
    if (it != m_styles.end()) {
        // If it exists, update the existing style
        *(it->second) = style;
    } else {
        // If it doesn't exist, create a new shared_ptr<Style> and add it to m_styles
        m_styles[styleId] = std::make_shared<Style>(style);
    }
}

std::shared_ptr<Style> StyleRepository::getStyle(const std::string& styleId) {
    // Check if the styleId exists in m_styles
    auto it = m_styles.find(styleId);
    
    if (it != m_styles.end()) {
        // If it exists, return the corresponding style
        return it->second;
    } else {
        // If it doesn't exist, return the default style
        return m_styles[DEFAULT_STYLE_ID];
    }
}

bool StyleRepository::removeStyle(const std::string& styleId) {
    // Check if the styleId exists in m_styles
    auto it = m_styles.find(styleId);
    
    if (it != m_styles.end() && styleId != DEFAULT_STYLE_ID) {
        // If it exists and is not the default style, remove it and return true
        m_styles.erase(it);
        return true;
    } else {
        // If it doesn't exist or is the default style, return false
        return false;
    }
}

void StyleRepository::clearStyles() {
    // Iterate through m_styles
    auto it = m_styles.begin();
    while (it != m_styles.end()) {
        if (it->first != DEFAULT_STYLE_ID) {
            // Remove all styles except the one with DEFAULT_STYLE_ID
            it = m_styles.erase(it);
        } else {
            ++it;
        }
    }
}

std::shared_ptr<Style> StyleRepository::getDefaultStyle() {
    // Return the style associated with DEFAULT_STYLE_ID from m_styles
    return m_styles[DEFAULT_STYLE_ID];
}