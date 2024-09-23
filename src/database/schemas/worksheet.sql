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