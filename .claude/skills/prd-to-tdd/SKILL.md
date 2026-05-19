# PRD to Technical Design Document (TDD) Skill

**Version**: 1.0  
**Purpose**: Transform Product Requirements Documents into comprehensive, architecture-aligned Technical Design Documents  
**Scope**: Full-stack design documentation with repository context integration  

---

## Overview

This skill processes Product Requirements Documents (PRDs) and generates structured Technical Design Documents (TDDs) that serve as blueprints for implementation. The process includes automated repository context discovery, architecture analysis, and interactive refinement checkpoints.

### Key Capabilities

- **PRD Analysis**: Extract requirements, user stories, and success criteria
- **Repository Context Discovery**: Automated analysis using git and find commands
- **Architecture Alignment**: Ensure consistency with existing codebase patterns
- **Structured TDD Generation**: Multi-section design documentation
- **Interactive Refinement**: Checkpoint-based feedback loops for human review
- **Risk Assessment**: Identify technical risks and mitigation strategies

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────┐
│  Phase 1: Input Validation & Context Discovery         │
│  ├─ Validate PRD existence and format                  │
│  ├─ Extract feature metadata                           │
│  ├─ Execute repository discovery commands              │
│  └─ Generate context analysis report                   │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│  Phase 2: Initial TDD Generation                        │
│  ├─ Extract requirements from PRD                      │
│  ├─ Generate architecture proposal                     │
│  ├─ Define component specifications                    │
│  ├─ Design data models                                 │
│  └─ Draft API specifications                           │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│  Phase 3: Interactive Refinement Loop                   │
│  ├─ Checkpoint 1: Architecture Review                  │
│  ├─ Checkpoint 2: Component Design                     │
│  ├─ Checkpoint 3: Data Model                           │
│  ├─ Checkpoint 4: API Specifications                   │
│  ├─ Checkpoint 5: Security & Performance               │
│  └─ Checkpoint 6: Implementation Plan                  │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│  Phase 4: Finalization & Delivery                       │
│  ├─ Consolidate feedback                               │
│  ├─ Generate final TDD document                        │
│  ├─ Create context reference report                    │
│  └─ Display implementation checklist                   │
└─────────────────────────────────────────────────────────┘
```

---

## Repository Context Discovery

### Git Commands

```bash
# Retrieve remote URL and authentication
git config --get remote.origin.url

# Identify current branch and commit context
git rev-parse --abbrev-ref HEAD
git log -1 --format='%h - %s'

# Find architecture-related commits
git log --oneline --all --grep="architecture|design|refactor"

# Analyze directory structure for patterns
git ls-tree -r --name-only HEAD | head -100
```

### Find Commands for Technology Stack Detection

```bash
# Package managers and dependency files
find . -maxdepth 2 -type f \(
  -name "package.json" \
  -o -name "requirements.txt" \
  -o -name "go.mod" \
  -o -name "pom.xml" \
  -o -name "build.gradle" \
  -o -name "Cargo.toml" \
  -o -name "mix.exs" \
  -o -name "Gemfile" \
\)

# Infrastructure & configuration
find . -maxdepth 2 -type f \(
  -name "*.env*" \
  -o -name "Dockerfile" \
  -o -name "docker-compose.yml" \
  -o -name "kubernetes/*.yaml" \
  -o -name "terraform/*.tf" \
  -o -name ".github/workflows/*.yml" \
\)

# Architecture patterns and structures
find ./src -type d 2>/dev/null
find . -maxdepth 2 -type d \(
  -name "controllers" \
  -o -name "services" \
  -o -name "repositories" \
  -o -name "models" \
  -o -name "entities" \
  -o -name "middlewares" \
\)

# Documentation index
find . -name "*.md" \(
  -path "*/docs/*" \
  -o -name "ARCHITECTURE*" \
  -o -name "DESIGN*" \
  -o -name "ADR*" \
\)

# Existing design decisions
find . -name "ADR-*.md" -o -name "decision-*.md"
```

### File Type Distribution

```bash
find . ! -path '*/\.*' ! -path '*/node_modules/*' ! -path '*/.git/*' \
  -type f 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn
