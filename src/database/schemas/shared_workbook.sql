CREATE TABLE shared_workbooks (
    share_id INT PRIMARY KEY AUTO_INCREMENT,
    workbook_id INT NOT NULL,
    user_id INT NOT NULL,
    permission_level ENUM('viewer', 'editor', 'owner') NOT NULL DEFAULT 'viewer',
    shared_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_accessed TIMESTAMP NULL,
    expiration_date TIMESTAMP NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (workbook_id) REFERENCES workbooks(workbook_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE INDEX idx_workbook_user (workbook_id, user_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Human tasks:
-- TODO: Review and validate the shared_workbook schema to ensure it meets all collaboration requirements
-- TODO: Implement a mechanism for efficiently managing and querying shared workbooks
-- TODO: Develop a strategy for handling conflicts when multiple users are editing the same workbook
-- TODO: Create corresponding API endpoints and services for managing shared workbooks
-- TODO: Implement a notification system for users when they are granted access to a shared workbook
-- TODO: Consider adding support for sharing workbooks with groups or teams
-- TODO: Implement an audit trail for tracking changes to sharing permissions