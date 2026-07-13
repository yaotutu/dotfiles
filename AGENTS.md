# Repository Guidelines

## Zsh configuration layout

- `zsh/.zshrc` is only the bootstrap entry point for Zsh. Keep it limited to loading `$HOME/.config/zsh/zshrc`; do not add PATH entries, environment variables, aliases, functions, tool initialization, or machine-specific settings there.
- Put shared Zsh configuration that should be synchronized across machines in `zsh/.config/zsh/zshrc` or an appropriately scoped file sourced by it.
- Put machine-specific configuration that should not be synchronized across machines in `$HOME/.config/zsh/host.local.zsh`. This includes host-only SDK paths, application paths, local CLI paths, and environment variables tied to one machine.
- Before adding or changing Zsh configuration, classify it as shared or machine-specific and place it in the corresponding file. Do not use the root `.zshrc` as a general configuration file.
