# llama-copilot.nvim

llama-copilot is a Neovim plugin that integrates with ollama's AI models for code completion.

## Installation & setup
Install it using any plugin manager, require nvim-lua/plenary.nvim.

**With [packer](https://github.com/wbthomason/packer.nvim)**
```lua
use {
  "Faywyn/llama-copilot.nvim",
  requires = "nvim-lua/plenary.nvim"
}
```
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
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- Need [ollama](https://ollama.com/) and any model.
> [!NOTE]\
> Initially for [codellama:7b-code](https://ollama.com/library/codellama:7b-code) (and up to [70b](https://ollama.com/library/codellama:70b-code)). It hasn't been tested with other llm model.

## Usage
llama-copilot provides a user command ``:LlamaCopilot`` that can be used to trigger code generation based on the current context. Here's how you can use it:

1. Position your cursor where you want to generate code.
2. Type ``:LlamaCopilot`` and press Enter.

This will trigger the plugin to send a request to ollama's API with the current context as a prompt. The AI model will then generate code based on the prompt and display the generated code in a floating window.

## Example
<div align="center">
  <p>https://github.com/Faywyn/llama-copilot.nvim/assets/63558304/116c126c-c20f-4537-b95a-76255f2a10a9</p>
  Video speed: x4
</div>
