# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ghost is an open source, professional publishing platform built on Node.js. It's a modern CMS for building websites, publishing content, sending newsletters, and managing memberships.

**Tech Stack:**
- Backend: Node.js (18.12.1+) with Express.js
- Database: MySQL/SQLite via Bookshelf.js ORM
- Admin Panel: Ember.js (legacy) migrating to React
- Modern Apps: React with TypeScript, Vite, Tailwind CSS
- Build System: Nx monorepo with Yarn workspaces

## Common Development Commands

### Development
```bash
# Start full development environment
yarn dev

# Start only Ghost core
yarn dev:ghost

# Start only Admin panel
yarn dev:admin

# Run with debug logging
yarn dev:debug
```

### Testing
```bash
# Run all tests
yarn test

# Run specific test types
yarn test:unit        # Unit tests only
yarn test:integration # Integration tests
yarn test:e2e        # End-to-end tests
yarn test:browser    # Browser tests

# Run single test file with extended timeout
yarn test:single path/to/test.js

# Run tests in Docker
yarn docker:test:unit
```

### Build & Lint
```bash
# Build everything
yarn build

# Lint code
yarn lint

# Type checking
yarn lint:types

# Fix common issues
yarn fix
```

### Database Management
```bash
# Run migrations
yarn knex-migrator

# Reset with sample data
yarn reset:data

# Reset with empty database
yarn reset:data:empty
```

## Architecture Overview

### Directory Structure
```
Ghost/
├── ghost/
│   ├── core/          # Main Ghost application
│   │   ├── core/      # Server code
│   │   ├── content/   # User content (themes, images)
│   │   └── test/      # Test files
│   ├── admin/         # Ember.js admin panel (legacy)
│   └── i18n/          # Translations
├── apps/              # Modern React applications
│   ├── admin-x-*/     # New admin panel components
│   ├── portal/        # Member portal
│   ├── comments-ui/   # Comments system
│   └── sodo-search/   # Search functionality
└── e2e/               # End-to-end tests
```

### Core Architecture Patterns

1. **Service Layer Pattern**: Business logic is encapsulated in services (`/ghost/core/core/server/services/`)
2. **Event-Driven Architecture**: Extensive use of events for decoupling components
3. **Adapter Pattern**: Used for storage, cache, email providers, and SSO
4. **Express App Composition**: Modular Express apps for frontend, admin, and APIs

### API Structure
- **Content API** (`/api/content/`): Public read-only API
- **Admin API** (`/api/admin/`): Full CRUD operations
- APIs are versioned and RESTful

### Key Services
- **Members**: Subscription management with Stripe integration
- **Email**: Bulk sending with analytics
- **Theme Engine**: Handlebars-based templating
- **URL Service**: Dynamic routing and URL generation
- **Settings**: Centralized configuration management

## Development Guidelines

### Commit Messages
Follow gitmoji convention with these emojis:
- ✨ Feature
- 🎨 Improvement/change
- 🐛 Bug Fix
- 🌐 i18n submissions
- 💡 Other user-facing changes

Format:
```
[emoji] Short summary in past tense

ref/fixes/closes #issue
Why this change was made
```

### Testing Requirements
- All new features must have tests
- Run `yarn test` before submitting PRs
- Browser tests use Playwright
- Unit/integration tests use Mocha

### Code Style
- Follow existing patterns in the codebase
- Use services for business logic
- Emit events for cross-cutting concerns
- Keep controllers thin
- Use dependency injection for testability

### Working with Themes
- Themes use Handlebars templating
- Located in `/ghost/core/content/themes/`
- Test with different themes before changes
- Respect theme API contracts

### Database Changes
- Create migrations for schema changes
- Test migrations up and down
- Use knex-migrator for migration management
- Consider performance impacts

## Important Notes

1. **Monorepo Structure**: This is a Yarn workspace monorepo. Dependencies are hoisted to root.
2. **Active Migration**: Admin panel is migrating from Ember.js to React (admin-x-* apps)
3. **Ghost CLI**: Production deployments use Ghost-CLI, not this development setup
4. **Node Version**: Requires Node.js ^18.12.1 || ^20.11.1 || ^22.13.1
5. **Primary Branch**: `main` contains latest changes (not stable). Stable versions are tagged.

## Debugging Tips

- Use `yarn dev:debug` for verbose logging
- Check `/ghost/core/content/logs/` for log files
- Use `yarn docker:shell` to debug in Docker environment
- Browser DevTools for frontend debugging
- Use `yarn test:single` for focused test debugging