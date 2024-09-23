-- Up migration

-- Create users table
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    role ENUM('user', 'admin') NOT NULL DEFAULT 'user',
    INDEX idx_email (email),
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create workbooks table
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

-- Create worksheets table
CREATE TABLE worksheets (
    worksheet_id INT PRIMARY KEY AUTO_INCREMENT,
    workbook_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    `index` INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_visible BOOLEAN NOT NULL DEFAULT TRUE,
    row_count INT NOT NULL DEFAULT 1000,
    column_count INT NOT NULL DEFAULT 26,
    zoom_level DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    freeze_rows INT NOT NULL DEFAULT 0,
    freeze_columns INT NOT NULL DEFAULT 0,
    FOREIGN KEY (workbook_id) REFERENCES workbooks(workbook_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_workbook_id (workbook_id),
    UNIQUE INDEX idx_workbook_index (workbook_id, `index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create named_ranges table
CREATE TABLE named_ranges (
    range_id INT PRIMARY KEY AUTO_INCREMENT,
    worksheet_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    start_row INT NOT NULL,
    start_column INT NOT NULL,
    end_row INT NOT NULL,
    end_column INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (worksheet_id) REFERENCES worksheets(worksheet_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_worksheet_id (worksheet_id),
    UNIQUE INDEX idx_worksheet_name (worksheet_id, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create shared_workbooks table
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

-- Create versions table
CREATE TABLE versions (
    version_id INT PRIMARY KEY AUTO_INCREMENT,
    workbook_id INT NOT NULL,
    version_number INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL,
    change_summary TEXT NULL,
    storage_path VARCHAR(512) NOT NULL,
    file_size BIGINT NOT NULL DEFAULT 0,
    is_major_version BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (workbook_id) REFERENCES workbooks(workbook_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE INDEX idx_workbook_version (workbook_id, version_number),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Down migration

DROP TABLE IF EXISTS versions;
DROP TABLE IF EXISTS shared_workbooks;
DROP TABLE IF EXISTS named_ranges;
DROP TABLE IF EXISTS worksheets;
DROP TABLE IF EXISTS workbooks;
DROP TABLE IF EXISTS users;

-- Human tasks:
-- 1. Review and validate the initial schema to ensure all necessary tables and relationships are included
-- 2. Consider adding additional indexes for frequently queried columns to optimize performance
-- 3. Implement a mechanism for tracking and applying database migrations in the application
-- 4. Create corresponding data access layers (DAOs) or repositories for each table
-- 5. Develop a strategy for seeding initial data (e.g., admin user, default templates) after migration
-- 6. Consider implementing database-level triggers for maintaining audit trails or enforcing complex business rules
-- 7. Plan for future migrations to handle schema changes as the application evolves