# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Ruby on Rails API application for calculating Chilean payroll liquidations. The system handles employee data loading and payroll calculations including all legal deductions (AFP, health insurance, unemployment insurance, income tax) and benefits according to Chilean labor legislation.

## Development Commands

### Start the server
```bash
bin/rails s
```

### Run tests
```bash
bin/rails test
```

### Code analysis and linting
```bash
# Security analysis
bundle exec brakeman

# Code style checking
bundle exec rubocop
```

## API Architecture

The application is configured as API-only Rails app (`config.api_only = true`) with two main endpoints:

- `PUT /api/payrolls/load` - Load employee data, replacing all existing information
- `POST /api/payrolls/calculate` - Calculate payroll liquidations for specified employees by RUT

## Key Business Logic

### Chilean Payroll Calculations
- **Taxable Income Limit**: 81.6 UF for AFP and health contributions
- **Legal Gratification**: Monthly limit of 4.75 IMM/12
- **Legal Deductions**: AFP (10%), Health (7%), Unemployment Insurance (0.6%), Income Tax (progressive table)
- **Base Calculation Period**: Monthly calculations using June 2025 UF/UTM values

### Employee Data Structure
- RUT identification
- Base salary (sueldo_base_pactado)
- Health affiliation (Fonasa or Isapre with UF plan)
- Assignments array with taxable/non-taxable items (haberes/descuentos)

## Current Implementation Status

The project is in early development stage:
- Basic API controller structure exists (`app/controllers/api/payrolls_controller.rb`) with stub methods
- Routes configured for both endpoints
- Basic integration tests present
- No domain models or business logic implemented yet
- Uses standard Rails 8.0 structure with SQLite database

## Development Dependencies

- Ruby on Rails 8.0.2
- SQLite3 for database
- Puma web server
- Brakeman for security analysis
- RuboCop Rails Omakase for code style
- Solid Cache/Queue/Cable for Rails infrastructure

## Testing Framework

Uses RSpec testing framework with integration tests in `/test` directory. Current tests only verify endpoint accessibility, not business logic.

## Architecture

- Layered Design