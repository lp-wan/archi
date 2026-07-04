# SCHC Architecture

This repository contains the IETF draft `draft-ietf-schc-architecture`, which
defines the terminology used throughout the documents of the SCHC Working
Group and illustrates deployment scenarios that explain the essential concepts,
components, and interactions of the SCHC architecture.

## Abstract

The SCHC framework provides both a header compression mechanism and an optional
fragmentation mechanism originally designed for Low-Power Wide-Area Networks
(LPWA). This document defines a generic architecture for SCHC deployments,
applicable across diverse networking environments (LPWA, 6LoWPAN, PPP,
Ethernet). It defines the essential architectural components and their
interactions, provides guidance for implementers and operators, and describes
illustrated deployment scenarios that clarify SCHC operation across both
network-layer and application-layer Strata. The document also clarifies the
two invocation modes: SCHC as a Network Service (Case A), using Dispatchers
and Discriminators, and SCHC as an Application Service (Case B), invoked by
the application pipeline.

## Building the Draft

This draft uses [kramdown-rfc](https://github.com/cabo/kramdown-rfc) and
[xml2rfc](https://github.com/ietf-tools/xml2rfc) for generating the various
output formats.

### Prerequisites

Make sure you have the following tools installed:

```bash
# Install kramdown-rfc (Ruby gem)
gem install kramdown-rfc

# Install xml2rfc (Python package)
# Using uv (recommended)
uv tool install xml2rfc

# Or using pip
pip install xml2rfc
```

### Building

Use the provided Makefile to build the draft:

```bash
# Generate all formats (TXT, HTML, XML, PDF)
make

# Generate specific format
make txt
make html
make xml
make pdf

# Check if tools are installed
make check-tools

# Validate the XML
make validate

# Clean generated files
make clean

# Show help
make help
```

## Files

- `schc-architecture.md` - Main draft source in Markdown format
- `schc-architecture-old.md` - Previous draft version (archived)
- `Makefile` - Build automation
- `README.md` - This file

## Contributing

This is an IETF WG draft. Please follow the standard IETF process for
contributions (see the SCHC Working Group mailing list and agenda).

## License

This document is subject to the rights, licenses and restrictions contained in
BCP 78, and except as set forth therein, the authors retain all their rights.
