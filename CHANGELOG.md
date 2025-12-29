# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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