/* 
 * This script creates tables inside database.
 * The database has to be created first using the template in poorMansDbTemplate.zip 
 */

/* Delete foreign keys relations and tables if they exist before creating them */
DECLARE @ConstraintName nvarchar(200)
DECLARE @TableName nvarchar(200)
DECLARE @SqlCommand nvarchar(1000)
DECLARE cursor_constraints CURSOR FOR 
    SELECT 
        fk.name AS FK_name, 
        t.name AS table_name
    FROM 
        sys.foreign_keys AS fk
    INNER JOIN 
        sys.tables AS t ON fk.parent_object_id = t.object_id
OPEN cursor_constraints
FETCH NEXT FROM cursor_constraints INTO @ConstraintName, @TableName
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SqlCommand = 'ALTER TABLE ' + @TableName + ' DROP CONSTRAINT ' + @ConstraintName
    EXEC sp_executesql @SqlCommand
    FETCH NEXT FROM cursor_constraints INTO @ConstraintName, @TableName
END
CLOSE cursor_constraints
DEALLOCATE cursor_constraints

IF EXISTS (SELECT * FROM sys.tables WHERE name = N'usersTb') DROP TABLE usersTb;
IF EXISTS (SELECT * FROM sys.tables WHERE name = N'departmentTb') DROP TABLE departmentTb;
IF EXISTS (SELECT * FROM sys.tables WHERE name = N'departmentHierarchyTb') DROP TABLE departmentHierarchyTb;
IF EXISTS (SELECT * FROM sys.tables WHERE name = N'professionTb') DROP TABLE professionTb;
IF EXISTS (SELECT * FROM sys.tables WHERE name = N'attendanceTb') DROP TABLE attendanceTb;

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
    department_id NVARCHAR(255) NOT NULL,
    created_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    updated_at DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
);
CREATE TABLE departmentTb (
    department_id NVARCHAR(255) PRIMARY KEY,
    department_en NVARCHAR(255) NOT NULL,
    department_cz NVARCHAR(255) NOT NULL
);
CREATE TABLE departmentHierarchyTb (
    department_id NVARCHAR(255) NOT NULL,
    sub_department_id NVARCHAR(255) NOT NULL
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