# Scrooge Bank - Ruby on Rails Banking API

A comprehensive banking system built with Ruby on Rails 8, featuring user management, account operations, transactions, and automated loan processing.

## Project Overview

This banking API simulates core banking operations including account management, deposits, withdrawals, and loan processing. The system starts with $250,000 in capital and can utilize up to 25% of customer deposits for additional lending capacity.

## Technology Stack

- **Framework**: Ruby on Rails 8.0.2 (API mode)
- **Database**: PostgreSQL
- **Testing**: RSpec with comprehensive test coverage
- **Authentication**: Header-based user identification
- **CORS**: Enabled for cross-origin requests

## Installation and Setup

### Prerequisites

Ensure you have the following installed:
- Ruby 3.0 or higher
- Rails 8.0.2
- PostgreSQL database
- Bundler gem manager

### Step 1: Project Initialization

Clone the repository and navigate to the project directory:

```bash
git clone https://github.com/Mowlavie/scrooge.git
cd bank_app
```

### Step 2: Dependency Installation

Install all required gems:

```bash
bundle install
```

If you encounter any dependency issues, try:

```bash
bundle update
```

### Step 3: Database Configuration

Create and migrate the database:

```bash
bin/rails db:create
bin/rails db:migrate
```

Verify the database setup by checking the schema:

```bash
bin/rails db:schema:dump
```

### Step 4: Test Suite Execution

Run the complete test suite to verify installation:

```bash
bundle exec rspec
```

Expected output should show all tests passing with minimal pending tests.

### Step 5: Server Launch

Start the development server:

```bash
bin/rails server
```

The API will be accessible at `http://localhost:3000`

## API Architecture

### Database Schema

The system uses five main models:

- **Users**: Customer information and authentication
- **Accounts**: Individual checking accounts linked to users
- **Transactions**: Complete audit trail of all financial operations
- **Loans**: Loan applications, approvals, and payment tracking
- **BankConfig**: System configuration and fund tracking

### Business Logic Rules

1. **Account Limitations**: Each user may maintain only one active checking account
2. **Fund Management**: Bank operates with $250,000 initial capital plus 25% of total customer deposits
3. **Loan Processing**: All approved loans carry 0% interest rate
4. **Withdrawal Restrictions**: Users cannot withdraw more than their current account balance
5. **Account Closure**: Accounts can only be closed when balance reaches zero

## Comprehensive Testing Guide

### Method 1: Command Line Testing

This section provides detailed curl commands to test each API endpoint systematically.

#### Test Sequence 1: Basic User and Account Setup

**Step 1: Verify Bank Initial Status**

```bash
curl -X GET http://localhost:3000/bank/status
```

Expected Response:
```json
{
  "total_funds": "250000.0",
  "customer_deposits": "0.0", 
  "outstanding_loans": "0.0",
  "total_customers": 0
}
```

**Step 2: Create First User**

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "Sarah Johnson",
      "email": "sarah.johnson@example.com"
    }
  }'
```

Expected Response Pattern:
```json
{
  "id": 1,
  "email": "sarah.johnson@example.com",
  "name": "Sarah Johnson",
  "created_at": "[timestamp]",
  "updated_at": "[timestamp]"
}
```

**Important**: Note the user ID from the response - you'll need this for all subsequent requests.

**Step 3: Account Creation**

```bash
curl -X POST http://localhost:3000/accounts \
  -H "User-ID: 1"
```

Expected Response:
```json
{
  "id": 1,
  "user_id": 1,
  "account_type": "checking",
  "balance": "0.0",
  "status": "active",
  "created_at": "[timestamp]",
  "updated_at": "[timestamp]"
}
```

#### Test Sequence 2: Transaction Operations

**Step 4: Initial Deposit**

```bash
curl -X POST http://localhost:3000/accounts/1/deposit \
  -H "User-ID: 1" \
  -H "Content-Type: application/json" \
  -d '{"amount": 2500}'
```

Expected Response:
```json
{
  "message": "Deposit successful",
  "new_balance": "2500.0"
}
```

**Step 5: Verify Bank Status After Deposit**

```bash
curl -X GET http://localhost:3000/bank/status
```

Expected Response Changes:
- `total_funds` should increase to "250625.0" (original + 25% of deposit)
- `customer_deposits` should show "2500.0"
- `total_customers` should show 1

**Step 6: Test Withdrawal Within Limits**

```bash
curl -X POST http://localhost:3000/accounts/1/withdraw \
  -H "User-ID: 1" \
  -H "Content-Type: application/json" \
  -d '{"amount": 500}'
