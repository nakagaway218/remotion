# AI Context: LearningTool Template

## Purpose

This folder is a reusable template for creating local HTML-based learning tools.

The intended default is manual prompt transfer:

- The user opens an HTML file locally.
- The user chooses an AI provider such as ChatGPT, Claude, or Gemini.
- The tool creates a structured prompt.
- The user copies it into the selected AI chat.
- The user may paste the AI output back into the tool for follow-up prompts.

API direct generation should stay optional until the tool has proven useful in manual mode.

## Product Principles

- Keep the tool easy to distribute.
- Keep PC and mobile entry points separate.
- Avoid adding file-opening or reference-material automation by default.
- Do not auto-append reference notes unless the user explicitly asks for that feature.
- Prefer readable first answers over long exhaustive explanations.
- If the tool is for math or science, consider separating explanation and model answer.
- If the tool is for language learning, keep examples, translations, and nuance notes concise.

## Main Files

- `TOOL_BRIEF.md`: planning brief for the new tool.
- `Template_Index.html`: PC-oriented HTML template.
- `Template_Mobile.html`: mobile-oriented HTML template.
- `Template_Start.cmd`: Windows direct-open launcher.
- `README_FOR_USERS.md`: PC user guide.
- `README_FOR_MOBILE_USERS.md`: mobile user guide.
- `SKILL.md`: maintenance rules.
- `WORKFLOWS.md`: workflow notes.
- `SUBAGENT_PROMPT.md`: prompt for delegating this tool to a sub-agent.

## Verification

For HTML files with inline JavaScript, extract the script and run `node --check` before distributing.

For simple static changes, also open the HTML manually and walk through the main Step flow.

