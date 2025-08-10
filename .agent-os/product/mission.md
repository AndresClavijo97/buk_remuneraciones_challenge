# Product Mission

> Last Updated: 2025-08-10
> Version: 1.0.0

## Pitch

Chilean Payroll System is a technical challenge API that helps developers demonstrate expertise in complex payroll calculations by providing accurate Chilean labor law compliance and tax computation capabilities.

## Users

### Primary Customers

- **Technical Recruiters**: HR professionals and hiring managers evaluating Ruby on Rails expertise for payroll/financial systems
- **Development Teams**: Software teams needing reference implementation for Chilean payroll compliance

### User Personas

**Technical Evaluator** (30-45 years old)
- **Role:** Senior Developer / Technical Lead
- **Context:** Assessing candidate technical skills for payroll system development
- **Pain Points:** Difficulty evaluating complex business logic implementation, ensuring compliance accuracy
- **Goals:** Verify technical competency, assess code quality and architecture decisions

## The Problem

### Complex Chilean Payroll Compliance

Chilean payroll calculations involve intricate tax brackets, AFP contributions, health insurance deductions, and legal gratifications that are difficult to implement correctly. Many developers struggle with the business logic complexity and regulatory compliance requirements.

**Our Solution:** A comprehensive Rails API demonstrating proper implementation of all Chilean payroll calculation requirements with clean architecture patterns.

### Technical Assessment Challenges

Evaluating a developer's ability to handle complex business rules, data modeling, and API design requires realistic scenarios. Simple CRUD applications don't demonstrate the depth of skills needed for financial systems.

**Our Solution:** A complete working system showcasing advanced Rails patterns, proper validation, and comprehensive testing strategies.

## Differentiators

### Complete Chilean Compliance

Unlike generic payroll examples, we provide full implementation of Chilean-specific regulations including progressive tax brackets, AFP calculations, and legal gratification rules with accurate formulas and edge case handling.

### Clean Architecture Patterns

Unlike monolithic approaches, we demonstrate layered design, value objects, and strategy patterns that extend Rails MVC for maintainable financial calculations.

### Production-Ready Structure

Unlike academic examples, we include comprehensive testing, security scanning with Brakeman, code quality with RuboCop, and deployment configuration with Kamal and Docker.

## Key Features

### Core Calculation Engine

- **Progressive Tax Calculation:** Accurate implementation of Chilean income tax brackets with proper threshold handling
- **AFP Contribution Processing:** Automatic calculation of pension fund contributions based on current rates
- **Health Insurance Deductions:** Support for FONASA and ISAPRE health insurance calculations
- **Legal Gratification Calculation:** Proper handling of mandatory year-end bonus calculations

### Data Management Features

- **Chilean RUT Validation:** Comprehensive validation of Chilean national identification numbers
- **Employee Data Models:** Well-structured ActiveRecord models with proper associations and validations
- **Payroll Period Management:** Support for monthly, bi-weekly, and custom payroll periods
- **Historical Calculation Storage:** Audit trail for all payroll calculations with versioning

### Technical Architecture Features

- **Value Object Pattern:** Clean domain modeling with immutable value objects for calculations
- **Strategy Pattern Implementation:** Flexible calculation strategies for different employee types
- **Layered Design Architecture:** Clean separation of concerns extending Rails MVC pattern
- **Comprehensive API Design:** RESTful endpoints with proper error handling and response formatting