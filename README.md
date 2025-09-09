# Cursor Background Agent API for Java Hello World

## Quick Start

### 1. Get Your API Key

- Go to [Cursor Settings](https://cursor.com/settings) → API section
- Copy your API key

### 2. Set Environment Variables

```bash
# Required: Set your API key, prompt, and repository
export CURSOR_API_KEY="your_actual_api_key_here"
export CURSOR_PROMPT="Create a Java Hello World program and verify the results compiling and executing"
export CURSOR_REPOSITORY="https://github.com/jabrena/cursor-background-agent-api-java-hello-world"

# Optional: Specify model (default is "Auto")
export CURSOR_MODEL="claude-4-sonnet"
```

### 3. Run the Script

Execute the bash script to make the API request:

```bash
./run_cursor_background_agent.sh
```

## References

- https://docs.cursor.com/en/background-agent/api/launch-an-agent
