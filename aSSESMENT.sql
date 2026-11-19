DROP TABLE fh_rental_line CASCADE CONSTRAINTS;
DROP TABLE fh_rental CASCADE CONSTRAINTS;
DROP TABLE fh_stock CASCADE CONSTRAINTS;
DROP TABLE fh_member_branch CASCADE CONSTRAINTS;
DROP TABLE fh_staff CASCADE CONSTRAINTS;
DROP TABLE fh_furniture_item CASCADE CONSTRAINTS;
DROP TABLE fh_member CASCADE CONSTRAINTS;
DROP TABLE fh_branch CASCADE CONSTRAINTS;

-- this is to create the table

CREATE TABLE fh_branch (
    branch_id VARCHAR2(10) PRIMARY KEY,
    address VARCHAR2(150) NOT NULL,
    telephone VARCHAR2(20),
    email VARCHAR2(100)
);

CREATE TABLE fh_member (
    member_id VARCHAR2(10) PRIMARY KEY,
    full_name VARCHAR2(100) NOT NULL,
    address VARCHAR2(150) NOT NULL,
    date_registered DATE NOT NULL
);

CREATE TABLE fh_furniture_item (
    item_id VARCHAR2(10) PRIMARY KEY,
    title VARCHAR2(100) NOT NULL,
    category VARCHAR2(50) NOT NULL,
    colour VARCHAR2(30),
    size_desc VARCHAR2(50),
    supplier VARCHAR2(80),
    rental_price NUMBER(8,2) NOT NULL,
    CONSTRAINT chk_price CHECK (rental_price > 0)
);

CREATE TABLE fh_staff (
    staff_id VARCHAR2(10) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    surname VARCHAR2(50) NOT NULL,
    position VARCHAR2(30) NOT NULL,
    salary NUMBER(9,2) NOT NULL,
    start_date DATE NOT NULL,
    finish_date DATE,
    branch_id VARCHAR2(10) NOT NULL,
    line_manager_id VARCHAR2(10),
    
    
    CONSTRAINT fk_staff_branch
        FOREIGN KEY (branch_id) REFERENCES fh_branch(branch_id),
    CONSTRAINT fk_staff_manager
        FOREIGN KEY (line_manager_id) REFERENCES fh_staff(staff_id),
    CONSTRAINT chk_position
        CHECK (position IN ('Manager','Administrator','Assistant')),
    CONSTRAINT chk_salary
        CHECK (salary > 0)
);

CREATE TABLE fh_member_branch (
    member_id VARCHAR2(10),
    branch_id VARCHAR2(10),
    registered_by VARCHAR2(10),
    join_date DATE NOT NULL,
    
    CONSTRAINT pk_member_branch
        PRIMARY KEY (member_id, branch_id),
    CONSTRAINT fk_mb_member
        FOREIGN KEY (member_id) REFERENCES fh_member(member_id),
    CONSTRAINT fk_mb_branch
        FOREIGN KEY (branch_id) REFERENCES fh_branch(branch_id),
    CONSTRAINT fk_mb_staff
        FOREIGN KEY (registered_by) REFERENCES fh_staff(staff_id)
);

CREATE TABLE fh_stock (
    stock_id VARCHAR2(10) PRIMARY KEY,
    item_id VARCHAR2(10) NOT NULL,
    branch_id VARCHAR2(10) NOT NULL,
    purchase_date DATE NOT NULL,
    status VARCHAR2(20) NOT NULL,
    
    CONSTRAINT fk_stock_item
        FOREIGN KEY (item_id) REFERENCES fh_furniture_item(item_id),
    CONSTRAINT fk_stock_branch
        FOREIGN KEY (branch_id) REFERENCES fh_branch(branch_id),
    CONSTRAINT chk_status
        CHECK (status IN ('Available','Rented','Damaged','Lost'))
);

CREATE TABLE fh_rental (
    rental_id VARCHAR2(10) PRIMARY KEY,
    member_id VARCHAR2(10) NOT NULL,
    branch_id VARCHAR2(10) NOT NULL,
    rental_date DATE NOT NULL,
    
    CONSTRAINT fk_rental_member
        FOREIGN KEY (member_id) REFERENCES fh_member(member_id),
    CONSTRAINT fk_rental_branch
        FOREIGN KEY (branch_id) REFERENCES fh_branch(branch_id)
);

CREATE TABLE fh_rental_line (
    rental_line_id VARCHAR2(10) PRIMARY KEY,
    rental_id VARCHAR2(10) NOT NULL,
    stock_id VARCHAR2(10) NOT NULL,
    out_date DATE NOT NULL,
    in_date DATE,
    
    CONSTRAINT fk_rl_rental
        FOREIGN KEY (rental_id) REFERENCES fh_rental(rental_id),
    CONSTRAINT fk_rl_stock
        FOREIGN KEY (stock_id) REFERENCES fh_stock(stock_id),
    CONSTRAINT chk_dates
        CHECK (in_date IS NULL OR in_date >= out_date)
);

-- to insert the data

INSERT INTO fh_branch VALUES ('B1','Stafford High St','01785 111111','stafford@fh.com');
INSERT INTO fh_branch VALUES ('B2','Stoke City Centre','01782 222222','stoke@fh.com');

