import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ChevronDown, AlertCircle, Plus, Info, Zap } from 'lucide-react';
import { Chain } from '../types';

interface ChainSelectorProps {
  chains: Chain[];
  activeChain: Chain;
  onSelectChain: (chainId: string) => void;
  onAddCustomChain: (newChain: Chain) => void;
}

export default function ChainSelector({ chains, activeChain, onSelectChain, onAddCustomChain }: ChainSelectorProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [showAddCustom, setShowAddCustom] = useState(false);

  // Form states for custom network
  const [customName, setCustomName] = useState('');
  const [customSymbol, setCustomSymbol] = useState('');
  const [customRpc, setCustomRpc] = useState('');
  const [customExplorer, setCustomExplorer] = useState('');
  const [errorMsg, setErrorMsg] = useState('');

  const handleCreateCustomNetwork = (e: React.FormEvent) => {
    e.preventDefault();
    if (!customName || !customSymbol || !customRpc) {
      setErrorMsg('Name, Symbol, and RPC URL are required.');
      return;
    }
    if (!customRpc.startsWith('http://') && !customRpc.startsWith('https://')) {
      setErrorMsg('RPC must be a valid http or https protocol endpoint.');
      return;
    }

    const customId = customName.toLowerCase().replace(/\s+/g, '-');
    const newNetwork: Chain = {
      id: customId as any,
      name: customName,
      symbol: customSymbol.toUpperCase(),
      logo: '⛓️',
      rpcUrl: customRpc,
      blockExplorer: customExplorer || 'https://etherscan.io',
      gasPriceGwei: 1.5,
      health: 'optimal'
    };

    onAddCustomChain(newNetwork);
    onSelectChain(newNetwork.id);
    
    // reset states
    setCustomName('');
    setCustomSymbol('');
    setCustomRpc('');
    setCustomExplorer('');
    setErrorMsg('');
    setShowAddCustom(false);
    setIsOpen(false);
  };

  return (
    <div className="relative font-mono">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2.5 px-4 py-2.5 rounded-full border border-slate-800 bg-[#0a0a14] text-xs font-semibold text-slate-200 hover:border-indigo-500/50 hover:bg-slate-900/60 transition-all cursor-pointer shadow-lg"
        id="chain-selector-trigger"
      >
        <span className="text-lg">{activeChain.logo}</span>
        <span className="max-w-[120px] truncate text-slate-100">{activeChain.name}</span>
        <Zap className={`w-3.5 h-3.5 ${
          activeChain.health === 'optimal' ? 'text-emerald-400 fill-emerald-400/20' : 'text-amber-400'
        }`} />
        <ChevronDown className="w-4 h-4 text-slate-400" />
      </button>

      <AnimatePresence>
        {isOpen && (
          <div className="absolute right-0 mt-2.5 w-72 rounded-2xl glass-panel p-3 shadow-[0_10px_30px_rgba(0,0,0,0.6)] border border-slate-800 z-50 overflow-hidden">
            <div className="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-cyan-500 to-indigo-500" />
            
            {!showAddCustom ? (
              <>
                <div className="flex justify-between items-center px-2 py-1.5 mb-2 border-b border-slate-800/80">
                  <span className="text-[10px] font-semibold text-indigo-400 uppercase tracking-widest">Select Network</span>
                  <button
                    onClick={() => setShowAddCustom(true)}
                    className="text-[10px] font-semibold text-emerald-400 hover:text-emerald-300 flex items-center gap-1 cursor-pointer"
                  >
                    <Plus className="w-3 h-3" /> Custom RPC
                  </button>
                </div>

                <div className="space-y-1 max-h-64 overflow-y-auto pr-1">
                  {chains.map((chain) => {
                    const isActive = chain.id === activeChain.id;
                    return (
                      <button
                        key={chain.id}
                        onClick={() => {
                          onSelectChain(chain.id);
                          setIsOpen(false);
                        }}
                        className={`w-full text-left p-2.5 rounded-xl flex items-center justify-between transition-all cursor-pointer ${
                          isActive 
                            ? 'bg-indigo-950/40 border border-indigo-500/30 text-white' 
                            : 'hover:bg-slate-900/50 text-slate-400 hover:text-slate-200'
                        }`}
                      >
                        <div className="flex items-center gap-3">
                          <span className="text-lg">{chain.logo}</span>
                          <div>
                            <p className="text-xs font-semibold">{chain.name}</p>
                            <p className="text-[9px] text-slate-500 mt-0.5">
                              Gas: {chain.gasPriceGwei} {chain.id === 'solana' ? 'SOL' : 'Gwei'}
                            </p>
                          </div>
                        </div>
                        
                        <div className="flex items-center gap-2">
                          <div className={`w-1.5 h-1.5 rounded-full ${
                            chain.health === 'optimal' 
                              ? 'bg-emerald-400 shadow-[0_0_8px_rgba(16,185,129,0.5)]' 
                              : chain.health === 'congested'
                                ? 'bg-amber-400'
                                : 'bg-rose-500'
                          }`} />
                          {isActive && <span className="text-[9px] text-indigo-400 font-extrabold">Active</span>}
                        </div>
                      </button>
                    );
                  })}
                </div>
              </>
            ) : (
              <form onSubmit={handleCreateCustomNetwork} className="p-1 space-y-3">
                <div className="flex justify-between items-center mb-1 text-xs">
                  <span className="font-semibold text-indigo-400 uppercase tracking-widest text-[10px]">Add Custom Net</span>
                  <button 
                    type="button" 
                    onClick={() => {
                      setShowAddCustom(false);
                      setErrorMsg('');
                    }}
                    className="text-slate-400 hover:text-white font-semibold text-[10px]"
                  >
                    Cancel
                  </button>
                </div>

                {errorMsg && (
                  <div className="p-2 border border-rose-500/20 bg-rose-950/10 rounded-lg text-[9px] text-rose-300 flex items-center gap-1">
                    <AlertCircle className="w-3 h-3 text-rose-400 flex-shrink-0" />
                    <span>{errorMsg}</span>
                  </div>
                )}

                <div className="space-y-2 text-[10px]">
                  <div>
                    <label className="block text-slate-400 uppercase tracking-wide mb-1 text-[9px]">Network Name</label>
                    <input
                      required
                      type="text"
                      placeholder="e.g., Arbitrum One"
                      value={customName}
                      onChange={(e) => setCustomName(e.target.value)}
                      className="w-full px-3 py-1.5 rounded-lg bg-slate-950/60 border border-slate-800 text-slate-200 outline-none focus:border-indigo-500"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-2">
                    <div>
                      <label className="block text-slate-400 uppercase tracking-wide mb-1 text-[9px]">Token Symbol</label>
                      <input
                        required
                        type="text"
                        placeholder="e.g., ARB"
                        value={customSymbol}
                        onChange={(e) => setCustomSymbol(e.target.value)}
                        className="w-full px-3 py-1.5 rounded-lg bg-slate-950/60 border border-slate-800 text-slate-200 outline-none focus:border-indigo-500"
                      />
                    </div>
                    <div>
                      <label className="block text-slate-400 uppercase tracking-wide mb-1 text-[9px]">Gas Base (Gwei)</label>
                      <span className="block px-3 py-1.5 rounded-lg bg-slate-950/30 border border-slate-800/80 text-slate-500">1.5 Gwei</span>
                    </div>
                  </div>

                  <div>
                    <label className="block text-slate-400 uppercase tracking-wide mb-1 text-[9px]">RPC Endpoint URL</label>
                    <input
                      required
                      type="text"
                      placeholder="https://arbitrum.public-rpc.com"
                      value={customRpc}
                      onChange={(e) => setCustomRpc(e.target.value)}
                      className="w-full px-3 py-1.5 rounded-lg bg-slate-950/60 border border-slate-800 text-slate-200 outline-none focus:border-indigo-500"
                    />
                  </div>

                  <div>
                    <label className="block text-slate-400 uppercase tracking-wide mb-1 text-[9px]">Block Explorer URL (Opt.)</label>
                    <input
                      type="text"
                      placeholder="https://arbiscan.io"
                      value={customExplorer}
                      onChange={(e) => setCustomExplorer(e.target.value)}
                      className="w-full px-3 py-1.5 rounded-lg bg-slate-950/60 border border-slate-800 text-slate-200 outline-none focus:border-indigo-500"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  className="w-full mt-3 py-2 rounded-xl bg-gradient-to-r from-emerald-500 to-indigo-500 hover:from-emerald-600 hover:to-indigo-600 text-[10px] font-bold text-slate-950 uppercase tracking-wider shadow-lg cursor-pointer"
                >
                  🚀 Connect Custom RPC Chain
                </button>
              </form>
            )}
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
