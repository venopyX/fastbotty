### v0.0.4 – Invoice Templates, Message Separation, and .env Support

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
