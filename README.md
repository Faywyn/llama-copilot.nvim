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
  model = "codellama:7b-code",
  max_completion_size = 15 -- use -1 for limitless
})
```

## Requirement
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- Need [ollama](https://ollama.com/) and any model.
> [!NOTE]\
> Initially for [codellama:7b-code](https://ollama.com/library/codellama:7b-code) (and up to [70b](https://ollama.com/library/codellama:70b-code)). It hasn't been tested with other llm model.

## Usage
llama-copilot provides user commands ``:LlamaCopilotComplet`` and ``:LlamaCopilotAccept`` that can be used to trigger code generation (based on the current context) and accept the code.
Here's how you can use it:

1. Position your cursor where you want to generate code.
2. Type ``:LlamaCopilotComplet`` and press Enter.
3. Wait for the code to generate
4. Type ``:LlamaCopilotAccept`` to place the completion on your file or ``:q`` to quit the open window

## Example
<div align="center">
  <p>https://github.com/Faywyn/llama-copilot.nvim/assets/63558304/119eb883-cbbd-4efe-90e5-ea181e9be44b</p>
  Video speed: x6  |  LLM: codellama:12b-code
</div>
