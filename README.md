# llama-copilot.nvim

This project has a simple goal, to use ollama llms for code completion.

## Installation & setup
Install it using any plugin manager.

Calling the setup function is not required, it is necessary if you want to use other llm or host.

```lua
-- Default config
require('llama-copilot').setup({
  host = "localhost",
  port = "11434",
  model = "codellama:7b-code"
})
```

## Requirement
Need [ollama](https://ollama.com/) and any llm model.
Initially for [codellama:7b-code](https://ollama.com/library/codellama:7b-code) and up to [70b](https://ollama.com/library/codellama:70b-code)

## Example
<div align="center">
  <p>https://github.com/Faywynnn/llama-copilot.nvim/assets/63558304/116c126c-c20f-4537-b95a-76255f2a10a9</p>
</div>


## Usage
`:LlamaCopilot` complete current code. The input is the text abouve the cursor.
