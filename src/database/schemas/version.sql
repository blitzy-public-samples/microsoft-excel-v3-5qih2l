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