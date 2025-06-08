#!/bin/bash

# ------------------------------------------------------------------------------
# Ollama Control Script
# Usage: ./ollama-control.sh {start|stop|status} [model-name]
# Default model: llama3
# ------------------------------------------------------------------------------

set -euo pipefail

ACTION=${1:-}
MODEL=${2:-llama3}
OLLAMA_PORT=11434

function info()    { echo -e "ℹ️  $*"; }
function warn()    { echo -e "⚠️  $*"; }
function error()   { echo -e "❌ $*" >&2; }
function success() { echo -e "✅ $*"; }

function is_running() {
  curl -s "http://localhost:$OLLAMA_PORT" > /dev/null
}

function start_ollama() {
  info "Starting Ollama server in background..."
  if pgrep -u "$USER" -f "ollama serve" > /dev/null; then
    warn "Ollama server is already running (under user $USER)."
  else
    nohup ollama serve > /dev/null 2>&1 &
    sleep 2
    success "Ollama server started."
  fi

  info "Ensuring model '$MODEL' is available..."
  ollama pull "$MODEL"

  info "Running model '$MODEL' interactively..."
  ollama run "$MODEL"
}

function stop_ollama() {
  info "Stopping model '$MODEL' if running..."
  ollama stop "$MODEL" 2>/dev/null || warn "Model '$MODEL' was not running."

  info "Stopping Ollama server..."

  if systemctl list-units --type=service --all | grep -q "ollama.service"; then
    if sudo systemctl stop ollama; then
      success "Ollama server stopped via systemctl."
    else
      error "Failed to stop Ollama server with systemctl."
    fi
  elif pgrep -f "ollama serve" > /dev/null; then
    if pkill -f "ollama serve" 2>/dev/null || sudo pkill -f "ollama serve"; then
      success "Ollama server stopped manually."
    else
      error "Failed to stop Ollama server manually."
    fi
  else
    warn "Ollama server was not running."
  fi
}

function check_status() {
  info "Checking Ollama server status..."
  if is_running; then
    success "Ollama server is running at http://localhost:$OLLAMA_PORT"
  else
    error "Ollama server is not running."
  fi
}

# ------------------------------------------------------------------------------
# Main Command Dispatch
# ------------------------------------------------------------------------------

case "$ACTION" in
  start)
    start_ollama
    ;;
  stop)
    stop_ollama
    ;;
  status)
    check_status
    ;;
  *)
    echo "Usage: $0 {start|stop|status} [model-name]"
    exit 1
    ;;
esac
