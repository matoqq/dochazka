/* 
 * This script creates tables inside database.
 * Then it fills the db with data (user_id and userName are obfuscated)
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
    user_id INT PRIMARY KEY NOT NULL CONSTRAINT CHK_user_id CHECK (user_id >= 0),
    name NVARCHAR(255) NOT NULL,
    email NVARCHAR(255) NOT NULL,
    password NVARCHAR(255) NOT NULL,
    password_salt NVARCHAR(255) NOT NULL,
    position_type INT CONSTRAINT CHK_position_type CHECK (position_type >= 0 AND position_type <= 3),
    titles NVARCHAR(255),
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
    user_id INT NOT NULL,
    note NVARCHAR(255) NOT NULL
);

/* Relations */
ALTER TABLE usersTb ADD FOREIGN KEY (department_id) REFERENCES departmentTb (department_id);
ALTER TABLE usersTb ADD FOREIGN KEY (profession_id) REFERENCES professionTb (profession_id);

ALTER TABLE departmentHierarchyTb ADD FOREIGN KEY (department_id) REFERENCES departmentTb (department_id);
ALTER TABLE departmentHierarchyTb ADD FOREIGN KEY (sub_department_id) REFERENCES departmentTb (department_id);

ALTER TABLE attendanceTb ADD FOREIGN KEY (user_id) REFERENCES usersTb (user_id);


/* INSERTING DATA INTO TABLES*/


/* Create departments  */
INSERT INTO departmentTb (department_id, department_en, department_cz) VALUES
('5610', 'Institute of Technology and Business in České Budějovice', 'Vysoká škola technická a ekonomická v Českých Budějovicích'),
('561010', 'Rector', 'Rektor'),
('56101010', 'Vice-Rector for Study Affairs', 'Prorektor pro studium'),
('5610101050', 'Directorate of Study Administration and Lifelong Learning', 'Útvar ředitele pro administraci studia a celoživotní vzdělávání'),
('561010105010', 'Study Department', 'Studijní oddělení'),
('561010105020', 'Barrier-free Centrum', 'Bezbariérové centrum'),
('561010105030', 'Lifelong learning Centre', 'Centrum celoživotního vzdělávání'),
('561010105040', 'University of the Third Age', 'Univerzita třetího věku'),
('561010105050', 'Department of Strategy', 'Rozvojové oddělení'),
('56101020', 'Internal Auditor', 'Interní auditor'),
('56101030', 'Training center', 'Centrum odborné přípravy'),
('56101031', 'Vice-Rector - The Statutory Deputy of the Rector', 'Prorektor - statutární zástupce rektora'),
('56101034', 'Faculty of Corporate Strategy', 'Ústav podnikové strategie'),
('5610103420', 'Department of Human Resource Management', 'Katedra řízení lidských zdrojů'),
('5610103421', 'Department of Management', 'Katedra managementu'),
('5610103430', 'Institute Administration', 'Správa ústavu ÚPS'),
('5610103450', 'Deputy Director of Department for Research, Development and Creative Activity', 'Oddělení zástupce ředitele pro výzkum, vývoj a tvůrčí činnost'),
('5610103460', 'Centre of language services', 'Centrum jazykových služeb'),
('5610103480', 'Department of Tourism and Marketing', 'Katedra cestovního ruchu a marketingu'),
('56101037', 'Bursar''s Department', 'Útvar kvestora'),
('5610103708', 'Economic and operating section', 'Hospodářsko-provozní úsek'),
('561010370820', 'Library', 'Knihovna'),
('561010370830', 'Copycenter', 'Copycentrum'),
('561010370850', 'Operations Department', 'Oddělení provozně-technické'),
('561010370860', 'Refectory', 'Menza'),
('5610103780', 'Department of Project Work', 'Oddělení projektových prací'),
('5610103790', 'Economic Department', 'Ekonomický úsek'),
('56101038', 'Faculty of Technology', 'Ústav technicko-technologický'),
('5610103820', 'Department of Transport and Logistics', 'Katedra dopravy a logistiky'),
('5610103830', 'Department of Civil Engineering', 'Katedra stavebnictví'),
('5610103840', 'The Department of Mechanical Engineering', 'Katedra strojírenství'),
('5610103850', 'Department of Informatics and Natural Sciences', 'Katedra informatiky a přírodních věd'),
('5610103860', 'Institute Administration', 'Správa ústavu ÚTT'),
('5610103880', 'Deputy Director of Department for Research, Development and Creative Activity', 'Oddělení zástupce ředitele pro výzkum, vývoj a tvůrčí činnost'),
('5610103890', 'Jikord, Ltd. - Common workplace', 'Jikord, s.r.o. – společné pracoviště'),
('56101039', 'School of Expertness and Valuation', 'Ústav znalectví a oceňování'),
('5610103910', 'Institute Administration', 'Správa ústavu ÚZO'),
('5610103920', 'Deputy Director Department for Expertise activity', 'Oddělení zástupce ředitele pro znaleckou činnost'),
('5610103930', 'Deputy Director of Department for Research, Development and Creative Activity', 'Oddělení zástupce ředitele pro výzkum, vývoj a tvůrčí činnost'),
('561010393010', 'Department of Corporate Finances', 'Skupina Finance podniku'),
('561010393020', 'Economics Group', 'Skupina Ekonomie'),
('561010393030', 'Law Group', 'Skupina Právo'),
('561010393040', 'Business Economics Group', 'Skupina Podniková ekonomika'),
('561010393050', 'Property Valuation Group', 'Skupina Oceňování nemovitostí'),
('561010393060', 'Technical expertise Group', 'Skupina Technické znalectví'),
('5610103960', 'Department of Support for Project and Expertise Activity', 'Oddělení podpory projektové a znalecké činnosti'),
('56101040', 'Vice-Rector for Informatics and Project Activities', 'Prorektor pro informatiku a projektovou činnost'),
('5610104010', 'Division of Informatics', 'Úsek informatiky'),
('56101050', 'Ombudsman', 'Ombudsman'),
('56101060', 'Legal Department', 'Právní oddělení'),
('56101070', 'Division of External Relations', 'Úsek vnějších vztahů'),
('5610107010', 'Department of Foreign Relations', 'Oddělení zahraničních vztahů'),
('5610107020', 'Marketing Department', 'Marketingové oddělení'),
('5610107030', 'Confucius Class', 'Konfuciova třída'),
('56101080', 'Vice-Rector for Creative Activities', 'Prorektor pro tvůrčí činnost'),
('5610108055', 'Environmental Research Department', 'Environmentální výzkumné pracoviště'),
('56101090', 'Rector''s office', 'Sekretariát rektora');