INSERT INTO fh_member VALUES ('M1','John Smith','12 King St', DATE '2023-01-10');
INSERT INTO fh_member VALUES ('M2','Sarah Jones','45 Queen Rd', DATE '2023-02-15');
INSERT INTO fh_member VALUES ('M3','David Wilson','78 Park Ave', DATE '2023-05-10');

INSERT INTO fh_furniture_item VALUES ('F1','Ikea Bed','Bedroom','White','Double','IKEA',40);
INSERT INTO fh_furniture_item VALUES ('F2','Dining Table','Kitchen','Brown','Large','Argos',60);
INSERT INTO fh_furniture_item VALUES ('F3','Leather Sofa','Living Room','Black','Large','DFS',80);

INSERT INTO fh_staff VALUES ('S1','Mike','Brown','Manager',30000, DATE '2020-01-01', NULL,'B1',NULL);
INSERT INTO fh_staff VALUES ('S2','Anna','White','Assistant',20000, DATE '2022-01-01', NULL,'B1','S1');
INSERT INTO fh_staff VALUES ('S3','James','Taylor','Manager',32000, DATE '2019-05-01', NULL, 'B2',NULL);
INSERT INTO fh_staff VALUES ('S4','Emily','Clark','Assistant',21000, DATE '2023-03-01', NULL,'B2','S3');

INSERT INTO fh_member_branch VALUES ('M1','B1','S2', DATE '2023-01-10');
INSERT INTO fh_member_branch VALUES ('M2','B1','S2', DATE '2023-02-15');
INSERT INTO fh_member_branch VALUES ('M3','B2','S4', DATE '2023-05-10');

INSERT INTO fh_stock VALUES ('ST1','F1','B1', DATE '2022-01-01','Available');
INSERT INTO fh_stock VALUES ('ST2','F2','B1', DATE '2022-06-01','Available');
INSERT INTO fh_stock VALUES ('ST3','F3','B2', DATE '2023-01-01','Available');

INSERT INTO fh_rental VALUES ('R1','M1','B1', DATE '2024-01-01');
INSERT INTO fh_rental VALUES ('R2','M3','B2', DATE '2024-02-01');

INSERT INTO fh_rental_line VALUES ('RL1','R1','ST1', DATE '2024-01-01', DATE '2024-01-10');
INSERT INTO fh_rental_line VALUES ('RL2','R2','ST3', DATE '2024-02-01', DATE '2024-02-15');

COMMIT;

-- queries

SELECT 
    item_id,
    title,
    category,
    colour,
    size_desc,
    supplier,
    rental_price
FROM fh_furniture_item
WHERE LOWER(category) = LOWER('&Enter_Category');

SELECT 
    s.staff_id,
    s.first_name || ' ' || s.surname AS staff_name,
    s.position,
    s.salary,
    s.branch_id,
    m.first_name || ' ' || m.surname AS line_manager
FROM fh_staff s
LEFT JOIN fh_staff m 
    ON s.line_manager_id = m.staff_id
WHERE s.branch_id = '&Enter_Branch_ID';

SELECT 
    b.branch_id,
    b.address,
    f.category,
    SUM(f.rental_price) AS total_revenue
FROM fh_rental r
JOIN fh_branch b 
    ON r.branch_id = b.branch_id
JOIN fh_rental_line rl 
    ON r.rental_id = rl.rental_id
JOIN fh_stock st 
    ON rl.stock_id = st.stock_id
JOIN fh_furniture_item f 
    ON st.item_id = f.item_id
GROUP BY b.branch_id, b.address, f.category
ORDER BY b.branch_id, f.category;

SELECT 
    f.category,
    SUM(f.rental_price) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(f.rental_price) DESC
    ) AS revenue_rank
FROM fh_rental_line rl
JOIN fh_stock st 
    ON rl.stock_id = st.stock_id
JOIN fh_furniture_item f 
    ON st.item_id = f.item_id
GROUP BY f.category;

SELECT 
    stock_id,
    item_id,
    branch_id,
    status,
    DECODE(
        status,
        'Available', 'Ready to rent',
        'Rented', 'Currently rented out',
        'Damaged', 'Needs repair',
        'Lost', 'Cannot be rented',
        'Unknown status'
    ) AS status_description
FROM fh_stock;

SELECT 
    b.branch_id,
    b.address,
    f.category,
    COUNT(st.stock_id) AS number_of_items,
    SUM(f.rental_price) AS possible_monthly_revenue
FROM fh_branch b
JOIN fh_stock st 
    ON b.branch_id = st.branch_id
JOIN fh_furniture_item f 
    ON st.item_id = f.item_id
GROUP BY b.branch_id, b.address, f.category
ORDER BY b.branch_id;

CREATE OR REPLACE VIEW fh_branch_management_view AS
SELECT 
    b.branch_id,
    b.address,
    f.category,
    COUNT(rl.rental_line_id) AS number_of_rentals,
    SUM(f.rental_price) AS revenue
FROM fh_branch b
JOIN fh_rental r 
    ON b.branch_id = r.branch_id
JOIN fh_rental_line rl 
    ON r.rental_id = rl.rental_id
JOIN fh_stock st 
    ON rl.stock_id = st.stock_id
JOIN fh_furniture_item f 
    ON st.item_id = f.item_id
GROUP BY b.branch_id, b.address, f.category;

SELECT *
FROM fh_branch_management_view
WHERE branch_id = '&Enter_Branch_ID'
ORDER BY category;