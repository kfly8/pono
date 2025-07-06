# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Pono is a modern Perl web framework using Perl 5.40's experimental class syntax. It provides a lightweight, PSGI-compatible web application framework with routing, context handling, and response utilities.

## Commands

### Testing
- `perl -Ilib t/00_compile.t` - Run compilation test
- `perl -Ilib t/Stump.t` - Run main test suite with Test2::V0
- `prove -Ilib t/` - Run all tests

### Building and Installation
- `perl Build.PL` - Generate build script (uses Module::Build::Tiny)
- `./Build` - Build the distribution
- `./Build test` - Run tests
- `./Build install` - Install the module

### Development
- `minil build` - Build distribution with Minilla
- `minil test` - Run tests with Minilla
- `minil release` - Release new version

## Architecture

### Core Components

1. **Pono** (lib/Pono.pm) - Main application class inheriting from Pono::Base
2. **Pono::Base** (lib/Pono/Base.pm) - Base application class with routing and dispatch logic
3. **Pono::Context** (lib/Pono/Context.pm) - Request/response context with helper methods
4. **Pono::Router** (lib/Pono/Router.pm) - Abstract router interface
5. **Pono::Router::Linear** (lib/Pono/Router/Linear.pm) - Linear router implementation
6. **Pono::Request** (lib/Pono/Request.pm) - Request wrapper
7. **Pono::Response** (lib/Pono/Response.pm) - Response wrapper

### Key Patterns

- **Modern Perl**: Uses `v5.40` with experimental `class` syntax
- **PSGI Interface**: Applications expose `->psgi()` method for PSGI servers
- **Route Handlers**: Accept a context object `$c` with request/response helpers
- **Method Chaining**: Context methods return response objects for chaining
- **Type Validation**: Optional Variables parameter for type-checked context storage

### Request Flow

1. PSGI environment → Pono::Request
2. Router matches path/method → handler + parameters
3. Pono::Context created with request/response/match_result
4. Handler executed with context
5. Response finalized and returned

### Response Helpers

Context provides convenience methods:
- `$c->text($code, $text)` - Plain text response
- `$c->html($code, $html)` - HTML response
- `$c->json($code, $data)` - JSON response
- `$c->redirect($url, $code)` - Redirect response
- `$c->header($name, $value)` - Set/get headers

### Error Handling

- Custom error handlers via `->on_error()`
- Custom 404 handlers via `->not_found()`
- Automatic error response generation
- Exception objects can provide `get_response()` method

### Testing

- Uses Test2::V0 framework
- Built-in test helper via `->test_request($http_request)`
- HTTP::Request::Common for request creation
- Response objects have `->json()` method for JSON assertion

## Dependencies

Core dependencies from cpanfile:
- WWW::Form::UrlEncoded (with optional XS version)
- Cpanel::JSON::XS
- HTTP::Entity::Parser
- HTTP::Headers::Fast
- Hash::MultiValue
- HTTP::Parser (with optional XS version)

Test dependencies:
- Test2::V0
- HTTP::Message::PSGI
- HTTP::Request::Common