/* Create departments  */
INSERT INTO departmentHierarchyTb (department_id, sub_department_id) VALUES
('5610', '561010'),
('561010', '56101010'),
('561010', '5610101050'),
('561010', '56101020'),
('561010', '56101030'),
('561010', '56101031'),
('561010', '56101034'),
('561010', '56101037'),
('561010', '56101038'),
('561010', '56101039'),
('561010', '56101040'),
('561010', '56101050'),
('561010', '56101060'),
('561010', '56101070'),
('561010', '56101080'),
('561010', '56101090'),
('5610101050', '561010105010'),
('5610101050', '561010105020'),
('5610101050', '561010105030'),
('5610101050', '561010105040'),
('5610101050', '561010105050'),
('56101034', '5610103420'),
('56101034', '5610103421'),
('56101034', '5610103430'),
('56101034', '5610103450'),
('56101034', '5610103460'),
('56101034', '5610103480'),
('56101037', '5610103708'),
('56101037', '5610103780'),
('56101037', '5610103790'),
('56101038', '5610103820'),
('56101038', '5610103830'),
('56101038', '5610103840'),
('56101038', '5610103850'),
('56101038', '5610103860'),
('56101038', '5610103880'),
('56101038', '5610103890'),
('56101039', '5610103910'),
('56101039', '5610103920'),
('56101039', '5610103930'),
('56101039', '5610103960'),
('56101040', '5610104010'),
('56101070', '5610107010'),
('56101070', '5610107020'),
('56101070', '5610107030'),
('56101080', '5610108055'),
('5610103708', '561010370820'),
('5610103708', '561010370830'),
('5610103708', '561010370850'),
('5610103708', '561010370860'),
('5610103930', '561010393010'),
('5610103930', '561010393020'),
('5610103930', '561010393030'),
('5610103930', '561010393040'),
('5610103930', '561010393050'),
('5610103930', '561010393060');


/* inserting data into professionTb */
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Rektror', 'internal auditor')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('interní auditor', 'Rector')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Vedoucí Studijního oddělení', 'Head of the Study Department')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent studijního oddělení', 'study department officer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent rozvojového oddělení', 'clerk of the development department')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('ředitel Útvaru pro administraci studia a celoživotní vzdělávání', 'director of the Department for study administration and lifelong learning')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('metodik výuky', 'teaching methods')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Prorektor pro strategii a rozvoj, Zástupce vedoucího Katedry managementu, docent', 'Vice-Rector for Strategy and Development, Deputy Head of the Department of Management, Associate Professor')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Vedoucí Centra odborné přípravy', 'Head of the Vocational Training Center')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('svářeč', 'welder')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent Centra odborné přípravy', 'officer of the Vocational Training Center')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('brusič', 'grinder')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('obsluha strojů', 'machine operation')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Akademický pracovník - odborný asistent', 'Academic worker - assistant professor')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('docent', 'associate professor')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('akademický pracovník - docent', 'academic worker - docent')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Akademický pracovník - asistent', 'Academic worker - assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('odborný asistent', 'Assistant Professor')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('asistent', 'assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('vědecký asistent', 'research assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('profesor', 'professor')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('asistentka ústavu', 'institute assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Tajemník ústavu', 'Secretary of the Institute')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent pro rozvojovou činnost', 'officer for development activities')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('lektor', 'lecturer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('akademický pracovník - lektor', 'academic worker - lecturer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('vedoucí katedry - docent', 'head of the department - docent')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('pomocný pracovník menzy', 'canteen assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('pracovnice kantýny', 'canteen worker')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('kuchař', 'cook')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('hlavní kuchař', 'head chef')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('uklízečka', 'cleaning woman')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('údržbář', 'maintenance worker')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent Provozně-technického oddělení', 'clerk of the Operational and Technical Department')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent výpůjčních služeb', 'loan services officer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent Oddělení projektových prací', 'clerk of the Department of Project Works')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('mateřská a následná rodičovská dovolená', 'maternity and subsequent parental leave')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('recepční', 'receptionist')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Finanční účetní', 'Financial accountant II.')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent podatelny a recepce', 'office clerk and reception')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent majetku', 'property officer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('mzdová účetní', 'payroll clerk')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('hlavní referent podatelny a recepce', 'main office clerk and reception')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Personalista', 'HR')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent nákupu', 'Purchase Officer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('zástupce ředitele ústavu pro výzkum, vývoj a tvůrčí činnost', 'deputy director of the Institute for Research, Development and Creative Activity')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('odborný vědecký pracovník', 'expert scientist')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('odborný asistent, Zástupce vedoucího Katedry dopravy a logistiky', 'assistant professor, Deputy Head of the Department of Transport and Logistics')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('samostatný vědecký pracovník', 'independent researcher')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('asistent; zástupce vedoucího katedry stavebnictví', 'assistant; Deputy Head of the Department of Civil Engineering')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('odborný asistent, Zástupce vedoucí Katedry strojírenství', 'assistant professor, Deputy Head of the Department of Engineering')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('vědecký asistent, zástupce vedoucího Katedry informatiky a přírodních věd', 'research assistant, deputy head of the Department of Informatics and Natural Sciences')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Zástupce ředitele pro znaleckou činnost', 'Deputy director for expertise')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Referent OZŘ pro VVTČ', 'OZŘ officer for VVTČ')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Vedoucí skupiny Oceňování podniku', 'Head of the Business Valuation group')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('asistent znalecké činnosti', 'expert activity assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Výuka a vzdělávací činnosti', 'Teaching and educational activities')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('vedoucí Skupiny Právo', 'head of the Law Group')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Vedoucí skupiny Podniková ekonomika - akademický pracovník - asistent', 'Head of the Business Economics group - academic worker - assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('vyšší kvalifikovaný pracovník', 'higher qualified worker')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Vedoucí skupiny Oceňování nemovitostí, asistent', 'Real Estate Appraisal group leader, assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Vedoucí Skupiny Technické znalectví, vědecký asistent', 'Head of the Technical Expertise Group, scientific assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent oddělení podpory projektové a znalecké činnosti', 'officer of the support department for project and expert activities')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Hons referent oddělení podpory projektové a znalecké činnosti', 'Hons referent of the support department for project and expert activities')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Externista', 'Externalist')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('IT technik', 'IT technician')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Asistentka IT', 'IT assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Prorektor pro studium a informatiku', 'Vice Chancellor for Studies and Informatics')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent právního oddělení', 'clerk of the legal department')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Referent praxe a kariérního centra', 'Practice and career center officer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('marketingový specialista', 'marketing specialist')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Referent PR', 'PR officer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Referent analytik', 'Associate analyst')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Referent komunikace', 'Communication officer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent marketingu', 'marketing officer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Administrativní pracovník', 'Office worker')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('koordinátor zahraničních vztahů', 'foreign relations coordinator')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('referent zahraničních vztahů', 'foreign relations officer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Referent pro výzkum, vývoj a tvůrčí činnost', 'Officer for research, development and creative activity')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Referentka pro projektovou činnost', 'Officer for project activities')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('Asistentka oddělení', 'Department assistant')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('pracovník na projektech', 'project worker')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('řidič - referent autoprovozu', 'driver - traffic officer')
INSERT INTO professionTb (profession_cz, profession_en) VALUES ('asistentka rektora', 'rector''s assistant')

