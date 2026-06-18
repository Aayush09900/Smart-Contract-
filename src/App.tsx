import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  Wallet, Shield, Coins, Layers, MessageSquare, History, 
  ArrowUpRight, ArrowDownLeft, ArrowRightLeft, Copy, Check, 
  Settings, Server, Info, Search, Power, Zap, TrendingUp, Sparkles, HelpCircle, Plus
} from 'lucide-react';

import { Chain, TokenAsset, NFTAsset, Transaction, WalletAccount } from './types';
import { SUPPORTED_CHAINS, INITIAL_TOKENS_DATA, INITIAL_NFTS_DATA, MOCK_SEED_PHRASE } from './data';

import VaultSetup from './components/VaultSetup';
import ChainSelector from './components/ChainSelector';
import SendReceiveModal from './components/SendReceiveModal';
import BridgeModule from './components/BridgeModule';
import NftGallery from './components/NftGallery';
import AiAssistant from './components/AiAssistant';

export default function App() {
  const [isSetup, setIsSetup] = useState(false);
  const [password, setPassword] = useState('');
  
  // Vault vault configuration
  const [accounts, setAccounts] = useState<WalletAccount[]>([
    { name: 'Core Account 1', address: '0x3A21c81829eFaD632c1E9e21Fe29E0b7C2b406Db', avatarSeed: 'core-a1' },
    { name: 'DeFi Alpha Vault', address: '0xDeFiCe718225d329ab0C3Cd915f4e0Bf8C86aB2C', avatarSeed: 'defi-alpha' }
  ]);
  const [activeAccountIdx, setActiveAccountIdx] = useState(0);
  const activeAccount = accounts[activeAccountIdx];

  // Global Ledger resources
  const [chains, setChains] = useState<Chain[]>(SUPPORTED_CHAINS);
  const [activeChainId, setActiveChainId] = useState<string>('ethereum');
  const activeChain = chains.find(c => c.id === activeChainId) || chains[0];

  const [tokens, setTokens] = useState<TokenAsset[]>([]);
  const [nfts, setNfts] = useState<NFTAsset[]>(INITIAL_NFTS_DATA);
  const [transactions, setTransactions] = useState<Transaction[]>([
    {
      id: 'tx-seed-1',
      type: 'receive',
      hash: '0x49ca...7112',
      from: '0x88fA...91d2',
      to: '0x3A21c81829eFaD632c1E9e21Fe29E0b7C2b406Db',
      amount: '1.25',
      symbol: 'ETH',
      chainId: 'ethereum',
      timestamp: Date.now() - 36 * 3600 * 1000,
      status: 'success',
      gasFeeUsd: 4.80,
      notes: 'Initial account activation deposit'
    }
  ]);

  // UI state managers
  const [activeTab, setActiveTab] = useState<'tokens' | 'nfts' | 'bridge' | 'ai' | 'history'>('tokens');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [copied, setCopied] = useState(false);
  const [isAddingAccount, setIsAddingAccount] = useState(false);
  const [newAccountName, setNewAccountName] = useState('');

  // Hydrate custom dynamic token asset on setup
  useEffect(() => {
    if (activeAccount) {
      setTokens(INITIAL_TOKENS_DATA(activeAccount.address));
    }
  }, [activeAccount]);

  const handleVaultCreated = (seedPhrase: string, pwd: string) => {
    setPassword(pwd);
    setIsSetup(true);
  };

  const handleSelectChain = (id: string) => {
    setActiveChainId(id);
  };

  const handleAddCustomChain = (newChain: Chain) => {
    setChains((prev) => [...prev, newChain]);
  };

  const handleAddTransaction = (newTx: Transaction) => {
    setTransactions((prev) => [newTx, ...prev]);
  };

  const handleUpdateBalance = (tokenId: string, newBalance: number) => {
    setTokens((prev) => prev.map((t) => t.id === tokenId ? { ...t, balance: newBalance } : t));
  };

  const handleAddAccount = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newAccountName.trim()) return;

    // Generate arbitrary secure hex addresses for additional sub-accounts
    const randomAddress = activeChain.id === 'solana'
      ? '9xQiyG' + Math.random().toString(36).substring(2, 10).toUpperCase() + 'zTe'
      : '0x' + Math.random().toString(16).substring(2, 10) + '22eFaD' + Math.random().toString(16).substring(2, 6) + '0b7c';

    const newAccount: WalletAccount = {
      name: newAccountName.trim(),
      address: randomAddress,
      avatarSeed: 'core-' + Date.now().toString().substring(10)
    };

    setAccounts((prev) => [...prev, newAccount]);
    setActiveAccountIdx(accounts.length); // Switch to newly created account immediately
    setNewAccountName('');
    setIsAddingAccount(false);
  };

  const handleMintNFT = (newNft: NFTAsset) => {
    setNfts((prev) => [newNft, ...prev]);
  };

  const handleCopyAddress = () => {
    navigator.clipboard.writeText(activeAccount.address);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleLockWallet = () => {
    setIsSetup(false);
    setPassword('');
  };

  // Compute aggregated dollar holdings across the selected chain, or all chains
  const getPortfolioValues = () => {
    // Current Active Chain evaluation
    const activeChainTokens = tokens.filter(t => t.chainId === activeChain.id);
    const activeChainTotal = activeChainTokens.reduce((acc, t) => acc + (t.balance * t.usdPrice), 0);

    // Global Aggregate Multi-Chain total
    const globalTotal = tokens.reduce((acc, t) => acc + (t.balance * t.usdPrice), 0);

    return {
      activeChainTotal: activeChainTotal.toLocaleString([], { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
      globalTotal: globalTotal.toLocaleString([], { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
    };
  };

  const portfolio = getPortfolioValues();

  // If password setup is incomplete, show introductory credentials portal
  if (!isSetup) {
    return <VaultSetup onVaultCreated={handleVaultCreated} />;
  }

  return (
    <div id="main-applet-wrapper" className="min-h-screen bg-[#030207] text-[#e2e8f0] relative flex flex-col justify-between overflow-x-hidden pb-10">
      
      {/* Dynamic Cyber Ambient Gradients */}
      <div className="absolute top-0 right-1/4 w-[500px] h-[500px] rounded-full bg-cyan-500/5 blur-[160px] pointer-events-none" />
      <div className="absolute bottom-0 left-1/4 w-[450px] h-[450px] rounded-full bg-pink-500/5 blur-[180px] pointer-events-none" />

      {/* 1. FUTURISTIC TOP BAR HEADER */}
      <header className="border-b border-slate-900/80 bg-slate-950/30 backdrop-blur-md sticky top-0 z-40 px-6 py-4.5">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row gap-4 items-center justify-between">
          
          {/* Logo & Concept */}
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-tr from-cyan-400 via-indigo-600 to-pink-500 rounded-xl flex items-center justify-center shadow-[0_0_15px_rgba(99,102,241,0.3)]">
              <Wallet className="w-5.5 h-5.5 text-white" />
            </div>
            <div>
              <h1 className="text-lg font-bold tracking-tight text-white flex items-center gap-1.5 leading-none">
                Aayu Wallet <span className="text-[9px] font-mono leading-none border border-cyan-400/30 text-cyan-400 bg-cyan-950/40 py-0.5 px-2 rounded-full uppercase tracking-wider">DEV PORTAL</span>
              </h1>
              <p className="text-[10px] font-mono text-slate-500 mt-1 uppercase tracking-widest">Metaverse Web3 Client</p>
            </div>
          </div>

          {/* Right aligned wallet details */}
          <div className="flex flex-wrap items-center gap-4">
            
            {/* CHAIN SELECT DROPDOWN */}
            <ChainSelector 
              chains={chains} 
              activeChain={activeChain} 
              onSelectChain={handleSelectChain} 
              onAddCustomChain={handleAddCustomChain} 
            />

            {/* ACCOUNT MANAGER SELECT */}
            <div className="relative font-mono">
              <div className="flex items-center gap-2 bg-[#0c0c16] border border-slate-800 px-3 py-1.5 rounded-full text-xs">
                {/* Simulated colorful avatar seed */}
                <div className="w-5 h-5 rounded-md bg-gradient-to-br from-pink-500 via-purple-600 to-cyan-400" />
                <select
                  value={activeAccountIdx}
                  onChange={(e) => setActiveAccountIdx(parseInt(e.target.value))}
                  className="bg-transparent text-slate-300 font-semibold outline-none py-1 mr-1 text-[11px] cursor-pointer"
                >
                  {accounts.map((acc, index) => (
                    <option key={index} value={index} className="bg-slate-950 text-slate-400">
                      {acc.name}
                    </option>
                  ))}
                </select>
                
                {/* Fast Account Add Button */}
                <button
                  onClick={() => setIsAddingAccount(true)}
                  className="p-1 hover:text-[#10b981] text-slate-500 cursor-pointer"
                  title="Create new key sub-address account"
                >
                  <Plus className="w-3.5 h-3.5" />
                </button>
              </div>

              {/* Add Account Popup Panel */}
              <AnimatePresence>
                {isAddingAccount && (
                  <div className="absolute right-0 mt-2.5 w-60 rounded-2xl p-4 glass-panel border border-slate-800 shadow-[0_10px_30px_rgba(0,0,0,0.5)] z-50">
                    <form onSubmit={handleAddAccount} className="space-y-3">
                      <div className="flex justify-between items-center pb-1">
                        <span className="text-[9px] font-bold text-indigo-400 uppercase tracking-widest">New Sub-Account</span>
                        <button type="button" onClick={() => setIsAddingAccount(false)} className="text-[9px] text-slate-500 hover:text-white">Cancel</button>
                      </div>
                      <input
                        required
                        type="text"
                        placeholder="Account Label (e.g. NFT vault)"
                        value={newAccountName}
                        onChange={(e) => setNewAccountName(e.target.value)}
                        className="w-full px-3 py-1.5 rounded-lg bg-slate-950/80 border border-slate-850 text-[10px] outline-none text-slate-200"
                      />
                      <button
                        type="submit"
                        className="w-full py-1.5 rounded-lg bg-gradient-to-r from-cyan-400 to-indigo-500 hover:from-cyan-500 hover:to-indigo-600 text-slate-950 text-[9px] font-bold uppercase tracking-widest cursor-pointer"
                      >
                        🚀 Generate Sub-Vault
                      </button>
                    </form>
                  </div>
                )}
              </AnimatePresence>
            </div>

            {/* Logout/Lock Portal */}
            <button
              onClick={handleLockWallet}
              className="p-2.5 rounded-full bg-slate-950/60 border border-slate-900/80 hover:border-rose-500/20 hover:bg-slate-900 text-slate-400 hover:text-rose-400 transition-colors cursor-pointer"
              title="Lock Wallet Session"
            >
              <Power className="w-4 h-4" />
            </button>

          </div>
        </div>
      </header>

      {/* 2. BODY MAIN WRAPPER */}
      <main className="max-w-7xl mx-auto flex-1 w-full px-4 md:px-6 py-6 grid grid-cols-1 md:grid-cols-12 gap-6 relative">
        
        {/* LEFT COLUMN PANEL: TELEMETRY QUICKSTATS & USER VIEW */}
        <div className="md:col-span-4 space-y-6 flex flex-col justify-start">
          
          {/* PROFILE STATS GLASS PANEL */}
          <div className="glass-panel p-5.5 rounded-3xl relative overflow-hidden flex flex-col justify-between min-h-[310px] shadow-[0_0_20px_rgba(0,0,0,0.4)]">
            {/* Pulsing visual scan effect */}
            <div className="absolute top-0 right-0 w-28 h-28 bg-gradient-to-bl from-indigo-500/10 to-transparent blur-xl pointer-events-none" />
            <div className="absolute top-0 left-0 right-0 h-[1.5px] bg-gradient-to-r from-cyan-400/60 via-indigo-500/40 to-transparent" />

            <div className="space-y-4 font-mono">
              <div className="flex items-center gap-3">
                <div className="relative">
                  <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-cyan-400 via-indigo-600 to-pink-500 p-0.5 shadow-[0_0_15px_rgba(99,102,241,0.2)]">
                    <div className="w-full h-full bg-[#030206] rounded-[10px] flex items-center justify-center font-bold text-white uppercase text-base">
                      {activeAccount.name.substring(0, 2)}
                    </div>
                  </div>
                  <div className="absolute -bottom-1 -right-1 w-4 h-4 rounded-full bg-[#0a0a14] border border-[#10b981] flex items-center justify-center shadow">
                    <span className="w-2 h-2 rounded-full bg-[#10b981] animate-pulse" />
                  </div>
                </div>

                <div>
                  <h3 className="font-bold text-slate-100 text-sm leading-tight flex items-center gap-2">
                    {activeAccount.name}
                  </h3>
                  <div className="flex items-center gap-1 bg-slate-950/80 border border-slate-900/60 px-2 py-0.5 rounded-lg text-[9px] text-slate-400 mt-1 cursor-pointer hover:border-slate-800 transition-all select-all pr-2" onClick={handleCopyAddress}>
                    <span>{activeAccount.address.slice(0, 8)}...{activeAccount.address.slice(-8)}</span>
                    {copied ? (
                      <Check className="w-3 h-3 text-emerald-400 ml-1" />
                    ) : (
                      <Copy className="w-3 h-3 text-slate-500 ml-1" />
                    )}
                  </div>
                </div>
              </div>

              {/* INTEGRATED LEDGER HOLOGRAPH BALANCE */}
              <div className="pt-4 border-t border-slate-900/80 space-y-2">
                <div className="flex justify-between items-baseline">
                  <span className="text-[10px] text-slate-500 uppercase tracking-widest font-semibold flex items-center gap-2">
                    <TrendingUp className="w-3.5 h-3.5 text-[#06b6d4] glow-cyan" /> Multi-Chain Balance
                  </span>
                  <span className="text-[9px] text-[#10b981] font-bold uppercase tracking-widest">USD value</span>
                </div>
                
                {/* Active Chain Valuation display */}
                <div className="text-3xl font-extrabold tracking-tight text-white glow-cyan">
                  ${portfolio.globalTotal} <span className="text-[11px] text-slate-500 font-mono font-medium block mt-1 tracking-wider uppercase">Active: ${portfolio.activeChainTotal} ({activeChain.symbol})</span>
                </div>
              </div>
            </div>

            {/* SEND / RECEIVE LAUNCH ACTIONS BUTTONS */}
            <div className="flex gap-3 pt-5 font-mono">
              <button
                onClick={() => {
                  setActiveTab('tokens');
                  setIsModalOpen(true);
                }}
                className="w-1/2 py-2.5 rounded-2xl bg-slate-950 border border-slate-850 hover:border-indigo-500/40 text-slate-200 hover:text-white hover:bg-slate-900 text-[10px] font-bold uppercase tracking-wider transition-all flex items-center justify-center gap-1.5 cursor-pointer shadow-lg"
                id="btn-trigger-send-modal"
              >
                <ArrowUpRight className="w-4 h-4 text-indigo-400" /> Transmit Pay
              </button>

              <button
                onClick={() => {
                  setActiveTab('tokens');
                  setIsModalOpen(true);
                }}
                className="w-1/2 py-2.5 rounded-2xl bg-gradient-to-r from-indigo-500 to-pink-500 hover:from-indigo-600 hover:to-pink-600 text-slate-950 text-[10px] font-extrabold uppercase tracking-wider transition-all flex items-center justify-center gap-1.5 cursor-pointer shadow-lg shadow-indigo-950/20"
                id="btn-trigger-receive-modal"
              >
                <ArrowDownLeft className="w-4 h-4" /> Receive In
              </button>
            </div>
          </div>

          {/* BLOCK TELEMETRY INDEX BOX */}
          <div className="p-5.5 rounded-3xl glass-panel font-mono text-[10px] space-y-3 shadow shadow-indigo-950/10">
            <div className="text-[9px] font-bold text-slate-500 uppercase tracking-widest mb-1.5 flex items-center gap-2">
              <Server className="w-4.5 h-4.5 text-indigo-400" /> Metaverse Node Explorer
            </div>

            <div className="grid grid-cols-2 gap-3 text-[10px]">
              <div className="p-2 bg-slate-950 rounded-xl border border-slate-900">
                <span className="block text-slate-500">RPC HEALTH</span>
                <span className="block text-emerald-400 font-bold mt-1 tracking-wider uppercase">100% ONLINE</span>
              </div>
              <div className="p-2 bg-slate-950 rounded-xl border border-slate-900">
                <span className="block text-slate-500">GAS INDEX</span>
                <span className="block text-indigo-300 font-bold mt-1 tracking-wider uppercase">{activeChain.gasPriceGwei} {activeChain.id === 'solana' ? 'SOL' : 'Gwei'}</span>
              </div>
            </div>

            <div className="p-2 bg-slate-950 rounded-xl border border-slate-900 text-[9px] flex items-center gap-2 text-slate-400">
              <Zap className="w-4 h-4 text-[#06b6d4] flex-shrink-0 animate-pulse glow-cyan" />
              <span>Aayu smart routing leverages simulated decentralization protocols, guaranteeing zero network failures during cross-chain execution.</span>
            </div>
          </div>

        </div>

        {/* RIGHT COLUMN STAGE: DYNAMIC TABS PANEL COORD */}
        <div className="md:col-span-8 flex flex-col space-y-6">
          
          {/* NAVIGATION DRAWER TABS BAR */}
          <div className="flex border-b border-slate-900 text-xs font-mono justify-start overflow-x-auto gap-1">
            <button
              onClick={() => setActiveTab('tokens')}
              className={`py-3 px-4 font-semibold hover:text-white transition-all uppercase tracking-wider cursor-pointer border-b-2 flex items-center gap-2 ${
                activeTab === 'tokens' ? 'border-cyan-400 text-white bg-slate-950/20' : 'border-transparent text-slate-400'
              }`}
            >
              <Coins className="w-4 h-4" /> Assets
            </button>
            <button
              onClick={() => setActiveTab('nfts')}
              className={`py-3 px-4 font-semibold hover:text-white transition-all uppercase tracking-wider cursor-pointer border-b-2 flex items-center gap-2 ${
                activeTab === 'nfts' ? 'border-emerald-400 text-white bg-slate-950/20' : 'border-transparent text-slate-400'
              }`}
            >
              <Layers className="w-4 h-4" /> NFT Studio
            </button>
            <button
              onClick={() => setActiveTab('bridge')}
              className={`py-3 px-4 font-semibold hover:text-white transition-all uppercase tracking-wider cursor-pointer border-b-2 flex items-center gap-2 ${
                activeTab === 'bridge' ? 'border-pink-500 text-white bg-slate-950/20' : 'border-transparent text-slate-400'
              }`}
            >
              <ArrowRightLeft className="w-4 h-4" /> Cross-Chain Bridge
            </button>
            <button
              onClick={() => setActiveTab('ai')}
              className={`py-3 px-4 font-semibold hover:text-white transition-all uppercase tracking-wider cursor-pointer border-b-2 flex items-center gap-2 ${
                activeTab === 'ai' ? 'border-indigo-400 text-white bg-slate-950/20' : 'border-transparent text-slate-400'
              }`}
            >
              <MessageSquare className="w-4 h-4" /> Aayu AI
            </button>
            <button
              onClick={() => setActiveTab('history')}
              className={`py-3 px-4 font-semibold hover:text-white transition-all uppercase tracking-wider cursor-pointer border-b-2 flex items-center gap-2 ${
                activeTab === 'history' ? 'border-amber-400 text-white bg-[#1a1711]/10' : 'border-transparent text-slate-400'
              }`}
            >
              <History className="w-4 h-4" /> Transactions
            </button>
          </div>

          {/* DYNAMIC DRAW TABS */}
          <div className="flex-1 min-h-[460px]">
            <AnimatePresence mode="wait">
              
              {/* TAB 1: TOKEN ASSETS */}
              {activeTab === 'tokens' && (
                <motion.div
                  key="tokens-pane"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-4"
                >
                  <div className="flex justify-between items-center px-4 py-2 bg-slate-950/40 rounded-2xl border border-slate-900">
                    <span className="text-[10px] font-bold text-cyan-400 uppercase tracking-widest font-mono">
                      Simulated {activeChain.name} Assets
                    </span>
                    <span className="text-[9px] text-slate-500 uppercase tracking-wider font-mono">
                      Prices synced with simulated RPC nodes
                    </span>
                  </div>

                  {/* TOKENS BENTO BUBBLE LIST */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {tokens
                      .filter((token) => token.chainId === activeChain.id)
                      .map((token) => (
                        <div
                          key={token.id}
                          className="p-4 rounded-3xl glass-panel flex justify-between items-center group transition-all hover:bg-slate-900/30 relative overflow-hidden h-24 shadow"
                        >
                          <div className="flex items-center gap-3.5 relative">
                            {/* Token Logo mockup */}
                            <img 
                              src={token.logoUrl} 
                              alt={token.symbol} 
                              referrerPolicy="no-referrer"
                              className="w-10 h-10 object-contain p-1 rounded-xl bg-slate-950/80 border border-slate-900" 
                              onError={(e) => {
                                // Image fallback
                                (e.target as HTMLElement).style.display = 'none';
                              }}
                            />
                            
                            <div>
                              <h4 className="font-bold text-slate-100 text-[13px] leading-tight">{token.name}</h4>
                              <p className="text-[10px] text-slate-500 font-mono mt-0.5">${token.usdPrice.toLocaleString([], { minimumFractionDigits: 2 })} USD</p>
                            </div>
                          </div>

                          <div className="text-right font-mono">
                            <span className="block text-sm font-extrabold text-white">{token.balance.toLocaleString([], { maximumFractionDigits: 4 })}</span>
                            <span className="block text-[10px] text-[#10b981] font-bold mt-0.5">
                              ${(token.balance * token.usdPrice).toLocaleString([], { minimumFractionDigits: 2 })}
                            </span>
                          </div>
                        </div>
                      ))}
                  </div>
                </motion.div>
              )}

              {/* TAB 2: NFT STUDIO MINT & GRID */}
              {activeTab === 'nfts' && (
                <motion.div
                  key="nfts-pane"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="h-full"
                >
                  <NftGallery 
                    activeChain={activeChain} 
                    nfts={nfts} 
                    onMintNFT={handleMintNFT} 
                  />
                </motion.div>
              )}

              {/* TAB 3: BRIDGE COMP COORDINATOR */}
              {activeTab === 'bridge' && (
                <motion.div
                  key="bridge-pane"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="h-full"
                >
                  <BridgeModule 
                    chains={chains} 
                    tokens={tokens} 
                    onAddTransaction={handleAddTransaction} 
                    onUpdateBalance={handleUpdateBalance} 
                  />
                </motion.div>
              )}

              {/* TAB 4: CHATBOT ADVISORY ASSISTANT */}
              {activeTab === 'ai' && (
                <motion.div
                  key="ai-pane"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="h-full"
                >
                  <AiAssistant 
                    activeChain={activeChain} 
                    tokens={tokens} 
                  />
                </motion.div>
              )}

              {/* TAB 5: TRANSACTION HISTORY */}
              {activeTab === 'history' && (
                <motion.div
                  key="history-pane"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-4"
                >
                  <div className="flex justify-between items-center px-4 py-2 bg-slate-950/40 rounded-2xl border border-slate-900">
                    <span className="text-[10px] font-bold text-amber-400 uppercase tracking-widest font-mono">
                      Decentralized Ledger Ledger logs
                    </span>
                    <span className="text-[9px] text-slate-500 uppercase tracking-wider font-mono">
                      Tracks transfers, swap contracts, and bridges
                    </span>
                  </div>

                  {transactions.length === 0 ? (
                    <div className="py-20 text-center text-slate-500 font-mono text-xs border border-dashed border-slate-800 rounded-3xl">
                      💡 Active ledger logs are ready to track incoming payloads.
                    </div>
                  ) : (
                    <div className="space-y-2 max-h-[460px] overflow-y-auto pr-1 font-mono text-[11px]">
                      {transactions.map((tx) => (
                        <div
                          key={tx.id}
                          className="p-3.5 rounded-2xl bg-slate-950/60 border border-slate-900 hover:border-slate-800 flex flex-col md:flex-row justify-between gap-3 items-start md:items-center relative"
                        >
                          <div className="flex items-center gap-3">
                            {/* Type indicators icon */}
                            <div className={`w-8 h-8 rounded-xl flex items-center justify-center border ${
                              tx.type === 'receive' 
                                ? 'bg-emerald-950/30 border-emerald-500/20 text-[#10b981]' 
                                : tx.type === 'bridge'
                                  ? 'bg-pink-950/20 border-pink-500/20 text-pink-400'
                                  : 'bg-indigo-950/30 border-indigo-500/20 text-indigo-400'
                            }`}>
                              {tx.type === 'receive' ? <ArrowDownLeft className="w-4.5 h-4.5" /> : tx.type === 'bridge' ? <ArrowRightLeft className="w-4.5 h-4.5" /> : <ArrowUpRight className="w-4.5 h-4.5" />}
                            </div>

                            <div>
                              <div className="flex items-center gap-1.5 font-bold">
                                <span className="uppercase text-slate-200">{tx.type} CONTRACT</span>
                                <span className="px-1.5 py-0.5 bg-slate-900 text-[8px] text-indigo-400 rounded-md border border-slate-800">{tx.hash}</span>
                              </div>
                              <p className="text-[10px] text-slate-500 mt-1">{tx.notes || 'Asset transfer action complete.'}</p>
                            </div>
                          </div>

                          <div className="text-right flex flex-row md:flex-col justify-between w-full md:w-auto mt-2 md:mt-0 pt-2 md:pt-0 border-t md:border-t-0 border-slate-900/60 text-[10px]">
                            <span className={`block font-extrabold text-[#e2e8f0] ${
                              tx.type === 'receive' ? 'text-[#10b981]' : 'text-slate-200'
                            }`}>
                              {tx.type === 'receive' ? '+' : '-'}{tx.amount} {tx.symbol}
                            </span>
                            <span className="block text-[8px] text-slate-550 mt-1">
                              {new Date(tx.timestamp).toLocaleString([], { hour: '2-digit', minute: '2-digit', month: 'short', day: 'numeric' })}
                            </span>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </motion.div>
              )}

            </AnimatePresence>
          </div>

        </div>

      </main>

      {/* 3. MULTI-CHAIN SEND AND RECEIVE TRANSACTION WIZARD MODAL */}
      <AnimatePresence>
        {isModalOpen && (
          <SendReceiveModal
            isOpen={isModalOpen}
            onClose={() => setIsModalOpen(false)}
            activeChain={activeChain}
            walletAddress={activeAccount.address}
            tokens={tokens}
            onAddTransaction={handleAddTransaction}
            onUpdateBalance={handleUpdateBalance}
          />
        )}
      </AnimatePresence>

    </div>
  );
}
