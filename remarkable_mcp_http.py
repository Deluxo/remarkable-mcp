#!/usr/bin/env python3
"""
Run remarkable-mcp over Streamable HTTP so Open WebUI (native MCP, Streamable HTTP only) can consume it.

Usage:
    .venv/bin/python remarkable_mcp_http.py

Serves on 127.0.0.1:8000/mcp by default. Only localhost is bound; Open WebUI on
this host is the intended client. Write tools are enabled (the default).
"""

import os

from remarkable_mcp.server import mcp

mcp.settings.host = os.environ.get("REMARKABLE_MCP_HOST", "127.0.0.1")
mcp.settings.port = int(os.environ.get("REMARKABLE_MCP_PORT", "8000"))
mcp.run(transport="streamable-http")