```

Expected Response:
```json
{
  "message": "Withdrawal successful",
  "new_balance": "2000.0"
}
```

**Step 7: Test Overdraft Protection**

```bash
curl -X POST http://localhost:3000/accounts/1/withdraw \
  -H "User-ID: 1" \
  -H "Content-Type: application/json" \
  -d '{"amount": 5000}'
```

Expected Response:
```json
{
  "error": "Insufficient funds or invalid amount"
}
```

#### Test Sequence 3: Loan System Validation

**Step 8: Loan Application**

```bash
curl -X POST http://localhost:3000/loans \
  -H "User-ID: 1" \
  -H "Content-Type: application/json" \
  -d '{
    "loan": {
      "amount": 10000
    }
  }'
```

Expected Response:
```json
{
  "message": "Loan approved and funds disbursed",
  "loan": {
    "id": 1,
    "user_id": 1,
    "amount": "10000.0",
    "status": "approved",
    "remaining_balance": "10000.0",
    "created_at": "[timestamp]",
    "updated_at": "[timestamp]"
  }
}
```

**Step 9: Verify Account Balance After Loan**

```bash
curl -H "User-ID: 1" http://localhost:3000/accounts
```

Expected Response should show balance of "12000.0" (previous balance + loan amount).

**Step 10: Loan Payment Processing**

```bash
curl -X POST http://localhost:3000/loans/1/payment \
  -H "User-ID: 1" \
  -H "Content-Type: application/json" \
  -d '{"amount": 2000}'
```

Expected Response:
```json
{
  "message": "Payment successful",
  "remaining_balance": "8000.0"
}
```

#### Test Sequence 4: Error Handling Validation

**Step 11: Test Duplicate Account Prevention**

```bash
curl -X POST http://localhost:3000/accounts \
  -H "User-ID: 1"
```

Expected Response:
```json
{
  "error": "User already has an active account"
}
```

**Step 12: Test Invalid User Operations**

```bash
curl -X POST http://localhost:3000/accounts/1/deposit \
  -H "User-ID: 999" \
  -H "Content-Type: application/json" \
  -d '{"amount": 100}'
```

Expected Response:
```json
{
  "error": "No active account found"
}
```

**Step 13: Test Negative Amount Validation**

```bash
curl -X POST http://localhost:3000/accounts/1/deposit \
  -H "User-ID: 1" \
  -H "Content-Type: application/json" \
  -d '{"amount": -500}'
```

Expected Response:
```json
{
  "error": "Invalid deposit amount"
}
```

#### Test Sequence 5: Multi-User Scenario

**Step 14: Create Second User**

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "Michael Chen",
      "email": "michael.chen@example.com"
    }
  }'
```

**Step 15: Create Account for Second User**

```bash
curl -X POST http://localhost:3000/accounts \
  -H "User-ID: 2"
```

**Step 16: Test Large Loan Application**

```bash
curl -X POST http://localhost:3000/loans \
  -H "User-ID: 2" \
  -H "Content-Type: application/json" \
  -d '{
    "loan": {
      "amount": 300000
    }
  }'
```

This should be rejected due to insufficient bank funds.

### Method 2: Web Interface Testing

Navigate to `http://localhost:3000` in your web browser to access the interactive testing interface.

The web interface provides:
- Visual feedback for all operations
- Automatic error handling display
- Real-time bank status updates
- Step-by-step guided testing process

### Method 3: Automated Test Suite

Execute the complete RSpec test suite:

```bash
bundle exec rspec --format documentation
```

For specific test categories:

```bash
# Test only model validations
bundle exec rspec spec/models/

# Test only API endpoints
bundle exec rspec spec/requests/

# Test with coverage report
bundle exec rspec --format progress
```

## Testing Logic Verification

### Fund Calculation Logic

The bank's available funds follow this formula:
```
Total Available Funds = Initial Capital ($250,000) + (Customer Deposits × 0.25) - Outstanding Loans
```

To verify this logic:

1. Check initial bank status (should show $250,000)
2. Make customer deposits and verify fund increase by 25% of