```

---

## TDD Template Structure

### 1. Executive Summary
- **Purpose**: Single-page overview of the design
- **Content**:
  - Problem statement from PRD
  - Proposed solution approach
  - Key technical decisions
  - Success metrics and KPIs
  - Timeline and resource requirements

### 2. Requirements Alignment
- **Purpose**: Trace PRD requirements to design decisions
- **Sections**:
  - Functional requirements mapping
  - Non-functional requirements analysis
  - Acceptance criteria validation
  - Out-of-scope clarifications

### 3. Architecture Overview
- **Purpose**: High-level system design
- **Diagrams**:
  - C4 Context diagram
  - System architecture diagram
  - Component diagram
  - Deployment architecture
- **Content**:
  - Architectural style (monolith, microservices, etc.)
  - Reasoning for architecture choice
  - Alignment with existing patterns
  - Key architectural principles

### 4. Component Specifications
- **Purpose**: Detailed design of each component
- **For Each Component**:
  - Component name and purpose
  - Responsibilities and single responsibility principle compliance
  - Dependencies and interfaces
  - Technology stack selection (with rationale)
  - Performance characteristics
  - Error handling and resilience strategy

### 5. Data Model & Schema
- **Purpose**: Database and data structure design
- **Sections**:
  - Entity-relationship diagram (ERD)
  - Schema definitions (tables, collections, documents)
  - Indexing strategy
  - Data retention policy
  - Migration strategy (if modifying existing schema)
  - Caching strategy and TTL considerations

### 6. API Specifications
- **Purpose**: Contract definitions for external and internal APIs
- **For Each Endpoint**:
  - HTTP method and path
  - Authentication and authorization requirements
  - Request schema (with examples)
  - Response schema (with examples)
  - Error responses and codes
  - Rate limiting and quotas
  - Versioning strategy

### 7. Integration Points
- **Purpose**: External system connections
- **For Each Integration**:
  - System name and purpose
  - Integration pattern (REST, gRPC, webhooks, etc.)
  - Authentication mechanism
  - Error handling and retry logic
  - Data transformation requirements
  - Fallback and degradation strategy

### 8. Security Considerations
- **Purpose**: Security design and threat mitigation
- **Sections**:
  - Authentication mechanism
  - Authorization and access control
  - Data encryption (in transit and at rest)
  - Input validation and sanitization
  - OWASP top 10 mitigations
  - Security audit and logging requirements
  - Secrets management strategy
  - Vulnerability assessment process

### 9. Performance & Scalability
- **Purpose**: Non-functional requirements and optimization strategies
- **Sections**:
  - Expected load and scale metrics
  - Response time targets (p50, p95, p99)
  - Throughput requirements
  - Caching strategy
  - Database query optimization
  - Horizontal and vertical scaling approach
  - Load balancing strategy
  - CDN and edge considerations

### 10. Deployment & Operations
- **Purpose**: Production deployment and monitoring
- **Sections**:
  - Deployment topology
  - Continuous integration/deployment pipeline
  - Environment configuration (dev, staging, production)
  - Database migration strategy
  - Rollback plan
  - Monitoring and alerting strategy
  - Logging and observability
  - Operational runbooks

### 11. Testing Strategy
- **Purpose**: Quality assurance approach
- **Sections**:
  - Unit test coverage targets
  - Integration test scenarios
  - End-to-end test coverage
  - Performance test baselines
  - Security test requirements
  - Load test scenarios
  - User acceptance test plan

### 12. Risk Assessment & Mitigation
- **Purpose**: Identify and manage technical risks
- **For Each Risk**:
  - Risk description and likelihood
  - Potential impact
  - Mitigation strategy
  - Contingency plan
  - Owner and review date

### 13. Implementation Roadmap
- **Purpose**: Phased implementation plan
- **Phases**:
  - Phase 1 (MVP): Core features, timeline, deliverables
  - Phase 2 (Enhancements): Additional features
  - Phase 3+ (Optimization): Performance and scale improvements
- **For Each Phase**:
  - Epic descriptions
  - Story breakdown
  - Dependencies and blockers
  - Resource allocation
  - Acceptance criteria

### 14. Alternative Approaches (Optional)
- **Purpose**: Document considered alternatives
- **For Each Alternative**:
  - Approach description
  - Pros and cons
  - Reasoning for rejection or acceptance

### 15. Open Questions & Decisions
- **Purpose**: Track unresolved design decisions
- **For Each Item**:
  - Question or decision point
  - Options and trade-offs
  - Recommended approach
  - Owner and decision deadline

### 16. Appendices
- **Sections**:
  - Glossary of technical terms
  - Reference implementations
  - Related ADRs and RFCs
  - External documentation links
  - Team contacts and roles

---

## PRD Analysis Instructions

### Extract Key Information

```markdown
### From PRD Title and Summary
- Primary feature being built
- Target user/stakeholder group
- Business impact and success metrics

### From User Stories
- User roles and personas
- User goals and workflows
- Acceptance criteria and edge cases

### From Requirements Section
- Functional requirements (must have vs nice to have)
- Non-functional requirements (performance, scale, availability)
- Constraints and dependencies
- External integrations needed

