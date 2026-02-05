# Archetype: Java Spring Boot Backend (Demo)

## 1. Target Stack
- Language: Java 21
- Framework: Spring Boot 3.x (Spring 6)
- Build: Maven
- Persistence: JPA (Hibernate)
- DB: PostgreSQL (or configurable)
- Migrations: Flyway
- API Style: REST (JSON)
- Validation: Jakarta Validation (jakarta.validation)
- Documentation: OpenAPI/Swagger (springdoc-openapi)
- Logging: SLF4J + Logback

## 2. Project Structure
Use this folder structure:

- src/main/java/com/company/demo/
  - controller/
  - service/
  - repository/
  - domain/entity/
  - domain/dto/
  - domain/mapper/
  - exception/
  - config/
- src/main/resources/
  - application.yml
  - db/migration/   (Flyway)
- src/test/java/com/company/demo/

## 3. Naming Conventions
- Entities: PascalCase singular (e.g., AccountBalance)
- Table names: snake_case plural (e.g., account_balances)
- Columns: snake_case (e.g., acct_id, bal_date)
- DTOs:
  - CreateXxxRequestDto
  - UpdateXxxRequestDto
  - XxxResponseDto
- Controllers: XxxController
- Services: XxxService
- Repositories: XxxRepository

## 4. Layer Patterns

### 4.1 Entity Layer Pattern
- Package: `com.company.demo.domain.entity`
- Use JPA annotations:
  - @Entity
  - @Table(name="...")
  - @Id + @GeneratedValue(strategy = GenerationType.IDENTITY) OR natural key if specified
  - @Column(nullable=..., length=..., precision=..., scale=...)
- Types mapping:
  - string -> String
  - integer -> Integer / Long (choose Long for ids)
  - decimal -> BigDecimal
  - date -> LocalDate
  - datetime -> LocalDateTime
- Relationships:
  - @ManyToOne / @OneToMany / @OneToOne as needed
  - Use LAZY for collections
- Must include:
  - constructors
  - getters/setters (or Lombok @Getter/@Setter if allowed)
  - equals/hashCode (based on id)

### 4.2 DTO Layer Pattern
- Package: `com.company.demo.domain.dto`
- Each DTO in its own file.
- Must include validation annotations:
  - @NotBlank, @NotNull, @Size, @Digits, etc.
- Response DTOs should be immutable if possible (record) or classic POJO.

### 4.3 Repository Layer Pattern
- Package: `com.company.demo.repository`
- Interface extends JpaRepository<Entity, IdType>
- Add finder methods required by business rules (derived queries or @Query)

### 4.4 Service Layer Pattern
- Package: `com.company.demo.service`
- @Service
- Transactional boundaries:
  - @Transactional(readOnly=true) for read
  - @Transactional for write
- Must implement:
  - all business rules logic
  - all validations not covered by DTO annotations
  - workflows step-by-step as described in business rules
- Error mapping:
  - throw custom exceptions in `exception/`

### 4.5 Controller Layer Pattern
- Package: `com.company.demo.controller`
- @RestController + @RequestMapping("/api/v1")
- CRUD endpoints per entity:
  - GET /{entities} (list)
  - GET /{entities}/{id}
  - POST /{entities}
  - PUT /{entities}/{id}
  - DELETE /{entities}/{id}
- Use proper status codes:
  - 200, 201, 204, 400, 404, 409, 500
- OpenAPI annotations:
  - @Operation(summary=..., description=...)
  - @ApiResponses(...)
- Use DTOs for requests/responses (never expose Entity directly)

## 5. Database & Migrations (Flyway)
- Location: `src/main/resources/db/migration`
- Naming: `V{timestamp}__create_{table}.sql`
- Must include:
  - create table with columns for all entity attributes
  - primary key
  - foreign keys for relationships
  - indexes for query fields used in business rules

## 6. Error Handling
- Create custom exceptions in `com.company.demo.exception`
  - NotFoundException
  - BadRequestException
  - ConflictException
  - ExternalServiceException
- Global handler:
  - @RestControllerAdvice
  - Standard error response:
    - timestamp
    - status
    - error
    - message
    - path

## 7. Security
- If roles/permissions exist in business rules:
  - annotate endpoints with @PreAuthorize("hasRole('...')")
- Otherwise leave security hooks in place but do not block all endpoints by default.

## 8. Testing
- Unit tests for services with JUnit 5 + Mockito
- Basic controller tests if required
- Ensure compilation and basic coverage for main flows

## 9. Non-Functional Requirements
- Logging at key steps (start/end of workflow, errors)
- Input validation first
- No hardcoded secrets
- Keep code clean and production-ready

## 10. Output Rules
- All generated files must be written inside the repository path provided by the agent.
- Do not create files outside repo.
