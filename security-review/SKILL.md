---
name: security-review
description: CRITICAL - Security gate for all skills execution. This skill MUST pass before any other skill can execute. Use PROACTIVELY when adding authentication, handling user input, working with secrets, creating API endpoints, or implementing payment/sensitive features. Blocks execution on security violations.
priority: critical
version: 1.0.0
---

# Security Review - Skills Execution Gate

This skill serves as the **mandatory security checkpoint** for all Claude Code operations. No skill should execute until security validation passes.

## Core Principle

> **Security is not optional.** One vulnerability can compromise the entire system. When in doubt, block execution.

## Gate Protocol

### Pre-Execution Security Check

Before executing ANY skill or significant code change:

```
┌─────────────────────────────────────────────────────────────┐
│  SECURITY GATE CHECKLIST                                     │
│                                                              │
│  □ Secrets Management     - No hardcoded secrets             │
│  □ Input Validation       - All inputs validated             │
│  □ SQL Injection          - Parameterized queries only       │
│  □ XSS Prevention         - Output sanitized                 │
│  □ Authentication         - Proper token handling            │
│  □ Authorization          - Access controls verified          │
│  □ Rate Limiting          - API endpoints protected          │
│  □ Error Handling         - No sensitive data in errors      │
│                                                              │
│  ALL CHECKS MUST PASS TO PROCEED                             │
└─────────────────────────────────────────────────────────────┘
```

## Security Checklist by Category

### 1. Secrets Management (CRITICAL)

#### NEVER Do This
```typescript
const apiKey = "sk-proj-xxxxx"  // Hardcoded secret
const dbPassword = "password123" // In source code
```

#### ALWAYS Do This
```typescript
const apiKey = process.env.OPENAI_API_KEY
const dbUrl = process.env.DATABASE_URL

if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

#### Verification Steps
- [ ] No hardcoded API keys, tokens, or passwords
- [ ] All secrets in environment variables
- [ ] `.env.local` in .gitignore
- [ ] No secrets in git history

### 2. Input Validation (CRITICAL)

```typescript
import { z } from 'zod'

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150)
})

export async function createUser(input: unknown) {
  const validated = CreateUserSchema.parse(input)
  return await db.users.create(validated)
}
```

#### Verification Steps
- [ ] All user inputs validated with schemas
- [ ] File uploads restricted (size, type, extension)
- [ ] No direct use of user input in queries
- [ ] Whitelist validation (not blacklist)

### 3. SQL Injection Prevention (CRITICAL)

#### NEVER Concatenate SQL
```typescript
// DANGEROUS - SQL Injection vulnerability
const query = `SELECT * FROM users WHERE email = '${userEmail}'`
```

#### ALWAYS Use Parameterized Queries
```typescript
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('email', userEmail)

await db.query('SELECT * FROM users WHERE email = $1', [userEmail])
```

### 4. Authentication & Authorization (CRITICAL)

```typescript
// Tokens in httpOnly cookies (NOT localStorage)
res.setHeader('Set-Cookie',
  `token=${token}; HttpOnly; Secure; SameSite=Strict; Max-Age=3600`)

// Always verify authorization
if (requester.role !== 'admin') {
  return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
}
```

### 5. XSS Prevention (HIGH)

```typescript
import DOMPurify from 'isomorphic-dompurify'

function renderUserContent(html: string) {
  const clean = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p'],
    ALLOWED_ATTR: []
  })
  return <div dangerouslySetInnerHTML={{ __html: clean }} />
}
```

### 6. CSRF Protection (HIGH)

```typescript
// SameSite cookies
res.setHeader('Set-Cookie',
  `session=${sessionId}; HttpOnly; Secure; SameSite=Strict`)

// CSRF tokens on state-changing operations
if (!csrf.verify(token)) {
  return NextResponse.json({ error: 'Invalid CSRF token' }, { status: 403 })
}
```

### 7. Rate Limiting (HIGH)

```typescript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: 'Too many requests'
})

app.use('/api/', limiter)
```

### 8. Sensitive Data Exposure (MEDIUM)

```typescript
// NEVER log sensitive data
console.log('User login:', { email, userId })  // NOT password

// Generic error messages for users
catch (error) {
  console.error('Internal error:', error)
  return NextResponse.json(
    { error: 'An error occurred. Please try again.' },
    { status: 500 }
  )
}
```

## OWASP Top 10 Quick Reference

| # | Vulnerability | Block If |
|---|---------------|----------|
| 1 | Injection | String concatenation in SQL/commands |
| 2 | Broken Auth | Tokens in localStorage, weak passwords |
| 3 | Sensitive Data | Secrets in code, unencrypted PII |
| 4 | XXE | XML parsers without entity limits |
| 5 | Broken Access | Missing auth checks on routes |
| 6 | Misconfiguration | Debug mode in prod, default creds |
| 7 | XSS | Unsanitized user content |
| 8 | Insecure Deserialization | User input to eval/JSON.parse |
| 9 | Known Vulnerabilities | Outdated dependencies with CVEs |
| 10 | Insufficient Logging | No security event logging |

## Severity Levels & Actions

| Severity | Action |
|----------|--------|
| **CRITICAL** | Block immediately, require fix |
| **HIGH** | Block, warn user, suggest fix |
| **MEDIUM** | Warn, allow with acknowledgment |
| **LOW** | Log, suggest improvement |

## Pre-Deployment Checklist

Before ANY production deployment:

- [ ] **Secrets**: No hardcoded secrets, all in env vars
- [ ] **Input Validation**: All user inputs validated
- [ ] **SQL Injection**: All queries parameterized
- [ ] **XSS**: User content sanitized
- [ ] **CSRF**: Protection enabled
- [ ] **Authentication**: Proper token handling
- [ ] **Authorization**: Role checks in place
- [ ] **Rate Limiting**: Enabled on all endpoints
- [ ] **HTTPS**: Enforced in production
- [ ] **Security Headers**: CSP, X-Frame-Options configured
- [ ] **Error Handling**: No sensitive data in errors
- [ ] **Logging**: No sensitive data logged
- [ ] **Dependencies**: Up to date, no vulnerabilities (`npm audit`)

## Automated Security Commands

```bash
# Check for vulnerabilities
npm audit --audit-level=high

# ESLint security plugin
npx eslint . --plugin security

# Check for hardcoded secrets
grep -r "api[_-]*key\|password\|secret\|token" --include="*.ts" --include="*.js"

# Check for SQL injection patterns
grep -r "\$\{.*\}" --include="*.sql" --include="*.ts"
```

## Emergency Response

If a CRITICAL vulnerability is found:

1. **Document** - Create detailed vulnerability report
2. **Block** - Prevent code from executing/deploying
3. **Alert** - Notify project owner immediately
4. **Fix** - Provide secure code example
5. **Verify** - Confirm remediation works
6. **Rotate** - Rotate any exposed secrets

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [Next.js Security](https://nextjs.org/docs/security)
- [Web Security Academy](https://portswigger.net/web-security)

---

**Remember**: This gate exists to protect users and systems. When in doubt, block and ask for clarification.
