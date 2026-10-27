# Git Commit Naming Conventions

This repository follows conventional commit message format to maintain clear, searchable commit history.

## Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Commit Types

- **feat** - New feature or functionality
- **fix** - Bug fix
- **docs** - Documentation changes
- **refactor** - Code restructuring without changing functionality
- **chore** - Maintenance tasks, dependency updates
- **ci** - CI/CD workflow changes
- **ai** - AI agent documentation or tooling changes
- **test** - Adding or updating tests (if used)

## Scope

Scope indicates the area of the codebase affected. Multiple scopes can be used when changes affect multiple areas:

- **aws** - AWS provider/infrastructure (Terraform, EKS, ECR, Route53)
- **gcp** - Google Cloud provider/infrastructure (Terraform, GKE, Artifact Registry, Cloud DNS)
- **app** - Application manifests
- **k3d** - k3d local development environment
- **argocd** - ArgoCD application or configuration changes
- **cnpg** - CloudNativePG operator
- **deps** - Dependency updates
- **global** - Repository-wide changes

## Examples

```
feat(aws): Add ECR repository
feat(aws, app): Add AWS overlay for sample app
fix(aws): Tag public subnets for Load Balancer controller
refactor(aws): Split files in EKS module
chore(deps): Update terraform aws to v6
ci(aws, argocd): Bootstrap ArgoCD in AWS workflow
ai(global): Add initial Agent documentation
```

## Subject Line Rules

- Use imperative mood ("Add" not "added" or "adds")
- First letter capitalized
- No period at the end
- Maximum 72 characters
- Be specific and descriptive

## Body (Optional)

Use body for:
- Explaining what and why (not how)
- Reference to issues/PRs

```
feat(app): Add new application

Add sample-app with base manifests, provider configurations,
and environment overlays for aws-prod and k3d-dev.

Closes #123
```

## Footer (Optional)

Use footer for:
- Issue references: `Closes #123`, `Fixes #456`

## Best Practices

1. **Be specific** - "add ECR repository" not "update AWS"
2. **Use correct type** - Match the type to the actual change
3. **Include scope** - Helps identify affected area quickly
4. **Keep it concise** - Subject should be clear in isolation
5. **Reference issues** - Link to related issues or PRs when applicable

## GitOps Considerations

Since ArgoCD syncs from `main` branch:
- Each commit to `main` triggers deployment
- Commit messages should clearly indicate deployment impact
- Use `feat` and `fix` types to indicate user-visible changes
- Use `chore` and `refactor` for non-deployment changes
