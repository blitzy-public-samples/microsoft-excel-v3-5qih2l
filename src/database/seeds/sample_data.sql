-- Users
INSERT INTO users (username, email, password_hash, first_name, last_name, role) VALUES ('admin', 'admin@example.com', '$2a$10$XQq2o2UsFMcH/59hHo9.4.3RFyTjQTtVUDfRMxQBzcL.57vZa9Ife', 'Admin', 'User', 'admin');
INSERT INTO users (username, email, password_hash, first_name, last_name) VALUES ('user1', 'user1@example.com', '$2a$10$XQq2o2UsFMcH/59hHo9.4.3RFyTjQTtVUDfRMxQBzcL.57vZa9Ife', 'John', 'Doe');
INSERT INTO users (username, email, password_hash, first_name, last_name) VALUES ('user2', 'user2@example.com', '$2a$10$XQq2o2UsFMcH/59hHo9.4.3RFyTjQTtVUDfRMxQBzcL.57vZa9Ife', 'Jane', 'Smith');

-- Workbooks
INSERT INTO workbooks (user_id, name, description, storage_path) VALUES (1, 'Sample Workbook 1', 'A sample workbook for testing', '/storage/workbooks/sample1.xlsx');
INSERT INTO workbooks (user_id, name, description, storage_path) VALUES (2, 'Financial Report', 'Annual financial report template', '/storage/workbooks/financial_report.xlsx');
INSERT INTO workbooks (user_id, name, description, storage_path) VALUES (3, 'Project Timeline', 'Project management timeline template', '/storage/workbooks/project_timeline.xlsx');

-- Worksheets
INSERT INTO worksheets (workbook_id, name, `index`) VALUES (1, 'Sheet1', 0);
INSERT INTO worksheets (workbook_id, name, `index`) VALUES (1, 'Sheet2', 1);
INSERT INTO worksheets (workbook_id, name, `index`) VALUES (2, 'Income Statement', 0);
INSERT INTO worksheets (workbook_id, name, `index`) VALUES (2, 'Balance Sheet', 1);
INSERT INTO worksheets (workbook_id, name, `index`) VALUES (3, 'Gantt Chart', 0);
INSERT INTO worksheets (workbook_id, name, `index`) VALUES (3, 'Resource Allocation', 1);

-- Named Ranges
INSERT INTO named_ranges (worksheet_id, name, start_row, start_column, end_row, end_column) VALUES (3, 'IncomeTable', 1, 1, 10, 5);
INSERT INTO named_ranges (worksheet_id, name, start_row, start_column, end_row, end_column) VALUES (4, 'AssetsList', 1, 1, 20, 3);
INSERT INTO named_ranges (worksheet_id, name, start_row, start_column, end_row, end_column) VALUES (5, 'TaskList', 1, 1, 50, 4);

-- Shared Workbooks
INSERT INTO shared_workbooks (workbook_id, user_id, permission_level) VALUES (1, 2, 'editor');
INSERT INTO shared_workbooks (workbook_id, user_id, permission_level) VALUES (1, 3, 'viewer');
INSERT INTO shared_workbooks (workbook_id, user_id, permission_level) VALUES (2, 3, 'editor');

-- Versions
INSERT INTO versions (workbook_id, version_number, created_by, change_summary, storage_path, is_major_version) VALUES (1, 1, 1, 'Initial version', '/storage/versions/sample1_v1.xlsx', TRUE);
INSERT INTO versions (workbook_id, version_number, created_by, change_summary, storage_path) VALUES (2, 1, 2, 'Initial version', '/storage/versions/financial_report_v1.xlsx');
INSERT INTO versions (workbook_id, version_number, created_by, change_summary, storage_path) VALUES (3, 1, 3, 'Initial version', '/storage/versions/project_timeline_v1.xlsx');

-- Human Tasks:
-- TODO: Review and validate the sample data to ensure it covers a wide range of test scenarios
-- TODO: Add more diverse and realistic sample data for each table to better represent real-world usage
-- TODO: Implement a mechanism to easily reset the database to this initial state for testing purposes
-- TODO: Create sample data for the collaboration_sessions and change_history tables
-- TODO: Develop a strategy for generating larger datasets for performance testing
-- TODO: Consider adding sample data for different locales and languages to test internationalization
-- TODO: Implement a way to programmatically generate and insert more complex sample data (e.g., actual cell values, formulas) into the worksheets