# Terraform / OpenTofu standards

Canonical sources:
- HashiCorp Terraform Style Guide:
  https://developer.hashicorp.com/terraform/language/style
- Module structure & best practices:
  https://developer.hashicorp.com/terraform/language/modules/develop/structure

## Tooling (run before "done")
- **`terraform fmt`** (canonical formatting — never hand-format).
- **`terraform validate`** + a `plan` review; never blind-`apply`.
- **tflint** for provider-aware linting; **terraform-docs** to generate docs.
- **tfsec** / **checkov** for security scanning of resources.

## File layout (per module)
- `main.tf` (resources), `variables.tf`, `outputs.tf`, `versions.tf`
  (`required_version` + pinned `required_providers`). `locals.tf` if large.
- Keep modules small and composable; a root module wires them together.

## Style
- `snake_case` for resource names, variables, outputs, and locals.
- Resource local names describe the role, not the type: `aws_instance.web`,
  not `aws_instance.aws_instance`. Don't repeat the type in the name.
- Declare every variable with a `type` and `description`; add `default` only
  when a sensible one exists; `validation` blocks for constrained inputs.
- Every output has a `description`. Mark sensitive outputs `sensitive = true`.
- Prefer `for_each` over `count` for keyed sets (stable addresses on change).

## State & safety
- **Remote, locked state** (S3+DynamoDB, Terraform Cloud, etc.) — never commit
  `.tfstate` or `.terraform/` to git.
- **Pin versions**: `required_version` and provider version constraints (`~>`).
- **No secrets in code or state-visible plaintext.** Use a secrets manager /
  vault data sources; mark variables `sensitive = true`.
- Tag resources consistently (owner, env, cost-center) via a shared `locals`.
- Avoid hardcoded IDs/regions — parameterize via variables.
- Idempotent by design: a second `apply` with no changes must be a no-op plan.
