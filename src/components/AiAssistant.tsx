import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Send, Bot, User, Trash2, Cpu, Sparkles, Terminal, Activity, HelpCircle } from 'lucide-react';
import { Chain, TokenAsset } from '../types';

interface AiAssistantProps {
  activeChain: Chain;
  tokens: TokenAsset[];
}

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
}

export default function AiAssistant({ activeChain, tokens }: AiAssistantProps) {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: 'init-msg',
      role: 'assistant',
      content: "Aayu AI Vault Telemetry Online. I am connected directly to your active multi-chain wallet ledger state. I can interpret smart contract vulnerabilities, suggest gas-optimized bridge channels, and calculate cross-chain route optimizations. How can I facilitate your assets today?",
      timestamp: Date.now()
    }
  ]);
  const [userInput, setUserInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  // Auto-scroll messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = async (textToSend: string) => {
    const trimmed = textToSend.trim();
    if (!trimmed) return;

    const userMsg: Message = {
      id: 'msg-' + Date.now(),
      role: 'user',
      content: trimmed,
      timestamp: Date.now()
    };

    setMessages((prev) => [...prev, userMsg]);
    setUserInput('');
    setIsLoading(true);

    // Format portfolio context for the advisor endpoints
    const portfolioSummary = tokens.map(t => ({
      chainId: t.chainId,
      name: t.name,
      symbol: t.symbol,
      balance: t.balance,
      usdValue: t.balance * t.usdPrice
    }));

    try {
      const response = await fetch('/api/ai/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messages: [...messages, userMsg].map(m => m.role === 'user' ? { role: 'user', content: m.content } : { role: 'assistant', content: m.content }),
          portfolio: portfolioSummary
        })
      });

      const data = await response.json();
      
      const assistantMsg: Message = {
        id: 'msg-reply-' + Date.now(),
        role: 'assistant',
        content: data.response || "Telemetry packet failed to compile, please try reloading the vault.",
        timestamp: Date.now()
      };

      setMessages((prev) => [...prev, assistantMsg]);
    } catch (error) {
      console.error(error);
      const errMsg: Message = {
        id: 'msg-err-' + Date.now(),
        role: 'assistant',
        content: "Warning: Network socket disrupted. Local sandbox advisory fallback: Standard fees are currently lowest on Polygon side channels. Execute safe bridge operations if necessary.",
        timestamp: Date.now()
      };
      setMessages((prev) => [...prev, errMsg]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleClearChat = () => {
    setMessages([
      {
        id: 'init-msg-' + Date.now(),
        role: 'assistant',
        content: "Ledger logs cleared. Memory buffers resetting... Operational parameters stand correct. Ask me any cross-chain query.",
        timestamp: Date.now()
      }
    ]);
  };

  const quickPrompts = [
    { label: 'Optimize gas fee', text: 'Analyze current gas and provide optimal fee suggestions' },
    { label: 'Multi-chain overview', text: 'Review my assets and tell me my current diversification profile' },
    { label: 'Audit contract', text: 'Perform a vulnerability smart contract security check query' }
  ];

  return (
    <div id="ai-assistant-container" className="glass-panel p-5 rounded-3xl flex flex-col justify-between h-[480px] relative overflow-hidden font-mono">
      {/* Laser top indicator */}
      <div className="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-cyan-400 via-indigo-500 to-pink-500" />

      {/* Title block */}
      <div className="flex justify-between items-center pb-3 border-b border-slate-900 mb-3 block-header text-xs">
        <div className="flex items-center gap-2">
          <Bot className="w-5 h-5 text-indigo-400 animate-pulse glow-cyan" />
          <div>
            <h3 className="font-bold text-slate-100 uppercase tracking-widest text-[11px]">Aayu AI Vault Assistant</h3>
            <span className="text-[9px] text-[#06b6d4] flex items-center gap-1">
              <Activity className="w-3 h-3 text-emerald-400 animate-pulse" /> Secure Telemetry Active
            </span>
          </div>
        </div>
        <button
          onClick={handleClearChat}
          className="p-1.5 rounded-lg border border-slate-900 bg-slate-950/40 hover:bg-slate-900 hover:text-rose-400 transition-all cursor-pointer"
          title="Reset telemetry memory"
        >
          <Trash2 className="w-3.5 h-3.5 text-slate-550 hover:text-rose-400" />
        </button>
      </div>

      {/* Message Screen */}
      <div className="flex-1 overflow-y-auto mb-4 space-y-3 pr-1 text-[11px]">
        {messages.map((m) => {
          const isAi = m.role === 'assistant';
          return (
            <div
              key={m.id}
              className={`flex gap-2.5 max-w-[85%] ${isAi ? 'mr-auto' : 'ml-auto flex-row-reverse'}`}
            >
              <div className={`w-7 h-7 rounded-lg flex items-center justify-center flex-shrink-0 border ${
                isAi 
                  ? 'bg-indigo-950/30 border-indigo-500/20 text-indigo-400' 
                  : 'bg-slate-900 border-slate-800 text-slate-300'
              }`}>
                {isAi ? <Bot className="w-4 h-4" /> : <User className="w-4 h-4" />}
              </div>

              <div className={`p-3 rounded-2xl leading-normal border ${
                isAi 
                  ? 'bg-slate-950/60 border-indigo-500/10 text-slate-300 selection:bg-indigo-500 font-sans' 
                  : 'bg-slate-900/40 border-slate-800/80 text-white font-mono'
              }`}>
                <p className="whitespace-pre-line">{m.content}</p>
                <div className="text-[8px] text-slate-650 text-right mt-1.5">
                  {new Date(m.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </div>
              </div>
            </div>
          );
        })}

        {isLoading && (
          <div className="flex gap-2.5 max-w-[80%] mr-auto">
            <div className="w-7 h-7 rounded-lg bg-indigo-950/30 border border-indigo-500/20 text-indigo-400 flex items-center justify-center animate-pulse">
              <Bot className="w-4 h-4" />
            </div>
            <div className="p-3.5 rounded-2xl bg-slate-950/60 border border-indigo-500/10 text-slate-400 flex items-center gap-2">
              <Cpu className="w-3.5 h-3.5 text-indigo-400 animate-spin" />
              <span>Analyzing decentralized logs...</span>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Quick advice options */}
      {messages.length === 1 && (
        <div className="mb-3 space-y-1.5 text-[9px] px-1 font-mono">
          <p className="text-slate-500 uppercase font-semibold">Suggested Actions</p>
          <div className="flex flex-wrap gap-1.5">
            {quickPrompts.map((p, idx) => (
              <button
                key={idx}
                onClick={() => handleSendMessage(p.text)}
                className="py-1 px-2 text-slate-400 bg-slate-950 hover:bg-slate-900 hover:text-indigo-400 border border-slate-900 rounded-lg transition-all text-left cursor-pointer"
              >
                ⚡ {p.label}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Input box */}
      <form
        onSubmit={(e) => {
          e.preventDefault();
          handleSendMessage(userInput);
        }}
        className="flex gap-2 font-sans"
        id="ai-assistant-input-form"
      >
        <input
          required
          type="text"
          placeholder="Query AI advisor (e.g. gas optimizations)..."
          value={userInput}
          onChange={(e) => setUserInput(e.target.value)}
          className="flex-1 px-3 py-2.5 bg-slate-950 border border-slate-900 focus:border-indigo-500 font-mono text-xs rounded-xl text-slate-200 outline-none placeholder:text-slate-650"
        />
        <button
          type="submit"
          className="p-2.5 bg-indigo-600 hover:bg-indigo-500 rounded-xl text-slate-950 transition-all flex items-center justify-center shadow-lg shadow-indigo-950 cursor-pointer"
        >
          <Send className="w-4 h-4 text-white" />
        </button>
      </form>
    </div>
  );
}
