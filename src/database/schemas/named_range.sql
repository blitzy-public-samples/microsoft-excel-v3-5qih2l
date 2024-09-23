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