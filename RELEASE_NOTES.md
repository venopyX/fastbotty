v1.0.4 – Payment & Invoice Support

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
