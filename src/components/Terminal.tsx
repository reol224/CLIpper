import React, { useState, useRef, useEffect } from 'react';
import { Terminal as TerminalIcon } from 'lucide-react';
import CommandProcessor from './CommandProcessor';

interface TerminalLine {
  id: number;
  type: 'input' | 'output' | 'error' | 'warning';
  content: string;
  timestamp: Date;
}

export default function Terminal() {
  const [lines, setLines] = useState<TerminalLine[]>([
    {
      id: 0,
      type: 'output',
      content: 'CLIpper v1.0.0 - Cross-platform System Management Tool',
      timestamp: new Date()
    },
    {
      id: 1,
      type: 'output',
      content: 'Type "help" to see available commands.',
      timestamp: new Date()
    }
  ]);
  const [currentInput, setCurrentInput] = useState('');
  const [commandHistory, setCommandHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const inputRef = useRef<HTMLInputElement>(null);
  const terminalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (terminalRef.current) {
      terminalRef.current.scrollTop = terminalRef.current.scrollHeight;
    }
  }, [lines]);

  // Check for updates on terminal load
  useEffect(() => {
    const checkUpdates = () => {
      const hasUpdate = Math.random() > 0.6; // 40% chance of update
      if (hasUpdate) {
        setTimeout(() => {
          addLine('🔄 Update available! CLIpper v1.0.2 is ready to install.', 'warning');
          addLine('Run "clipper --update" for details or "clipper --upgrade" to update now.', 'warning');
          addLine('', 'output');
        }, 2000);
      }
    };
    
    checkUpdates();
  }, []);

  const addLine = (content: string, type: 'input' | 'output' | 'error' | 'warning' = 'output') => {
    const newLine: TerminalLine = {
      id: Date.now(),
      type,
      content,
      timestamp: new Date()
    };
    setLines(prev => [...prev, newLine]);
  };

  const handleCommand = (command: string) => {
    // Add the input command to terminal
    addLine(`$ ${command}`, 'input');
    
    // Add to command history
    setCommandHistory(prev => [...prev, command]);
    setHistoryIndex(-1);
    
    // Process the command
    const result = CommandProcessor.processCommand(command.trim());
    
    // Add result to terminal
    if (Array.isArray(result)) {
      result.forEach(line => {
        if (line.includes('🔄') || line.includes('Update available')) {
          addLine(line, 'warning');
        } else if (line.startsWith('Error:')) {
          addLine(line, 'error');
        } else {
          addLine(line, 'output');
        }
      });
    } else {
      const lineType = result.startsWith('Error:') ? 'error' : 
                      result.includes('🔄') || result.includes('Update') ? 'warning' : 'output';
      addLine(result, lineType);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (currentInput.trim()) {
      handleCommand(currentInput);
      setCurrentInput('');
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (historyIndex < commandHistory.length - 1) {
        const newIndex = historyIndex + 1;
        setHistoryIndex(newIndex);
        setCurrentInput(commandHistory[commandHistory.length - 1 - newIndex]);
      }
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (historyIndex > 0) {
        const newIndex = historyIndex - 1;
        setHistoryIndex(newIndex);
        setCurrentInput(commandHistory[commandHistory.length - 1 - newIndex]);
      } else if (historyIndex === 0) {
        setHistoryIndex(-1);
        setCurrentInput('');
      }
    }
  };

  const getLineColor = (type: string) => {
    switch (type) {
      case 'input': return 'text-cyan-400';
      case 'error': return 'text-red-400';
      case 'warning': return 'text-yellow-400';
      default: return 'text-green-400';
    }
  };

  return (
    <div className="min-h-screen bg-black text-green-400 font-mono">
      {/* Header */}
      <div className="border-b border-green-500 p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <TerminalIcon className="w-5 h-5" />
            <span className="text-white font-bold">CLIpper Terminal</span>
          </div>
          <div className="text-sm text-gray-400">
            v1.0.0 | Type "update" to check for updates
          </div>
        </div>
      </div>

      {/* Terminal Content */}
      <div 
        ref={terminalRef}
        className="h-[calc(100vh-120px)] overflow-y-auto p-4 space-y-1"
      >
        {lines.map((line) => (
          <div key={line.id} className={`${getLineColor(line.type)} whitespace-pre-wrap`}>
            {line.content}
          </div>
        ))}
      </div>

      {/* Input */}
      <div className="border-t border-green-500 p-4">
        <form onSubmit={handleSubmit} className="flex items-center gap-2">
          <span className="text-green-400">$</span>
          <input
            ref={inputRef}
            type="text"
            value={currentInput}
            onChange={(e) => setCurrentInput(e.target.value)}
            onKeyDown={handleKeyDown}
            className="flex-1 bg-transparent text-green-400 outline-none"
            placeholder="Enter command..."
            autoFocus
          />
        </form>
      </div>
    </div>
  );
}