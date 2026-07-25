# Domeneshop

Domeneshop is a PowerShell module for interacting with the Domeneshop API.

## Status

The module provides a pre-1.0 API for storing Domeneshop credentials and working with domains, DNS records, HTTP forwards, dynamic DNS, and invoices. Command names and parameters may change before v1.0.0.

## Installation

```powershell
Install-PSResource -Name Domeneshop
Import-Module -Name Domeneshop
```

## Commands

- [Authentication](src/functions/public/Auth/Auth.md): Store credentials and select a default context.
- [Domains](src/functions/public/Domains/Domains.md): List domains or retrieve one by ID.
- [DNS](src/functions/public/Dns/Dns.md): List, add, update, and remove DNS records.
- [HTTP forwards](src/functions/public/Forwards/Forwards.md): List, add, update, and remove forwards.
- [Dynamic DNS](src/functions/public/Ddns/Ddns.md): Update a hostname with a supplied or detected address.
- [Invoices](src/functions/public/Invoices/Invoices.md): List invoices or retrieve one by ID.

## Documentation

Each public command includes PowerShell help. After importing the module, run `Get-Help <CommandName> -Full` for parameter details and examples.
