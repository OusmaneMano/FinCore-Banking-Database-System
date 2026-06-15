
--DDL
CREATE DATABASE fincore;

USE fincore;

--branch Table
CREATE TABLE branch (
    branch_id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(80) NOT NULL,
    country VARCHAR(80) NOT NULL DEFAULT 'Germany',
    phone VARCHAR(30),
    PRIMARY KEY (branch_id)
);

--Customer Table
CREATE TABLE customer (
    customer_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(30),
    date_of_birth DATE NOT NULL,
    kyc_status ENUM('pending','verified','rejected') DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id) );

--Employee Table
CREATE TABLE employee (
    employee_id INT NOT NULL AUTO_INCREMENT,
    branch_id INT NOT NULL,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    role ENUM('teller','advisor','manager','analyst') NOT NULL,
    salary DECIMAL(12,2) NOT NULL,
    hired_at DATE NOT NULL,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

--Account Table
CREATE TABLE account (
    account_id INT NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_type ENUM('checking','savings','loan') NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.00,
    iban VARCHAR(34) NOT NULL UNIQUE,
    status ENUM('active','frozen','closed') DEFAULT 'active',
    opened_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (account_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

--Transaction Table
CREATE TABLE transaction (
    transaction_id INT NOT NULL AUTO_INCREMENT,
    account_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    type ENUM('deposit','withdrawal','transfer_in','transfer_out','fee') NOT NULL,
    status ENUM('pending','completed','failed','reversed') DEFAULT 'completed',
    description VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (transaction_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

--Card Table
CREATE TABLE card (
    card_id INT NOT NULL AUTO_INCREMENT,
    account_id INT NOT NULL,
    card_type ENUM('debit','credit') NOT NULL,
    card_number CHAR(16) NOT NULL UNIQUE,
    expiry_date DATE NOT NULL,
    cvv_hash VARCHAR(255) NOT NULL,
    status ENUM('active','blocked','expired') DEFAULT 'active',
    issued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (card_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

--Loan Table
CREATE TABLE loan (
    loan_id INT NOT NULL AUTO_INCREMENT,
    account_id INT NOT NULL,
    employee_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    term_months INT NOT NULL,
    monthly_payment DECIMAL(15,2) NOT NULL,
    status ENUM('active','paid_off','defaulted') DEFAULT 'active',
    disbursed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (loan_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

--Indexes
CREATE INDEX idx_txn_account_date ON transaction(account_id, created_at);
CREATE INDEX idx_txn_status ON transaction(status);
CREATE INDEX idx_account_customer ON account(customer_id);
CREATE INDEX idx_account_branch ON account(branch_id);
CREATE INDEX idx_loan_status ON loan(status);
CREATE INDEX idx_customer_email ON customer(email);

--DML
-- 2.1  Branches
INSERT INTO branch (name, address, city, country, phone) VALUES
  ('FinCore Berlin Mitte',    'Friedrichstraße 10',   'Berlin',    'Germany', '+49301000001'),
  ('FinCore Munich Central',  'Marienplatz 5',        'Munich',    'Germany', '+49891000002'),
  ('FinCore Hamburg HQ',      'Jungfernstieg 20',     'Hamburg',   'Germany', '+49401000003'),
  ('FinCore Frankfurt Main',  'Kaiserstraße 14',      'Frankfurt', 'Germany', '+49691000004');

-- 2.2  Customers
INSERT INTO customer (first_name, last_name, email, phone, date_of_birth, kyc_status) VALUES
  ('Lena',     'Müller',    'lena.mueller@mail.de',    '+4915111110001', '1990-03-14', 'verified'),
  ('Jonas',    'Schmidt',   'jonas.schmidt@mail.de',   '+4915111110002', '1985-07-22', 'verified'),
  ('Fatima',   'Diallo',    'fatima.diallo@mail.de',   '+4915111110003', '1993-11-05', 'verified'),
  ('Erik',     'Hansen',    'erik.hansen@mail.de',     '+4915111110004', '1978-01-30', 'verified'),
  ('Aisha',    'Traoré',    'aisha.traore@mail.de',    '+4915111110005', '1995-06-18', 'pending'),
  ('Stefan',   'Wagner',    'stefan.wagner@mail.de',   '+4915111110006', '1988-09-09', 'verified'),
  ('Mia',      'Becker',    'mia.becker@mail.de',      '+4915111110007', '2000-02-28', 'verified'),
  ('Carlos',   'Ortega',    'carlos.ortega@mail.de',   '+4915111110008', '1982-12-01', 'verified'),
  ('Ingrid',   'Larsen',    'ingrid.larsen@mail.de',   '+4915111110009', '1975-05-17', 'verified'),
  ('Kwame',    'Asante',    'kwame.asante@mail.de',    '+4915111110010', '1997-08-23', 'verified');

-- 2.3  Employees
INSERT INTO employee (branch_id, first_name, last_name, role, salary, hired_at) VALUES
  (1, 'Anna',    'Klein',    'manager',  72000.00, '2015-04-01'),
  (1, 'Peter',   'Hofmann',  'teller',   34000.00, '2019-08-12'),
  (2, 'Maria',   'Braun',    'advisor',  48000.00, '2017-02-20'),
  (2, 'Tobias',  'Richter',  'teller',   33000.00, '2021-06-01'),
  (3, 'Sabine',  'Wolf',     'manager',  75000.00, '2012-11-15'),
  (3, 'David',   'Fischer',  'analyst',  55000.00, '2018-03-10'),
  (4, 'Claudia', 'Schäfer',  'advisor',  49000.00, '2020-09-01'),
  (4, 'Michael', 'Krause',   'teller',   32500.00, '2022-01-17');

-- 2.4  Accounts
INSERT INTO account (customer_id, branch_id, account_type, balance, iban, status) VALUES
  (1,  1, 'checking', 4250.00,  'DE89370400440532013000', 'active'),
  (1,  1, 'savings',  18500.00, 'DE89370400440532013001', 'active'),
  (2,  1, 'checking', 1200.50,  'DE89370400440532013002', 'active'),
  (3,  2, 'savings',  9800.00,  'DE89370400440532013003', 'active'),
  (4,  2, 'checking', 320.00,   'DE89370400440532013004', 'active'),
  (5,  3, 'checking', 750.00,   'DE89370400440532013005', 'active'),
  (6,  3, 'savings',  32000.00, 'DE89370400440532013006', 'active'),
  (7,  4, 'checking', 2100.00,  'DE89370400440532013007', 'active'),
  (8,  4, 'savings',  5600.00,  'DE89370400440532013008', 'active'),
  (9,  1, 'checking', 890.00,   'DE89370400440532013009', 'active'),
  (10, 2, 'checking', 14300.00, 'DE89370400440532013010', 'active'),
  (2,  1, 'savings',  6700.00,  'DE89370400440532013011', 'frozen');

-- 2.5  Transactions
INSERT INTO transaction (account_id, amount, type, status, description) VALUES
  (1,  3000.00, 'deposit',       'completed', 'Salary March'),
  (1,   450.00, 'withdrawal',    'completed', 'ATM withdrawal Berlin'),
  (1,   200.00, 'transfer_out',  'completed', 'Rent payment'),
  (2,  5000.00, 'deposit',       'completed', 'Bonus payment'),
  (3,   800.00, 'deposit',       'completed', 'Freelance income'),
  (3,   150.00, 'withdrawal',    'completed', 'Online shopping'),
  (4,  2000.00, 'deposit',       'completed', 'Monthly savings'),
  (5,   100.00, 'withdrawal',    'completed', 'Grocery store'),
  (6,   500.00, 'deposit',       'completed', 'Part-time job'),
  (7, 12000.00, 'deposit',       'completed', 'Annual bonus'),
  (8,   900.00, 'transfer_out',  'completed', 'Wire transfer'),
  (9,   250.00, 'deposit',       'completed', 'Refund received'),
  (10, 3500.00, 'deposit',       'completed', 'Consulting fee'),
  (10,  75.00,  'fee',           'completed', 'Account maintenance fee'),
  (11, 1000.00, 'deposit',       'completed', 'Old deposit before freeze'),
  (1,   300.00, 'withdrawal',    'failed',    'Insufficient funds attempt'),
  (3,   500.00, 'transfer_in',   'completed', 'Transfer from account 1'),
  (5,   200.00, 'deposit',       'completed', 'Cash deposit'),
  (7,   400.00, 'withdrawal',    'completed', 'Furniture store'),
  (8,   100.00, 'deposit',       'completed', 'Interest credited');

-- 2.6  Cards
INSERT INTO card (account_id, card_type, card_number, expiry_date, cvv_hash, status) VALUES
  (1,  'debit',  '4111111111110001', '2027-12-31', SHA2('101', 256), 'active'),
  (1,  'credit', '4111111111110002', '2026-06-30', SHA2('102', 256), 'active'),
  (3,  'debit',  '4111111111110003', '2028-03-31', SHA2('103', 256), 'active'),
  (4,  'debit',  '4111111111110004', '2025-11-30', SHA2('104', 256), 'expired'),
  (5,  'debit',  '4111111111110005', '2027-08-31', SHA2('105', 256), 'active'),
  (7,  'credit', '4111111111110006', '2026-09-30', SHA2('106', 256), 'active'),
  (8,  'debit',  '4111111111110007', '2028-01-31', SHA2('107', 256), 'active'),
  (10, 'credit', '4111111111110008', '2027-04-30', SHA2('108', 256), 'blocked'),
  (11, 'debit',  '4111111111110009', '2026-12-31', SHA2('109', 256), 'blocked'),
  (6,  'credit', '4111111111110010', '2028-07-31', SHA2('110', 256), 'active');

-- 2.7  Loans
INSERT INTO loan (account_id, employee_id, amount, interest_rate, term_months, monthly_payment, status) VALUES
  (1,  3, 15000.00, 4.50, 48,  342.50, 'active'),
  (3,  3, 8000.00,  5.20, 24,  351.80, 'active'),
  (5,  7, 3500.00,  6.00, 12,  300.75, 'paid_off'),
  (8,  7, 25000.00, 3.90, 60,  459.20, 'active'),
  (10, 3, 12000.00, 4.75, 36,  358.60, 'active'),
  (2,  6, 50000.00, 3.50, 120, 494.30, 'active');

-- ----------------------------------------------
-- CRUD

-- List all customers with their KYC status
SELECT customer_id, first_name, last_name, email, kyc_status
FROM customer
ORDER BY last_name;

-- Insert a new customer
INSERT INTO customer (first_name, last_name, email, phone, date_of_birth, kyc_status)
VALUES ('Sophie', 'Neumann', 'sophie.neumann@mail.de', '+4915199990001', '1996-04-10', 'pending');

-- Update KYC status after document verification
UPDATE customer
SET kyc_status = 'verified'
WHERE email = 'aisha.traore@mail.de';

-- Freeze an account (e.g. suspicious activity)
UPDATE account
SET status = 'frozen'
WHERE iban = 'DE89370400440532013004';

-- Delete a failed/test transaction
DELETE FROM transaction
WHERE status = 'failed';

-- -----------------------------------------------
--JOINS 

-- Full customer + account + branch overview
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    c.kyc_status,
    a.account_id,
    a.account_type,
    a.balance,
    a.iban,
    a.status                                 AS account_status,
    b.name                                   AS branch_name,
    b.city
FROM customer c
JOIN account  a ON c.customer_id = a.customer_id
JOIN branch   b ON a.branch_id   = b.branch_id
ORDER BY c.last_name, a.account_type;

-- All transactions with customer name and account type
SELECT
    t.transaction_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    a.account_type,
    a.iban,
    t.type,
    t.amount,
    t.status,
    t.created_at
FROM transaction t
JOIN account  a ON t.account_id  = a.account_id
JOIN customer c ON a.customer_id = c.customer_id
ORDER BY t.created_at DESC;

-- Loan details with employee advisor name and branch
SELECT
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS borrower,
    l.amount,
    l.interest_rate,
    l.term_months,
    l.monthly_payment,
    l.status                                 AS loan_status,
    CONCAT(e.first_name, ' ', e.last_name)  AS advisor,
    b.name                                   AS branch
FROM loan l
JOIN account  a ON l.account_id  = a.account_id
JOIN customer c ON a.customer_id = c.customer_id
JOIN employee e ON l.employee_id = e.employee_id
JOIN branch   b ON e.branch_id   = b.branch_id
ORDER BY l.disbursed_at DESC;

--------------------------------------------------
-- AGGREGATIONS

-- Total deposits vs withdrawals per account
SELECT
    a.iban,
    CONCAT(c.first_name, ' ', c.last_name)             AS customer,
    SUM(CASE WHEN t.type IN ('deposit','transfer_in')
             THEN t.amount ELSE 0 END)                 AS total_in,
    SUM(CASE WHEN t.type IN ('withdrawal','transfer_out','fee')
             THEN t.amount ELSE 0 END)                 AS total_out,
    COUNT(t.transaction_id)                             AS txn_count
FROM account a
JOIN customer    c ON a.customer_id = c.customer_id
LEFT JOIN transaction t ON t.account_id = a.account_id
GROUP BY a.account_id, a.iban, customer
ORDER BY total_in DESC;

-- Average balance per account type
SELECT
    account_type,
    COUNT(*)                  AS total_accounts,
    ROUND(AVG(balance), 2)    AS avg_balance,
    SUM(balance)              AS total_balance
FROM account
WHERE status = 'active'
GROUP BY account_type;

-- Monthly transaction volume (last 12 months)
SELECT
    DATE_FORMAT(created_at, '%Y-%m')   AS month,
    COUNT(*)                           AS txn_count,
    SUM(amount)                        AS total_volume,
    AVG(amount)                        AS avg_amount
FROM transaction
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
  AND status = 'completed'
GROUP BY month
ORDER BY month DESC;

-- Top 3 customers by total account balance
SELECT
    CONCAT(c.first_name, ' ', c.last_name)  AS customer,
    c.kyc_status,
    COUNT(a.account_id)                      AS num_accounts,
    SUM(a.balance)                           AS total_balance
FROM customer c
JOIN account a ON c.customer_id = a.customer_id
WHERE a.status = 'active'
GROUP BY c.customer_id, customer, c.kyc_status
ORDER BY total_balance DESC
LIMIT 3;

-- Revenue per branch (fees collected)
SELECT
    b.name           AS branch,
    b.city,
    COUNT(t.transaction_id) AS fee_txn_count,
    SUM(t.amount)           AS fee_revenue
FROM branch b
JOIN account     a ON a.branch_id   = b.branch_id
JOIN transaction t ON t.account_id  = a.account_id
WHERE t.type = 'fee' AND t.status = 'completed'
GROUP BY b.branch_id, b.name, b.city
ORDER BY fee_revenue DESC;

-- ── 3.4  ADVANCED / BUSINESS LOGIC ───────────────────────────

-- Customers with multiple accounts (detect power users)
SELECT
    CONCAT(c.first_name, ' ', c.last_name)  AS customer,
    c.email,
    COUNT(a.account_id)                      AS account_count,
    SUM(a.balance)                           AS total_balance
FROM customer c
JOIN account a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, customer, c.email
HAVING COUNT(a.account_id) > 1
ORDER BY account_count DESC;

-- Active loans with remaining principal estimate
SELECT
    CONCAT(c.first_name, ' ', c.last_name)  AS borrower,
    l.amount                                 AS original_amount,
    l.interest_rate,
    l.term_months,
    l.monthly_payment,
    ROUND(l.monthly_payment * l.term_months, 2) AS total_repayable,
    ROUND(l.monthly_payment * l.term_months - l.amount, 2) AS total_interest
FROM loan l
JOIN account  a ON l.account_id  = a.account_id
JOIN customer c ON a.customer_id = c.customer_id
WHERE l.status = 'active'
ORDER BY l.amount DESC;

-- Accounts with cards that are expired or blocked (risk report)
SELECT
    CONCAT(c.first_name, ' ', c.last_name)  AS customer,
    a.iban,
    cd.card_type,
    cd.card_number,
    cd.expiry_date,
    cd.status                                AS card_status
FROM card cd
JOIN account  a ON cd.account_id = a.account_id
JOIN customer c ON a.customer_id = c.customer_id
WHERE cd.status IN ('expired', 'blocked')
ORDER BY cd.expiry_date;

-- Branch performance: total deposits, loans issued, active accounts
SELECT
    b.name                                         AS branch,
    b.city,
    COUNT(DISTINCT a.account_id)                   AS active_accounts,
    COALESCE(SUM(a.balance), 0)                    AS total_deposits,
    COUNT(DISTINCT l.loan_id)                      AS loans_issued,
    COALESCE(SUM(l.amount), 0)                     AS total_loan_value,
    COUNT(DISTINCT e.employee_id)                  AS staff_count
FROM branch b
LEFT JOIN account  a ON a.branch_id = b.branch_id AND a.status = 'active'
LEFT JOIN loan     l ON l.account_id = a.account_id
LEFT JOIN employee e ON e.branch_id  = b.branch_id
GROUP BY b.branch_id, b.name, b.city
ORDER BY total_deposits DESC;

-- Customers with no transactions in the last 90 days (dormant accounts)
SELECT
    CONCAT(c.first_name, ' ', c.last_name)  AS customer,
    a.iban,
    a.balance,
    MAX(t.created_at)                        AS last_transaction
FROM customer c
JOIN account     a ON c.customer_id = a.customer_id
LEFT JOIN transaction t ON t.account_id  = a.account_id
WHERE a.status = 'active'
GROUP BY c.customer_id, customer, a.account_id, a.iban, a.balance
HAVING last_transaction < DATE_SUB(NOW(), INTERVAL 90 DAY)
    OR last_transaction IS NULL
ORDER BY last_transaction ASC;

-- ─────────────────────────────────────────
-- END OF fincore_schema.sql
-- ─────────────────────────────────────────

