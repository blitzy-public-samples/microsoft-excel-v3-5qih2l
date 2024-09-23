CREATE TABLE workbooks (
    workbook_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_accessed TIMESTAMP NULL,
    is_template BOOLEAN NOT NULL DEFAULT FALSE,
    version INT NOT NULL DEFAULT 1,
    file_size BIGINT NOT NULL DEFAULT 0,
    storage_path VARCHAR(512) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_name (name),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Human tasks:
-- TODO: Review and validate the workbook schema to ensure it meets all application requirements
-- TODO: Consider adding a column for workbook sharing settings or permissions
-- TODO: Implement a versioning system for workbooks to support undo/redo functionality
-- TODO: Develop a strategy for efficient storage and retrieval of large workbooks
-- TODO: Create corresponding API endpoints and services for workbook management
-- TODO: Implement a backup and recovery system for workbooks
-- TODO: Consider adding support for workbook categories or tags for better organization