### From Success Metrics
- KPIs that indicate success
- Performance thresholds
- Scale requirements
- Availability targets
```

---

## Architecture Decision Making

### Apply These Principles

1. **Alignment with Existing Patterns**
   - Analyze codebase architecture patterns
   - Maintain consistency with established conventions
   - Document when departing from patterns (with reasoning)

2. **Technology Stack Compatibility**
   - Use languages and frameworks already in the codebase
   - Consider team expertise and learning curve
   - Evaluate dependency compatibility

3. **Scalability and Performance**
   - Design for the projected scale in 1, 5, 10 years
   - Identify potential bottlenecks early
   - Plan for horizontal scaling

4. **Operational Excellence**
   - Design with monitoring and observability
   - Plan for graceful degradation
   - Document operational procedures

5. **Security by Design**
   - Threat modeling for new components
   - Principle of least privilege
   - Defense in depth approach

6. **Team Velocity**
   - Balance perfection with pragmatism
   - Consider team capacity and timeline
   - Identify technical debt trade-offs

---

## Quality Checklist

### Completeness Verification

- [ ] All PRD requirements are explicitly addressed
- [ ] Architecture aligns with existing codebase patterns
- [ ] Each component has clear responsibility boundaries
- [ ] Data model is normalized (3NF minimum)
- [ ] All external integrations documented
- [ ] Security considerations documented for each component
- [ ] Performance targets defined and justified
- [ ] Deployment topology clearly defined
- [ ] Monitoring and alerting strategy documented
- [ ] Testing strategy covers all critical paths

### Clarity Verification

- [ ] Architecture can be understood by new team members
- [ ] Component diagrams support text descriptions
- [ ] API specifications are complete and unambiguous
- [ ] Data model includes all field definitions and constraints
- [ ] Implementation roadmap has clear phases and deliverables
- [ ] Risk mitigation strategies are actionable

### Feasibility Verification

- [ ] Design can be implemented within project timeline
- [ ] Team has required skills or training plan exists
- [ ] Required infrastructure/tools are available
- [ ] Dependencies are realistic and documented
- [ ] No single point of failure without mitigation

### Alignment Verification

- [ ] Technical decisions align with business objectives
- [ ] Performance targets align with user expectations
- [ ] Security requirements align with compliance needs
- [ ] Operational requirements align with team capabilities
- [ ] Technology choices align with organizational standards

---

## Usage Example

```bash
# Basic execution with interactive prompts
./scripts/generate-tdd.sh --prd-file path/to/PRD.md

# Specify output and feature name
./scripts/generate-tdd.sh \
  --prd-file docs/PRD_UserAuth.md \
  --feature-name user_authentication \
  --output ./docs/technical-designs

# Automated execution for CI/CD
./scripts/generate-tdd.sh \
  --prd-file PRD.md \
  --feature-name payment_service \
  --skip-confirmation
```

---

## Output Artifacts

### 1. Technical Design Document (TDD_{feature}_{timestamp}.md)
- Comprehensive design documentation
- ~50-100 pages typical length
- Serves as implementation reference
- Updated as design decisions solidify

### 2. Repository Context Report (CONTEXT_{feature}_{timestamp}.md)
- Technology stack analysis
- Architecture patterns identified
- Documentation inventory
- Useful for onboarding and reference

### 3. Implementation Checklist
- Phase-by-phase task breakdown
- Resource allocation guide
- Risk mitigation actions
- Success criteria

---

## Best Practices

### For PRD Authors
- Provide clear success metrics
- Include user stories with acceptance criteria
- Document constraints and dependencies early
- Identify external integrations needed

### For TDD Reviewers
- Verify all requirements are addressed
- Validate architecture against scalability needs
- Assess security completeness
- Challenge assumptions and trade-offs
- Request clarifications on ambiguous sections

### For Implementation Teams
- Use TDD as the blueprint for code structure
- Create GitHub issues directly from roadmap phases
- Link ADRs to TDD sections
- Document deviations and reasoning
- Update TDD as learnings emerge

---

## Integration with Development Workflow

### GitHub Actions
```yaml
- name: Generate TDD from PRD
  run: |
    ./scripts/generate-tdd.sh \
      --prd-file ${{ github.event.pull_request.body }} \
      --feature-name ${{ env.FEATURE }} \
      --skip-confirmation
```

### Manual Workflow
1. Author creates PRD and links to issue
2. Architect runs TDD generation script
3. TDD is reviewed in team meeting
4. Approved TDD is linked in GitHub discussions
5. Implementation tasks are created from roadmap
6. TDD is referenced in code reviews

---

## Troubleshooting

### Common Issues

**Issue**: Script fails to find repository context
- **Solution**: Ensure you're running from repository root
- **Verify**: `git rev-parse --show-toplevel`

**Issue**: Generated TDD is incomplete
- **Solution**: Manually complete sections marked with "TODO"
- **Process**: Use interactive checkpoints to refine each section

**Issue**: Architecture doesn't match codebase patterns
- **Solution**: Review repository's existing ADRs and architecture
- **Verify**: Check `.claude/skills` for existing patterns

**Issue**: PRD file not recognized
- **Solution**: Ensure PRD is in Markdown format
- **Verify**: File should be `.md` extension

---

## Extension Points

This skill can be extended for:
- **Microservices Architecture**: Component becomes service with API boundaries
- **API-First Development**: API specs generated from data model
- **Infrastructure as Code**: Deployment sections can generate Terraform configs
- **Compliance Requirements**: Additional security and audit sections
- **Internationalization**: Multi-language and multi-region considerations

---

## Related Skills & Resources

- **Architecture Decision Records (ADRs)**: Document individual decisions
- **C4 Model**: Component diagram methodology
- **Design Patterns**: Common architecture patterns reference
- **Security Checklist**: OWASP and other security frameworks
- **Performance Optimization**: Scalability and caching patterns

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-19 | Initial release with full PRD-to-TDD pipeline |

---

## Support & Feedback

For issues or improvements to this skill:
1. Create an issue in the repository
2. Reference this skill document
3. Include example PRD and generated TDD
4. Describe the gap or improvement needed
