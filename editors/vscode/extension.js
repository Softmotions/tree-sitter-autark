'use strict';

const path = require('path');
const vscode = require('vscode');

const CONFIG_SECTION = 'tree-sitter-vscode';
const CONFIG_KEY = 'languageConfigs';

function autarkConfig(extensionPath) {
  return {
    lang: 'autark',
    parser: path.join(extensionPath, 'tree-sitter-autark.wasm'),
    highlights: path.join(extensionPath, 'queries', 'highlights.scm'),
    folds: path.join(extensionPath, 'queries', 'folds.scm'),
    semanticTokenTypeMappings: {
      'punctuation.bracket': {
        targetTokenType: 'operator',
      },
    },
  };
}

async function activate(context) {
  const config = vscode.workspace.getConfiguration(CONFIG_SECTION);
  const current = config.get(CONFIG_KEY, []);
  const next = Array.isArray(current)
    ? current.filter((entry) => !entry || entry.lang !== 'autark')
    : [];

  next.push(autarkConfig(context.extensionPath));

  if (JSON.stringify(current) !== JSON.stringify(next)) {
    await config.update(CONFIG_KEY, next, vscode.ConfigurationTarget.Global);
  }

  try {
    await vscode.commands.executeCommand('tree-sitter-vscode.reload');
  } catch (_) {
    // The dependency may not have activated yet. It will read the persisted
    // configuration when it activates for the Autark document.
  }
}

function deactivate() {}

module.exports = { activate, deactivate };
