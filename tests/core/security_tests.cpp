#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "../../src/core/security/encryption.hpp"
#include "../../src/core/security/authentication.hpp"
#include "../../src/core/security/authorization.hpp"
#include "../../src/core/models/user.hpp"
#include "../../src/core/models/workbook.hpp"

class SecurityTest : public ::testing::Test {
protected:
    std::unique_ptr<Encryption> encryption;
    std::unique_ptr<Authentication> authentication;
    std::unique_ptr<Authorization> authorization;
    std::shared_ptr<User> testUser;
    std::shared_ptr<Workbook> testWorkbook;

    SecurityTest() {
        encryption = std::make_unique<Encryption>();
        authentication = std::make_unique<Authentication>();
        authorization = std::make_unique<Authorization>();
        testUser = std::make_shared<User>("testuser", "password123");
        testWorkbook = std::make_shared<Workbook>("TestWorkbook");
    }

    void SetUp() override {
        encryption->reset();
        authentication->reset();
        authorization->reset();
        testUser->resetState();
        testWorkbook->clear();
    }

    void TearDown() override {
        encryption->clearSensitiveData();
        authentication->clearSensitiveData();
        authorization->clearSensitiveData();
    }
};

TEST_F(SecurityTest, UserAuthentication) {
    EXPECT_TRUE(authentication->authenticate(testUser->getUsername(), "password123"));
    EXPECT_FALSE(authentication->authenticate(testUser->getUsername(), "wrongpassword"));
    EXPECT_FALSE(authentication->authenticate("nonexistentuser", "password123"));

    std::string storedHash = authentication->getStoredHash(testUser->getUsername());
    EXPECT_NE(storedHash, "password123");
}

TEST_F(SecurityTest, WorkbookEncryption) {
    std::string password = "secret123";
    std::string encryptedContent = encryption->encryptWorkbook(*testWorkbook, password);
    
    EXPECT_NE(encryptedContent, testWorkbook->serialize());
    
    auto decryptedWorkbook = encryption->decryptWorkbook(encryptedContent, password);
    EXPECT_EQ(decryptedWorkbook->serialize(), testWorkbook->serialize());
    
    EXPECT_THROW(encryption->decryptWorkbook(encryptedContent, "wrongpassword"), std::runtime_error);
}

TEST_F(SecurityTest, UserAuthorization) {
    authorization->setUserRole(testUser, UserRole::VIEWER);
    EXPECT_TRUE(authorization->canRead(testUser, testWorkbook));
    EXPECT_FALSE(authorization->canModify(testUser, testWorkbook));
    EXPECT_FALSE(authorization->canDelete(testUser, testWorkbook));

    authorization->setUserRole(testUser, UserRole::EDITOR);
    EXPECT_TRUE(authorization->canRead(testUser, testWorkbook));
    EXPECT_TRUE(authorization->canModify(testUser, testWorkbook));
    EXPECT_FALSE(authorization->canDelete(testUser, testWorkbook));

    authorization->setUserRole(testUser, UserRole::OWNER);
    EXPECT_TRUE(authorization->canRead(testUser, testWorkbook));
    EXPECT_TRUE(authorization->canModify(testUser, testWorkbook));
    EXPECT_TRUE(authorization->canDelete(testUser, testWorkbook));

    // Test worksheet-specific permissions
    auto worksheet = testWorkbook->getWorksheet(0);
    authorization->setWorksheetPermission(testUser, worksheet, WorksheetPermission::READ_ONLY);
    EXPECT_TRUE(authorization->canReadWorksheet(testUser, worksheet));
    EXPECT_FALSE(authorization->canModifyWorksheet(testUser, worksheet));
}

TEST_F(SecurityTest, InputSanitization) {
    std::string maliciousFormula = "=CMD(\'rm -rf /\')";
    std::string sanitizedFormula = encryption->sanitizeInput(maliciousFormula);
    EXPECT_NE(sanitizedFormula, maliciousFormula);
    EXPECT_FALSE(encryption->containsMaliciousContent(sanitizedFormula));

    std::string largeInput(1000000, 'A');  // 1 million 'A's
    EXPECT_NO_THROW(encryption->sanitizeInput(largeInput));

    std::string specialChars = "!@#$%^&*()_+{}|:\"<>?`-=[]\\;',./";
    std::string escapedChars = encryption->escapeSpecialCharacters(specialChars);
    EXPECT_NE(escapedChars, specialChars);
    EXPECT_TRUE(encryption->isProperlyEscaped(escapedChars));
}

// TODO: Implement tests for multi-factor authentication scenarios
// TODO: Add tests for secure communication protocols (e.g., TLS) when accessing remote resources
// TODO: Implement tests for audit logging of security-related events
// TODO: Add tests for handling and preventing common attack vectors (e.g., XSS, CSRF) in web-based scenarios
// TODO: Implement tests for secure storage and management of API keys and other secrets
// TODO: Add tests for compliance with data protection regulations (e.g., GDPR, CCPA)
// TODO: Implement penetration testing scenarios to identify potential security vulnerabilities