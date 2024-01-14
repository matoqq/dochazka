/* 
 * This script creates tables inside database.
 * The database has to be created first using the template in poorMansDbTemplate.zip 
 */

/* Delete tables if they exist before creating them */
DROP TABLE usersTb;
DROP TABLE departmentTb;
DROP TABLE departmentHierarchyTb;
DROP TABLE professionTb;
DROP TABLE attendanceTb;

/* Create tables */
CREATE TABLE usersTb (
    user_id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    name NVARCHAR(255) NOT NULL,
    email NVARCHAR(255) NOT NULL,
    password NVARCHAR(255) NOT NULL,
    password_salt NVARCHAR(255),
    titles NVARCHAR(255),
    position_type NVARCHAR(255),
    profession_id UNIQUEIDENTIFIER NOT NULL,
    department_id UNIQUEIDENTIFIER NOT NULL,
    created_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    updated_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
);
CREATE TABLE departmentTb (
    department_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
    department_en NVARCHAR(255),
    department_cz NVARCHAR(255)
);
CREATE TABLE departmentHierarchyTb (
    department_id UNIQUEIDENTIFIER NOT NULL,
    sub_department_id UNIQUEIDENTIFIER NOT NULL
);
CREATE TABLE professionTb (
    profession_id UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWID(),
    profession_en NVARCHAR(255),
    profession_cz NVARCHAR(255)
);
CREATE TABLE attendanceTb (
    entry_time DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    exit_time DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    note NVARCHAR(255) NOT NULL
);

/* Relations */
ALTER TABLE usersTb ADD FOREIGN KEY (department_id) REFERENCES departmentTb (department_id);
ALTER TABLE usersTb ADD FOREIGN KEY (profession_id) REFERENCES professionTb (profession_id);

ALTER TABLE departmentHierarchyTb ADD FOREIGN KEY (department_id) REFERENCES departmentTb (department_id);
ALTER TABLE departmentHierarchyTb ADD FOREIGN KEY (sub_department_id) REFERENCES departmentTb (department_id);

ALTER TABLE attendanceTb ADD FOREIGN KEY (user_id) REFERENCES usersTb (user_id);