/* Create users */
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63830, 'Mary Thomas', '', 'password001', 'salt001', 1, '', profession_id, '5610108055' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 23562, 'Jenna Armstrong', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35746, 'Yvonne Evans', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='main office clerk and reception'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64081, 'Patricia Parsons', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63984, 'Michael Scott MD', '', 'password001', 'salt001', 1, 'doc. PhDr. Ph.D.', profession_id, '5610103420' FROM professionTb WHERE profession_en='academic worker - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 26119, 'Tabitha Martin', '', 'password001', 'salt001', 1, 'Ing. Bc. Ph.D.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 84200, 'Andrew Hudson', '', 'password001', 'salt001', 0, 'Ing. doc. CSc.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 21336, 'Kathleen Chapman', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 17208, 'Dana Summers', '', 'password001', 'salt001', 1, 'Mgr. et Mgr.', profession_id, '5610107010' FROM professionTb WHERE profession_en='Officer for project activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15767, 'Sheri Chapman', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '56101060' FROM professionTb WHERE profession_en='PR officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 21892, 'Wendy Campbell', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '561010105010' FROM professionTb WHERE profession_en='study department officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 93461, 'Elizabeth Deleon', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610107010' FROM professionTb WHERE profession_en='Officer for project activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 45068, 'Jennifer Martinez', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 83731, 'Travis Houston', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610108055' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94148, 'Judith Smith', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15756, 'Jim Villarreal', '', 'password001', 'salt001', 1, 'Mgr. Ph.D.', profession_id, '561010393030' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94584, 'Barry James', '', 'password001', 'salt001', 1, 'Mgr. PhD.', profession_id, '5610108055' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64910, 'Nicole Jones', '', 'password001', 'salt001', 1, '', profession_id, '56101080' FROM professionTb WHERE profession_en='project worker'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74296, 'Richard Phillips', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010370820' FROM professionTb WHERE profession_en='maternity and subsequent parental leave'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 43731, 'Rachel Perez DVM', '', 'password001', 'salt001', 1, 'Bc. DiS.', profession_id, '56101037' FROM professionTb WHERE profession_en='assistant professor, Deputy Head of the Department of Transport and Logistics'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34620, 'Aaron Decker', '', 'password001', 'salt001', 1, 'Ing.  Mgr. et Mgr.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Academic worker - assistant professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34699, 'Erica Miles', '', 'password001', 'salt001', 2, 'Mgr.', profession_id, '561010370820' FROM professionTb WHERE profession_en='maternity and subsequent parental leave'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14116, 'Maria Jimenez', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 4383, 'Michael Morrison', '', 'password001', 'salt001', 0, 'Ing. Ph.D. MBA', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24504, 'Melissa Marshall', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103840' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 20984, 'Carrie Brown', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '561010105030' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35946, 'Amber Sherman', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14115, 'Monica Barron', '', 'password001', 'salt001', 1, 'RNDr. Ph.D.', profession_id, '5610103850' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16177, 'Danny Irwin', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103421' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63600, 'Nicholas Mcintosh', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='head of the department - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24518, 'Thomas Harvey', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393010' FROM professionTb WHERE profession_en='Teaching and educational activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 36153, 'James Montgomery', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393050' FROM professionTb WHERE profession_en='Head of the Business Economics group - academic worker - assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 83628, 'Steven Brown', '', 'password001', 'salt001', 0, 'Mgr. Ph.D.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74502, 'David Cooper', '', 'password001', 'salt001', 0, '', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25110, 'Dave Hanson', '', 'password001', 'salt001', 2, 'Ing.', profession_id, '56101060' FROM professionTb WHERE profession_en='marketing specialist'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15226, 'Lauren Huffman', '', 'password001', 'salt001', 1, 'Bc. DiS.', profession_id, '5610104010' FROM professionTb WHERE profession_en='Vice Chancellor for Studies and Informatics'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 26120, 'Kristina Lucas', '', 'password001', 'salt001', 1, 'Ph.D.', profession_id, '5610103421' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 43467, 'Erica Mejia', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94576, 'Jackie Hicks MD', '', 'password001', 'salt001', 1, 'Mgr. Ph.D.', profession_id, '5610103920' FROM professionTb WHERE profession_en='Teaching and educational activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 83733, 'Nancy Greene', '', 'password001', 'salt001', 1, 'DiS.', profession_id, '5610103860' FROM professionTb WHERE profession_en='independent researcher'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63697, 'Jesus Armstrong', '', 'password001', 'salt001', 0, 'PaedDr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15663, 'Sarah Guerrero', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393050' FROM professionTb WHERE profession_en='Hons referent of the support department for project and expert activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15992, 'Daniel Crawford', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 18915, 'Pamela Simmons', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44564, 'Robert Mathis', '', 'password001', 'salt001', 0, 'Ing. doc. CSc.', profession_id, '56101034' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 20789, 'Matthew Taylor', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='expert scientist'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 95070, 'Nicole Brooks', '', 'password001', 'salt001', 1, 'doc. JUDr. PhD.', profession_id, '561010393030' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 13818, 'Samuel Graham', '', 'password001', 'salt001', 1, '', profession_id, '561010370860' FROM professionTb WHERE profession_en='cook'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44756, 'Cory Stewart', '', 'password001', 'salt001', 1, 'Ing. prof. Ph.D.', profession_id, '5610108055' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14700, 'Debbie Franklin', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 93453, 'Lisa Walker', '', 'password001', 'salt001', 1, '', profession_id, '5610104010' FROM professionTb WHERE profession_en='clerk of the legal department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3906, 'Elizabeth Gibson', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '561010393020' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25587, 'James Romero', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '561010393040' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16002, 'Eugene Cooper', '', 'password001', 'salt001', 0, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 75300, 'Larry Krause', '', 'password001', 'salt001', 1, 'doc. PhDr. PhD.', profession_id, '5610103420' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 26322, 'Jonathan Wilson', '', 'password001', 'salt001', 1, 'MSc', profession_id, '5610103460' FROM professionTb WHERE profession_en='academic worker - lecturer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 13612, 'Mary Jones', '', 'password001', 'salt001', 0, 'Bc. Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 4320, 'Joshua Olson', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103820' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24803, 'Paul Owens', '', 'password001', 'salt001', 3, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='receptionist'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 46286, 'Joshua Jimenez', '', 'password001', 'salt001', 1, '', profession_id, '561010393020' FROM professionTb WHERE profession_en='Academic worker - assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74478, 'Stephanie Neal', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63976, 'Erica Mccormick', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94467, 'Ronald Summers', '', 'password001', 'salt001', 1, 'Ing. prof. CSc.', profession_id, '5610103840' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54012, 'Emily Finley', '', 'password001', 'salt001', 1, 'Ing. prof. CSc.', profession_id, '5610103830' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 95072, 'Jennifer Barrett', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Academic worker - assistant professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64804, 'Javier Rogers', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393050' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 85181, 'Megan Arnold', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103780' FROM professionTb WHERE profession_en='receptionist'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55256, 'Charles Leblanc', '', 'password001', 'salt001', 1, 'RNDr.', profession_id, '561010105030' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64077, 'Karen Lewis', '', 'password001', 'salt001', 1, 'Ing. PhD.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Academic worker - assistant professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15670, 'Sherry Kaiser', '', 'password001', 'salt001', 1, '', profession_id, '56101039' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 5013, 'Lori Payne', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610101050' FROM professionTb WHERE profession_en='teaching methods'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35034, 'Danielle Wiley', '', 'password001', 'salt001', 1, 'RNDr. Ph.D.', profession_id, '5610103850' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16275, 'Jeremy Olson', '', 'password001', 'salt001', 1, 'Ing. doc. Ph.D.', profession_id, '5610108055' FROM professionTb WHERE profession_en='research assistant, deputy head of the Department of Informatics and Natural Sciences'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 45421, 'Cory Manning', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103430' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 22176, 'Amy Wiley', '', 'password001', 'salt001', 1, 'Ing. PhD. MBA', profession_id, '561010393040' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54084, 'Gabriela Morgan', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '56101030' FROM professionTb WHERE profession_en='officer of the Vocational Training Center'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64919, 'Stephanie Dennis', '', 'password001', 'salt001', 1, 'Ing. doc. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='research assistant, deputy head of the Department of Informatics and Natural Sciences'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 4310, 'Benjamin Thomas', '', 'password001', 'salt001', 0, 'PhDr. Ph.D.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44061, 'Russell Houston', '', 'password001', 'salt001', 1, '', profession_id, '5610104010' FROM professionTb WHERE profession_en='Vice Chancellor for Studies and Informatics'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 73398, 'Andrew Gomez PhD', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610107020' FROM professionTb WHERE profession_en='foreign relations coordinator'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25180, 'Sally Clark', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 95069, 'Brooke Villarreal', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74410, 'Wanda Macdonald', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='assistant; Deputy Head of the Department of Civil Engineering'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 46309, 'Kathleen Day', '', 'password001', 'salt001', 1, 'JUDr. Ph.D.', profession_id, '561010393030' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34701, 'Heidi Ward', '', 'password001', 'salt001', 1, 'Ing. doc. MBA CSc.', profession_id, '5610103830' FROM professionTb WHERE profession_en='academic worker - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15672, 'Amy Garcia', '', 'password001', 'salt001', 1, 'PhDr. JUDr. Ph.D.', profession_id, '561010393030' FROM professionTb WHERE profession_en='higher qualified worker'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3618, 'Heather Holden', '', 'password001', 'salt001', 1, 'Ing. prof. DrSc., dr. h.c. ', profession_id, '561010393050' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14303, 'Theresa Gordon', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103820' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 45423, 'Daniel Carter', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103430' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16200, 'Susan Andersen', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54624, 'Kimberly Kelly', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610108055' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24702, 'Jeffery West', '', 'password001', 'salt001', 1, 'Ing. doc. PhDr. CSc.', profession_id, '5610103420' FROM professionTb WHERE profession_en='academic worker - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54368, 'Scott Stewart', '', 'password001', 'salt001', 2, 'Ing. prof. Ph.D.', profession_id, '5610103840' FROM professionTb WHERE profession_en='officer for development activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34648, 'Melissa David', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '56101030' FROM professionTb WHERE profession_en='machine operation'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 12817, 'William Gardner', '', 'password001', 'salt001', 2, 'Ing. prof. CSc.', profession_id, '5610103421' FROM professionTb WHERE profession_en='academic worker - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 17968, 'Calvin Butler', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610107020' FROM professionTb WHERE profession_en='Associate analyst'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3702, 'Richard Gonzalez', '', 'password001', 'salt001', 1, 'Ing. MBA', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24402, 'Troy Harris', '', 'password001', 'salt001', 1, 'Mgr. Ph.D.', profession_id, '5610101050' FROM professionTb WHERE profession_en='teaching methods'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74703, 'Brian Jones', '', 'password001', 'salt001', 1, 'Ing. Bc. Ph.D.', profession_id, '5610108055' FROM professionTb WHERE profession_en='assistant; Deputy Head of the Department of Civil Engineering'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54518, 'Corey Davis', '', 'password001', 'salt001', 1, '', profession_id, '561010370860' FROM professionTb WHERE profession_en='cook'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15967, 'Michael Robinson', '', 'password001', 'salt001', 0, 'Ing. Ph.D.', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 12754, 'Jared Hall', '', 'password001', 'salt001', 1, 'Ing. doc. Ph.D.', profession_id, '56101010' FROM professionTb WHERE profession_en='Vice-Rector for Strategy and Development, Deputy Head of the Department of Management, Associate Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54735, 'Craig Ferguson', '', 'password001', 'salt001', 0, 'Ing. arch.  Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 43345, 'Martin Randolph', '', 'password001', 'salt001', 0, 'Ing. arch.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 13521, 'Jordan Bates', '', 'password001', 'salt001', 2, 'Ing. PhD. MBA', profession_id, '5610103960' FROM professionTb WHERE profession_en='IT assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14016, 'Vincent Hernandez', '', 'password001', 'salt001', 1, 'Ing. PhD. MBA', profession_id, '561010393050' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 84329, 'Aaron Odonnell', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103421' FROM professionTb WHERE profession_en='research assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 20138, 'Mrs. Sara Smith MD', '', 'password001', 'salt001', 0, 'RNDr.', profession_id, '5610103850' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 85276, 'Renee Morgan', '', 'password001', 'salt001', 1, '', profession_id, '561010370850' FROM professionTb WHERE profession_en='loan services officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74700, 'Linda Hoover', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 20778, 'Ruben Moore', 'stanek@mail.vstecb.cz', 'password001', 'salt001', 1, 'Ing. DiS.', profession_id, '56101020' FROM professionTb WHERE profession_en='Rector'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 33826, 'Cory Clark', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010105010' FROM professionTb WHERE profession_en='study department officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 43966, 'Paula Ritter', '', 'password001', 'salt001', 1, 'Ing. doc. CSc.', profession_id, '5610103830' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 83518, 'Jonathan Wong', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64292, 'Hannah Estrada', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='academic worker - lecturer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55122, 'Keith Campbell', '', 'password001', 'salt001', 1, 'Ing. doc. CSc.', profession_id, '5610103840' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16178, 'Andrea Jordan', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Purchase Officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25629, 'Brenda Dillon', '', 'password001', 'salt001', 1, '', profession_id, '5610103790' FROM professionTb WHERE profession_en='main office clerk and reception'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 83519, 'Shelley Ferguson', '', 'password001', 'salt001', 1, 'Ing. Bc. Ph.D.', profession_id, '5610103820' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 13410, 'Rachael Griffin', '', 'password001', 'salt001', 1, 'Ing. CSc.', profession_id, '5610103850' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44659, 'Brian Ortega', '', 'password001', 'salt001', 1, 'RNDr.', profession_id, '561010105030' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55224, 'Ray Pace', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393040' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44457, 'Jason Burch', '', 'password001', 'salt001', 1, '', profession_id, '5610103790' FROM professionTb WHERE profession_en='office clerk and reception'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 26237, 'Nicole Jones', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610104010' FROM professionTb WHERE profession_en='Vice Chancellor for Studies and Informatics'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 4214, 'Katherine Warner', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '561010393010' FROM professionTb WHERE profession_en='IT assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15964, 'Laura White', '', 'password001', 'salt001', 1, '', profession_id, '561010370850' FROM professionTb WHERE profession_en='loan services officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35957, 'Daniel Ward', '', 'password001', 'salt001', 1, '', profession_id, '56101030' FROM professionTb WHERE profession_en='machine operation'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 13617, 'Jason Murphy', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103850' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 17974, 'Stephen Johnson', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64104, 'Abigail Turner', '', 'password001', 'salt001', 1, 'Ing. doc. Ph.D.', profession_id, '5610108055' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 43348, 'Tyler Webster', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55120, 'Adam Love', '', 'password001', 'salt001', 1, '', profession_id, '56101030' FROM professionTb WHERE profession_en='welder'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34188, 'Reginald Johns', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103850' FROM professionTb WHERE profession_en='Head of the Business Valuation group'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 43346, 'Jennifer Brewer', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 53531, 'Tamara Schultz', '', 'password001', 'salt001', 1, 'Ing. doc. PhD.', profession_id, '5610103820' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25183, 'Ms. Morgan Simpson', '', 'password001', 'salt001', 1, 'Ing. PhD.', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 95065, 'Tracy Campbell', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610108055' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 33937, 'Joshua Russo', '', 'password001', 'salt001', 1, 'Ing. Bc. Ph.D.', profession_id, '5610103850' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 4605, 'Frank Booth', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393050' FROM professionTb WHERE profession_en='Head of the Business Economics group - academic worker - assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 4382, 'Douglas Lopez', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103840' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44760, 'Robert Dickson', '', 'password001', 'salt001', 1, 'Ing. doc. Ph.D. MBA', profession_id, '56101080' FROM professionTb WHERE profession_en='Officer for project activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55103, 'Christopher Morales', '', 'password001', 'salt001', 1, 'Ing. Ph.D. MBA', profession_id, '5610103850' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 13409, 'Kimberly Leonard', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='head of the department - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 93479, 'Gina Hernandez', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610107020' FROM professionTb WHERE profession_en='Communication officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34373, 'Adrian Howe', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010105010' FROM professionTb WHERE profession_en='study department officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 13300, 'Michael Sheppard', '', 'password001', 'salt001', 2, 'Ing.', profession_id, '56101060' FROM professionTb WHERE profession_en='PR officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44660, 'Alexis Thompson', '', 'password001', 'salt001', 1, 'Bc. DiS.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 46152, 'Kyle Hooper', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103780' FROM professionTb WHERE profession_en='receptionist'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15861, 'Steven Mendoza', '', 'password001', 'salt001', 1, 'MgA.', profession_id, '5610107020' FROM professionTb WHERE profession_en='marketing officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25775, 'Lisa Wagner', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '561010393010' FROM professionTb WHERE profession_en='IT assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15286, 'Melody Chan DDS', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 12787, 'Robert Moore', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393010' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64741, 'Spencer Allen', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103420' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15048, 'Robert Castaneda', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393040' FROM professionTb WHERE profession_en='Academic worker - assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3596, 'Russell Anderson', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25291, 'Hunter Jones', '', 'password001', 'salt001', 1, 'doc. MUDr. Ph.D.', profession_id, '561010105030' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44851, 'Erin Gomez DDS', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103850' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14317, 'Gary Sanders', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103820' FROM professionTb WHERE profession_en='assistant; Deputy Head of the Department of Civil Engineering'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34857, 'Kathleen Davis', '', 'password001', 'salt001', 1, 'Ing. prof. DrSc. ', profession_id, '5610108055' FROM professionTb WHERE profession_en='research assistant, deputy head of the Department of Informatics and Natural Sciences'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 4211, 'Brandon Osborne', '', 'password001', 'salt001', 1, '', profession_id, '56101030' FROM professionTb WHERE profession_en='grinder'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 12830, 'Ryan Guerra', '', 'password001', 'salt001', 0, 'Ing. doc. Ph.D.', profession_id, '5610103421' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44761, 'Rachel Nelson', '', 'password001', 'salt001', 2, 'Ing. doc. Ph.D. MBA', profession_id, '5610108055' FROM professionTb WHERE profession_en='driver - traffic officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15039, 'Bryan Jordan', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='property officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 73578, 'Karen Solis', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 83914, 'Mary Bishop', '', 'password001', 'salt001', 1, 'Ing. doc. PhD.', profession_id, '5610103820' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 75120, 'Amy Watkins', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='main office clerk and reception'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44456, 'James Brewer', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103430' FROM professionTb WHERE profession_en='Secretary of the Institute'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35454, 'Vincent Young', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393010' FROM professionTb WHERE profession_en='Head of the Business Economics group - academic worker - assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63597, 'Steven Keller', '', 'password001', 'salt001', 2, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='lecturer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 83863, 'Edwin Davis', '', 'password001', 'salt001', 2, 'Bc.', profession_id, '5610103780' FROM professionTb WHERE profession_en='receptionist'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14837, 'David Martin', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '561010105010' FROM professionTb WHERE profession_en='study department officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14022, 'Cynthia Shaffer', '', 'password001', 'salt001', 1, 'Dr. Ing. doc.', profession_id, '5610103830' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25542, 'Richard Tate', '', 'password001', 'salt001', 1, 'Ing. prof. CSc.', profession_id, '561010393010' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94973, 'Andrea Martinez', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610108055' FROM professionTb WHERE profession_en='assistant; Deputy Head of the Department of Civil Engineering'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94466, 'Jillian Levy', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '561010105010' FROM professionTb WHERE profession_en='study department officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64131, 'Jordan Knight', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 20910, 'Michael Russo', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24191, 'Janet Hernandez', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 13773, 'Mary Mendez', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24260, 'Todd Miller', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 75003, 'Ryan Wright', '', 'password001', 'salt001', 1, 'Dr.', profession_id, '5610103850' FROM professionTb WHERE profession_en='assistant; Deputy Head of the Department of Civil Engineering'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35286, 'Dale Chandler', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 43558, 'Hunter White', '', 'password001', 'salt001', 0, 'PhDr.', profession_id, '5610103430' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64917, 'Michelle Martinez', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='assistant; Deputy Head of the Department of Civil Engineering'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74704, 'Vincent Gonzalez', '', 'password001', 'salt001', 1, 'Bc. MBA', profession_id, '5610107010' FROM professionTb WHERE profession_en='Officer for project activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 26176, 'Fernando Fuller', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393010' FROM professionTb WHERE profession_en='Academic worker - assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74554, 'Brittney Rivers', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 12816, 'Ashley Mendoza', '', 'password001', 'salt001', 1, 'Ing. prof. Ph.D. MBA dr. h.c. ', profession_id, '5610103910' FROM professionTb WHERE profession_en='expert activity assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74803, 'Richard Snyder', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74798, 'Jeffery Brennan', '', 'password001', 'salt001', 1, '', profession_id, '561010370850' FROM professionTb WHERE profession_en='clerk of the Operational and Technical Department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54370, 'Nicole Kemp', '', 'password001', 'salt001', 1, 'Ing. doc. PhD.', profession_id, '5610103840' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 19013, 'Crystal Patel', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '561010393010' FROM professionTb WHERE profession_en='IT assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 19341, 'Brandon Olson', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 45923, 'Samantha Swanson', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610104010' FROM professionTb WHERE profession_en='Vice Chancellor for Studies and Informatics'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16233, 'Joseph Davis', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34653, 'Jocelyn Collins', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610108055' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64079, 'Jessica Oconnell', '', 'password001', 'salt001', 1, 'Ing. Ph.D. PhD.', profession_id, '5610103840' FROM professionTb WHERE profession_en='OZŘ officer for VVTČ'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 84222, 'Alicia Manning', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103820' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 83629, 'Jessica Clark', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103850' FROM professionTb WHERE profession_en='Head of the Business Valuation group'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35956, 'Kayla Ayers', '', 'password001', 'salt001', 1, '', profession_id, '56101030' FROM professionTb WHERE profession_en='machine operation'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74401, 'Jennifer Dominguez', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '56101034' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24697, 'Amy Berry', '', 'password001', 'salt001', 1, 'Ing. Mgr. Ph.D. MBA', profession_id, '561010393020' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15115, 'Karla Griffin', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '56101070' FROM professionTb WHERE profession_en='Officer for research, development and creative activity'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16055, 'Taylor Long', '', 'password001', 'salt001', 1, 'Ing. PhD.', profession_id, '5610103820' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94775, 'Timothy Stewart', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610108055' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74411, 'Troy Rodriguez', '', 'password001', 'salt001', 2, 'Ing.', profession_id, '5610103708' FROM professionTb WHERE profession_en='maternity and subsequent parental leave'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55280, 'Christopher Wright', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '561010105050' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15666, 'Alexander Black', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610108055' FROM professionTb WHERE profession_en='assistant; Deputy Head of the Department of Civil Engineering'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94575, 'Martin Bolton', '', 'password001', 'salt001', 1, '', profession_id, '5610103790' FROM professionTb WHERE profession_en='HR'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 43979, 'Joseph Mclaughlin', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610107020' FROM professionTb WHERE profession_en='Office worker'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25208, 'Nathaniel Allen', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '561010393040' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34848, 'Gabriel Howard', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 12799, 'Eric Elliott', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 13856, 'Caleb Chan', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14583, 'Tammy Larson', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 84631, 'Timothy Baker', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103420' FROM professionTb WHERE profession_en='head of the department - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3499, 'Jennifer Anderson', '', 'password001', 'salt001', 2, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='officer for development activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 21922, 'Holly Bell', '', 'password001', 'salt001', 3, 'Ing. MBA', profession_id, '56101034' FROM professionTb WHERE profession_en='head of the department - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55000, 'Donna Malone', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 73512, 'Charles Porter', '', 'password001', 'salt001', 3, 'Bc.', profession_id, '5610101050' FROM professionTb WHERE profession_en='director of the Department for study administration and lifelong learning'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64817, 'John Chen', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '561010370820' FROM professionTb WHERE profession_en='maternity and subsequent parental leave'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35204, 'Robert Mcintyre', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103421' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54641, 'Michael Nelson', '', 'password001', 'salt001', 1, '', profession_id, '561010370860' FROM professionTb WHERE profession_en='canteen worker'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44482, 'Shannon Horn', '', 'password001', 'salt001', 1, 'doc. RNDr. Ph.D.', profession_id, '5610103840' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74701, 'Gregory Mendoza', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Academic worker - assistant professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54311, 'Scott Acosta', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610107020' FROM professionTb WHERE profession_en='foreign relations officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16076, 'Rebecca Dennis', '', 'password001', 'salt001', 1, 'Ing. Mgr. DiS.', profession_id, '5610103430' FROM professionTb WHERE profession_en='officer for development activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44559, 'Samantha Jones', '', 'password001', 'salt001', 1, 'doc. PhDr. PhD.', profession_id, '561010393010' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 93902, 'Stephen White', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 84319, 'Ariel Turner', '', 'password001', 'salt001', 1, 'Ing. PhD.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 75190, 'Susan Hopkins', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='head of the department - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14862, 'Hannah Holland', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54815, 'Angel Allen', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='head of the department - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15656, 'James Torres', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24503, 'John Moran', '', 'password001', 'salt001', 1, 'Ing. PhD.', profession_id, '5610103820' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24711, 'Jason Anderson', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610108055' FROM professionTb WHERE profession_en='rector''s assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54622, 'Micheal Howell', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3441, 'Martha Hill', '', 'password001', 'salt001', 2, 'Ing.', profession_id, '5610107020' FROM professionTb WHERE profession_en='Officer for research, development and creative activity'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35564, 'Kimberly Phillips', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393060' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15659, 'Ricky Strong', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '561010393010' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 45422, 'Dakota Smith', '', 'password001', 'salt001', 0, 'Ing.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 22243, 'Jeffrey Curry', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 75299, 'Christina Baker', '', 'password001', 'salt001', 1, 'Ing. et Ing. Ph.D.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Academic worker - assistant professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25588, 'Joshua Thompson', '', 'password001', 'salt001', 1, '', profession_id, '56101030' FROM professionTb WHERE profession_en='officer of the Vocational Training Center'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94579, 'Antonio Tyler', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '56101080' FROM professionTb WHERE profession_en='driver - traffic officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15475, 'Cheyenne Garcia', '', 'password001', 'salt001', 1, '', profession_id, '561010370850' FROM professionTb WHERE profession_en='clerk of the Operational and Technical Department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 18007, 'Nancy Green', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94665, 'Danielle Murphy', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 12827, 'Daniel Miller', '', 'password001', 'salt001', 0, 'PhDr.', profession_id, '56101034' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54436, 'Jennifer Jackson', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103830' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 43466, 'Samantha Jennings', '', 'password001', 'salt001', 2, 'Ing. doc. PhD.', profession_id, '5610103820' FROM professionTb WHERE profession_en='officer for development activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55229, 'Janet Leonard', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103920' FROM professionTb WHERE profession_en='Teaching and educational activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44569, 'Aaron Kerr', '', 'password001', 'salt001', 1, 'Mgr. Ph.D.', profession_id, '5610108055' FROM professionTb WHERE profession_en='assistant; Deputy Head of the Department of Civil Engineering'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34091, 'Chad Pruitt', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103820' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 18987, 'Angela Roberts', '', 'password001', 'salt001', 1, '', profession_id, '5610103790' FROM professionTb WHERE profession_en='office clerk and reception'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64298, 'Mr. Thomas Butler DVM', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393010' FROM professionTb WHERE profession_en='Academic worker - assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 84388, 'Kayla Alvarez', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393050' FROM professionTb WHERE profession_en='officer of the support department for project and expert activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 53935, 'Sherri Larson', '', 'password001', 'salt001', 1, '', profession_id, '5610104010' FROM professionTb WHERE profession_en='clerk of the legal department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 26239, 'Larry Bryant', '', 'password001', 'salt001', 1, '', profession_id, '561010370860' FROM professionTb WHERE profession_en='cleaning woman'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74699, 'Rachel Taylor', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44655, 'Timothy Wheeler', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '561010105030' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16033, 'John Anderson', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '561010393020' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 5070, 'Travis Torres', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '561010105010' FROM professionTb WHERE profession_en='Head of the Study Department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 20328, 'Traci Rowe', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010105010' FROM professionTb WHERE profession_en='study department officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14304, 'Abigail Brown', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63599, 'Gary Rivas', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 17217, 'Jose Duran', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63979, 'Ronald Page', '', 'password001', 'salt001', 1, 'Ing. prof. DrSc. ', profession_id, '5610103830' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35453, 'Patricia Patel', '', 'password001', 'salt001', 1, 'Ing. doc. CSc.', profession_id, '5610103421' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 84199, 'Christopher Carpenter', '', 'password001', 'salt001', 1, 'Ing. doc. CSc.', profession_id, '5610103840' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25585, 'Jared Medina', '', 'password001', 'salt001', 1, '', profession_id, '56101030' FROM professionTb WHERE profession_en='welder'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 95265, 'Manuel Hart', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103820' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44636, 'Selena Singleton', '', 'password001', 'salt001', 0, '', profession_id, '56101030' FROM professionTb WHERE profession_en='machine operation'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 18749, 'Jason Edwards', '', 'password001', 'salt001', 3, 'Ing.', profession_id, '56101070' FROM professionTb WHERE profession_en='foreign relations officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16041, 'Carlos Lynn', '', 'password001', 'salt001', 0, 'doc. MUDr. Ph.D.', profession_id, '5610104010' FROM professionTb WHERE profession_en='Rector'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25787, 'Jeremy Sandoval', '', 'password001', 'salt001', 1, '', profession_id, '5610104010' FROM professionTb WHERE profession_en='clerk of the legal department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44657, 'Andrew Mullins', '', 'password001', 'salt001', 1, 'Mgr. DiS.', profession_id, '561010105030' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63795, 'Debra Garcia', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='head of the department - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35352, 'Randall Nguyen', '', 'password001', 'salt001', 1, 'JUDr. Ph.D.', profession_id, '561010393030' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 53406, 'Kevin Reynolds', '', 'password001', 'salt001', 2, 'Bc.', profession_id, '56101030' FROM professionTb WHERE profession_en='Head of the Vocational Training Center'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55221, 'Theresa Gibson', '', 'password001', 'salt001', 1, 'Mgr. PhD.', profession_id, '561010393010' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35550, 'Audrey Salinas', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393050' FROM professionTb WHERE profession_en='Head of the Business Economics group - academic worker - assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24600, 'Angela Wilson', '', 'password001', 'salt001', 1, 'Ing. et Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Deputy director for expertise'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54816, 'Joanna Brown', '', 'password001', 'salt001', 1, '', profession_id, '5610103790' FROM professionTb WHERE profession_en='Purchase Officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54638, 'Shelia Rubio', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103430' FROM professionTb WHERE profession_en='Secretary of the Institute'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 33380, 'John Anthony', '', 'password001', 'salt001', 2, 'Ing. doc. Ph.D.', profession_id, '5610103420' FROM professionTb WHERE profession_en='head of the department - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 84726, 'Terry Guerrero', '', 'password001', 'salt001', 1, 'DiS. BA', profession_id, '5610103960' FROM professionTb WHERE profession_en='IT assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 13895, 'Randy Higgins', '', 'password001', 'salt001', 2, 'Ing. Bc.', profession_id, '56101037' FROM professionTb WHERE profession_en='assistant professor, Deputy Head of the Department of Transport and Logistics'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 19037, 'Christina Murphy', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103430' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44759, 'Anthony Thomas', '', 'password001', 'salt001', 1, 'Mgr. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 43855, 'Shelia Allen', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103420' FROM professionTb WHERE profession_en='head of the department - docent'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 19102, 'Angelica Mason', '', 'password001', 'salt001', 0, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14002, 'Monica Black', '', 'password001', 'salt001', 1, 'Ing. prof. DrSc. ', profession_id, '5610103830' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63978, 'Megan Perez', '', 'password001', 'salt001', 1, 'Ing. Ph.D. MBA', profession_id, '5610103421' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55255, 'Sherri Mclean', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010105030' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34702, 'Mary Fisher', '', 'password001', 'salt001', 1, '', profession_id, '561010370850' FROM professionTb WHERE profession_en='clerk of the Department of Project Works'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 5071, 'James Brown', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16945, 'Eric Fischer', '', 'password001', 'salt001', 1, 'Ing.  BBA ', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 45265, 'Frederick Santos', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610107010' FROM professionTb WHERE profession_en='Department assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94667, 'Brian Dudley', '', 'password001', 'salt001', 0, '', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64915, 'Jennifer Sanders', '', 'password001', 'salt001', 1, 'Ing. doc. Ph.D.', profession_id, '56101040' FROM professionTb WHERE profession_en='marketing specialist'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 22085, 'Alyssa Rivera', '', 'password001', 'salt001', 0, 'Ing. MBA', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54999, 'Seth Barnes MD', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103840' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 18834, 'Cody Davis', '', 'password001', 'salt001', 1, 'Ing. DiS. PhD.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34463, 'Miss Kelli Rodriguez MD', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44906, 'Brenda Welch', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103840' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 17188, 'Kimberly Schroeder', '', 'password001', 'salt001', 3, 'Ing. doc. Ph.D. MBA', profession_id, '56101038' FROM professionTb WHERE profession_en='officer for development activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 5108, 'Amber Powell PhD', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '561010393010' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 73497, 'Sharon Wheeler', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 24696, 'Brandi Green', '', 'password001', 'salt001', 0, '', profession_id, '5610107010' FROM professionTb WHERE profession_en='Officer for project activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74501, 'Lisa Sims', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103860' FROM professionTb WHERE profession_en='officer for development activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 85182, 'Casey Russell', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103960' FROM professionTb WHERE profession_en='IT technician'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63982, 'James Martinez', '', 'password001', 'salt001', 1, 'Ing. doc. Ph.D.', profession_id, '561010393010' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34043, 'Kathleen Jones', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '561010393030' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 55162, 'Roy Edwards', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '561010105030' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 75302, 'Lawrence Gonzalez', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '561010393020' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 84527, 'David Smith', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103850' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15303, 'Sandra Fernandez', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16094, 'Bryan James', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='payroll clerk'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 63396, 'Christine Lee', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103460' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25693, 'Philip Gordon', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '56101039' FROM professionTb WHERE profession_en='officer for development activities'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54131, 'Timothy Thomas', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='deputy director of the Institute for Research, Development and Creative Activity'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15575, 'Alicia Murphy', '', 'password001', 'salt001', 1, '', profession_id, '561010370860' FROM professionTb WHERE profession_en='cleaning woman'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 21182, 'Emily Martinez', '', 'password001', 'salt001', 1, 'Ing. PhD. MBA', profession_id, '5610103910' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15863, 'Doris Mendez', '', 'password001', 'salt001', 1, 'PaedDr. prof. PhD.', profession_id, '56101039' FROM professionTb WHERE profession_en='research assistant, deputy head of the Department of Informatics and Natural Sciences'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3814, 'Kayla White', '', 'password001', 'salt001', 1, 'Mgr. Ph.D.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35549, 'Amber Pugh', '', 'password001', 'salt001', 0, 'RNDr. prof. Ph.D.', profession_id, '5610103421' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94016, 'Danielle Landry', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103830' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35745, 'Robert Sanders', '', 'password001', 'salt001', 1, 'Mgr. LL.M. ', profession_id, '561010393030' FROM professionTb WHERE profession_en='Real Estate Appraisal group leader, assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3513, 'Samuel Adams', '', 'password001', 'salt001', 1, 'Mgr. Ph.D.', profession_id, '5610103850' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44596, 'Dennis Allen', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610108055' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35029, 'Shannon Davis', '', 'password001', 'salt001', 1, '', profession_id, '5610104010' FROM professionTb WHERE profession_en='clerk of the legal department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44658, 'Blake Espinoza', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '561010105030' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16023, 'Kenneth Stanley', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Academic worker - assistant professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16043, 'Peggy Moore', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393020' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3402, 'Sarah Gilbert', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610103430' FROM professionTb WHERE profession_en='lecturer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14867, 'Daniel Gonzales', '', 'password001', 'salt001', 1, 'Ing. Ph.D. MBA', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44773, 'Gabrielle Hernandez', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103421' FROM professionTb WHERE profession_en='professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64047, 'Jonathan Mora', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94577, 'Claudia Dominguez', '', 'password001', 'salt001', 1, 'Ing. MSc.', profession_id, '561010393010' FROM professionTb WHERE profession_en='head of the Law Group'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 46185, 'Ryan Cole', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15119, 'Michael Chang', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393060' FROM professionTb WHERE profession_en='Externalist'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35033, 'Annette Shepherd', '', 'password001', 'salt001', 1, 'Ing. PhD.', profession_id, '5610103820' FROM professionTb WHERE profession_en='assistant professor, Deputy Head of the Department of Engineering'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54724, 'Amber Miller', '', 'password001', 'salt001', 1, 'RNDr. prof. DrSc. ', profession_id, '5610103840' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15127, 'Lonnie Mckenzie', '', 'password001', 'salt001', 1, 'Ing. doc. PhD.', profession_id, '5610103820' FROM professionTb WHERE profession_en='research assistant, deputy head of the Department of Informatics and Natural Sciences'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 45420, 'Lorraine Garcia', '', 'password001', 'salt001', 0, 'Mgr.', profession_id, '5610103430' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15935, 'Matthew Goodman', 'stehel@mail.vstecb.cz', 'password001', 'salt001', 2, 'Ing. doc. PhD. MBA', profession_id, '561010' FROM professionTb WHERE profession_en='internal auditor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 64918, 'Samantha Martin', '', 'password001', 'salt001', 1, 'Ing. doc. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='assistant; Deputy Head of the Department of Civil Engineering'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 75002, 'Michelle Edwards', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103421' FROM professionTb WHERE profession_en='assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35074, 'Andrea Foley', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '561010393040' FROM professionTb WHERE profession_en='Head of the Technical Expertise Group, scientific assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35360, 'Ashley Griffin', '', 'password001', 'salt001', 1, '', profession_id, '561010370860' FROM professionTb WHERE profession_en='cleaning woman'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 4209, 'Andrea Macias', '', 'password001', 'salt001', 2, 'doc.  Mgr. PaedDr.  Ph.D. MBA MSc.', profession_id, '5610103420' FROM professionTb WHERE profession_en='machine operation'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 12810, 'Christine Ingram', '', 'password001', 'salt001', 1, 'doc.  Mgr. PaedDr.  Ph.D. MBA MSc.', profession_id, '5610103420' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35031, 'David Young', '', 'password001', 'salt001', 1, 'doc. RNDr. Ph.D.', profession_id, '5610103850' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94468, 'Kristi Delgado', '', 'password001', 'salt001', 1, 'Ing. doc. Ph.D. MBA', profession_id, '5610103840' FROM professionTb WHERE profession_en='associate professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16762, 'Kimberly Gallagher', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '561010105010' FROM professionTb WHERE profession_en='study department officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 34703, 'Joseph Fritz', '', 'password001', 'salt001', 1, '', profession_id, '561010370860' FROM professionTb WHERE profession_en='head chef'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 74797, 'Kelly Chavez', '', 'password001', 'salt001', 1, '', profession_id, '561010370850' FROM professionTb WHERE profession_en='clerk of the Operational and Technical Department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 35354, 'Paula Blankenship', '', 'password001', 'salt001', 1, 'Ing. prof. CSc.', profession_id, '5610108055' FROM professionTb WHERE profession_en='research assistant, deputy head of the Department of Informatics and Natural Sciences'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 25590, 'Sarah Harris', '', 'password001', 'salt001', 1, '', profession_id, '56101030' FROM professionTb WHERE profession_en='officer of the Vocational Training Center'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 15859, 'Kelsey Jordan', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '561010105010' FROM professionTb WHERE profession_en='study department officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3496, 'Samantha Ritter', '', 'password001', 'salt001', 1, 'Ing. Ph.D.', profession_id, '5610103830' FROM professionTb WHERE profession_en='Assistant Professor'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 54918, 'Kelly Benson', '', 'password001', 'salt001', 1, 'Ing. prof. PhD.', profession_id, '5610103840' FROM professionTb WHERE profession_en='institute assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 73901, 'Nichole Stafford', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 44656, 'Virginia Ochoa', '', 'password001', 'salt001', 1, 'MVDr.', profession_id, '561010105030' FROM professionTb WHERE profession_en='clerk of the development department'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 16078, 'Gregory Boone', '', 'password001', 'salt001', 1, 'Ing.', profession_id, '5610104010' FROM professionTb WHERE profession_en='Practice and career center officer'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 94972, 'Shannon Hansen', '', 'password001', 'salt001', 1, 'Mgr.', profession_id, '5610103420' FROM professionTb WHERE profession_en='Academic worker - assistant'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 14008, 'Alejandro Castro', '', 'password001', 'salt001', 1, 'Bc.', profession_id, '5610103790' FROM professionTb WHERE profession_en='Financial accountant II.'
INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT 3599, 'David Hicks', '', 'password001', 'salt001', 1, '', profession_id, '561010370860' FROM professionTb WHERE profession_en='maintenance worker'
