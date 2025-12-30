# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.4] - 2025-12-30

### Changes
**Added**
* Support for sending template messages and invoices as two separate Telegram messages.
* Jinja2 template support for all invoice amount fields, including prices and tips.
* Automatic `.env` file loading for all CLI commands.
* New invoice examples covering template-based and invoice-only flows.
**Fixed**
* Issue where configuring both template and invoice sent only the invoice.
* Crashes caused by using template strings in invoice amount fields.
* CLI commands failing when environment variables were only defined in `.env`.
**Changed**
* Invoice configuration models now accept both `int` and template `str` values.
* Runtime rendering and type conversion for invoice amounts.
* Updated documentation to reflect new invoice behavior and `.env` handling.
**Security**
* No changes; fully backward compatible with existing configurations.

## [0.0.3] - 2025-12-29

### Changes
**Added**
* Complete invoice and payment support compliant with Telegram Bot API.
* InvoiceConfig and LabeledPrice models with full template support.
* send_invoice integration for Telegram Stars and traditional currencies.
* Automatic pay button text replacement for ⭐️ and XTR.
* Comprehensive invoice examples and documentation.
**Fixed**
* Enforced pay and callback_game buttons to be first in the first row.
* Clear validation errors for invalid button placement.
* Correct handling of provider tokens for Telegram Stars.
**Changed**
* Extended EndpointConfig to support invoices.
* Updated routing to handle invoice sending and validation.
* Expanded test coverage for payments, validation, and text replacement.
**Security**
* Provider tokens restricted to environment variables.
* Strict validation to prevent non-compliant payment configurations.

## [0.0.2] - 2025-12-29

### Changes
### Added
- Support for reply keyboard markup, including text buttons, special request buttons (contact, location, poll, web_app), customization options (resize, one_time, persistent), input field placeholder, and keyboard removal
- Force reply functionality via reply markup
- Document sending with caption, custom filename, parse mode, and reply markup support
- Video sending with caption, thumbnail, metadata (width, height, duration), and streaming support flag
- Audio sending with metadata (title, performer, duration), thumbnail, and caption support
- Voice message sending with duration and caption support
- Location sharing, including static GPS coordinates, live location tracking with duration, horizontal accuracy, heading, and proximity alert radius
### Changed
- Extended reply markup support across document, video, audio, voice, and location messages

## [0.0.2] - 2025-12-29

### Changes
docs/RELEASE_NOTES.md

## [0.0.1] - 2025-12-29

### Changes
docs/RELEASE_NOTES.md

## [0.0.1] - 2025-12-29

### 🎉 Initial Release - FastBotty v0.0.1

This is the initial release of **FastBotty** v0.0.1. It is a simple, fast, and easy to use bot framework for Telegram.

### What's Changed

- **Project Name**: FastBotty
- **Version**: v0.0.1
- **Package Name**: `pip install fastbotty`
- **CLI Command**: `fastbotty`
- **Repository**: Moved to [venopyx/fastbotty](https://github.com/venopyx/fastbotty)

### Current Features

- Easy setup and configuration
- Plugin architecture for extensible formatters
- Supports all Telegram chat types
- Broadcast messaging to multiple chats
- Image and photo gallery support
- Interactive inline keyboards with all button types
- Command and callback handlers
- Jinja2 templating for message customization
- API key authentication
- Automatic retries with exponential backoff

### Install

```bash
pip install fastbotty
```

### Links

- **PyPI**: [pypi.org/project/fastbotty/](https://pypi.org/project/fastbotty/)
- **Documentation**: [github.com/venopyx/fastbotty#readme](https://github.com/venopyx/fastbotty#readme)
- **Roadmap**: [docs/FUTURE.md](https://github.com/venopyx/fastbotty/blob/main/docs/FUTURE.md)