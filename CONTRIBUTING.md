# 🚀 FastBotty Contributing & Development Guide

> **Read this FIRST before making any changes to the codebase!**

Thank you for your interest in contributing to FastBotty! This guide ensures your contributions are effective, maintainable, and align with the project’s standards.

---

## 📌 Before You Start

### 1. Understand the Codebase Architecture

```
fastbotty/
├── cli/              # CLI commands (init, run, validate, webhook)
├── core/             # Core business logic (bot, config, interfaces, registry)
├── formatters/       # Built-in message formatters (plain, markdown)
├── server/           # FastAPI server (app, routes)
└── utils/            # Utility functions (escape, validators)
```

### 2. Read Similar Files First
Before implementing a new feature, study the most similar existing implementation for patterns, imports, and structure.

**Examples:**
- Adding a new formatter? Look at `fastbotty/formatters/plain.py` and `markdown.py`.
- Adding a new config option? Study `fastbotty/core/config.py`.
- Adding a new CLI command? Check `fastbotty/cli/commands.py`.

### 3. Understand the Testing Architecture
Tests are in the `tests/` directory. Follow existing patterns:
- Use `pytest` with `pytest-asyncio` for async tests.
- Group related tests in classes.
- Use descriptive test names: `test_<what>_<expected_behavior>`.

---

## 🔧 Development Workflow

### Step 1: Set Up Environment

**Prerequisites:**
- Python 3.10+
- Git

```bash
git clone https://github.com/venopyx/fastbotty.git
cd fastbotty
make install
source .venv/bin/activate
```

### Step 2: Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### Step 3: Implement Your Changes
- Write code following existing patterns.
- Add type hints and docstrings.
- Update configuration models if adding new options.

### Step 4: Add Tests
- Create or update test files in `tests/`.
- Run your tests:
  ```bash
  python -m pytest tests/test_your_feature.py -v
  make test
  ```

### Step 5: Run All Checks
```bash
make check  # Runs format, lint, and test
```
**⚠️ Your PR will not be accepted if `make check` fails!**

### Step 6: Update Documentation
- Update `README.md` for major features.
- Update `docs/USAGE.md` for usage details.
- Add examples in config templates if relevant.

### Step 7: Write Release Notes
Add a concise entry to `CHANGELOG.md` under `[Unreleased]`:
```markdown
## [Unreleased]
### Added
- **Your Feature**: Brief description of what it does
```

### Step 8: Update `llms.txt`
**Make sure to update the `llms.txt` file** to reflect the changes you made for AI use. Add your feature support to `llms.txt` similarly to existing entries.

---

## 📋 Code Quality Checklist
Before submitting your PR, verify:
- [ ] `make check` passes completely.
- [ ] All new code has type hints and docstrings.
- [ ] Tests cover the new functionality.
- [ ] Documentation and `llms.txt` are updated.
- [ ] Release notes are added to `CHANGELOG.md`.
- [ ] Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).

---

## 🏗️ Common Patterns

### Adding a New Button Type
1. Add config model to `fastbotty/core/config.py`.
2. Add field to `ButtonConfig`.
3. Handle in `build_inline_keyboard()` in `fastbotty/server/routes.py`.
4. Add tests in `tests/test_buttons.py`.

### Adding a New Formatter
1. Create `fastbotty/formatters/your_formatter.py`.
2. Register in `fastbotty/formatters/__init__.py`.
3. Add tests in `tests/test_formatters.py`.

### Adding a New Config Option
1. Add Pydantic field to `config.py`.
2. Handle the option where it’s used.
3. Add tests for configuration loading.
4. Document in `docs/USAGE.md`.

---

## 🐛 Debugging Tips
- Enable debug logging in config:
  ```yaml
  logging:
    level: "DEBUG"
  ```
- Use test mode to avoid Telegram API calls:
  ```yaml
  bot:
    test_mode: true
  ```
- Run a single test:
  ```bash
  python -m pytest tests/test_file.py::TestClass::test_method -v
  ```

---

## 📚 Key Files to Know

| File | Purpose |
|------|---------|
| `fastbotty/core/config.py` | All configuration models |
| `fastbotty/core/bot.py` | Telegram API client |
| `fastbotty/server/routes.py` | Endpoint handling and keyboard building |
| `fastbotty/utils/escape.py` | Message escaping for parse modes |
| `tests/conftest.py` | Shared test fixtures |

---

## 🎯 Getting Help
- Check existing issues on GitHub.
- Review `docs/USAGE.md` for feature documentation.
- Study test files to understand expected behavior.

---

## 📝 Reporting Issues
When reporting bugs, include:
- Python version
- FastBotty version
- Operating system
- Steps to reproduce
- Expected vs actual behavior
- Error messages/logs

## 💡 Feature Requests
For feature requests:
- Describe the feature and its use case.
- Explain why it would be useful.
- Provide examples if possible.

## 🤝 Code of Conduct
- Be respectful and inclusive.
- Focus on constructive feedback.
- Help others learn and grow.
- Follow GitHub’s Community Guidelines.

## 📄 License
By contributing, you agree that your contributions will be licensed under the MIT License.

---

## ✨ Thank You!
Your contributions make FastBotty better. Following this guide helps maintain code quality and ensures your work can be merged quickly.

**Remember:**
- Always run `make check` before submitting.
- Update `llms.txt` for AI-related changes.
- Keep your PR focused and well-documented.

Happy coding! 🚀
