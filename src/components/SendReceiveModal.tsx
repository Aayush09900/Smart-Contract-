import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Send, Copy, ArrowDownLeft, Check, AlertCircle, Info, ExternalLink } from 'lucide-react';
import { Chain, TokenAsset, Transaction } from '../types';

interface SendReceiveModalProps {
  isOpen: boolean;
  onClose: () => void;
  activeChain: Chain;
  walletAddress: string;
  tokens: TokenAsset[];
  onAddTransaction: (tx: Transaction) => void;
  onUpdateBalance: (tokenId: string, newBalance: number) => void;
}

export default function SendReceiveModal({
  isOpen,
  onClose,
  activeChain,
  walletAddress,
  tokens,
  onAddTransaction,
  onUpdateBalance
}: SendReceiveModalProps) {
  const [activeTab, setActiveTab] = useState<'send' | 'receive'>('send');
  const [copied, setCopied] = useState(false);

  // Send states
  const [selectedTokenId, setSelectedTokenId] = useState(tokens[0]?.id || '');
  const [recipient, setRecipient] = useState('');
  const [amount, setAmount] = useState('');
  const [isBroadcasting, setIsBroadcasting] = useState(false);
  const [broadcastingStep, setBroadcastingStep] = useState(0);
  const [txSuccess, setTxSuccess] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  const selectedToken = tokens.find(t => t.id === selectedTokenId) || tokens[0];

  const handleCopyAddress = () => {
    navigator.clipboard.writeText(walletAddress);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const getMaxAmount = () => {
    if (!selectedToken) return '0';
    // Leave a small buffer for gas if native token
    if (selectedToken.id.includes('-native')) {
      const buffer = activeChain.id === 'ethereum' ? 0.005 : activeChain.id === 'polygon' ? 0.1 : 0.001;
      const max = Math.max(0, selectedToken.balance - buffer);
      return max.toFixed(4);
    }
    return selectedToken.balance.toString();
  };

  const handleSendTransaction = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg('');

    if (!selectedToken) {
      setErrorMsg('No token selected.');
      return;
    }

    const numericAmount = parseFloat(amount);
    if (isNaN(numericAmount) || numericAmount <= 0) {
      setErrorMsg('Please enter a valid amount greater than 0.');
      return;
    }

    if (numericAmount > selectedToken.balance) {
      setErrorMsg(`Insufficient ${selectedToken.symbol} balance. Your current ledger is ${selectedToken.balance} ${selectedToken.symbol}.`);
      return;
    }

    // Basic Web3 address validation mock
    let isValidAddr = false;
    if (activeChain.id === 'solana') {
      isValidAddr = recipient.length >= 32 && recipient.length <= 44;
    } else {
      isValidAddr = recipient.startsWith('0x') && recipient.length === 42;
    }

    if (!isValidAddr) {
      setErrorMsg(`Invalid ${activeChain.name} address syntax. Ensure it follows regional cryptographic length requirements.`);
      return;
    }

    // Launch broadcasting simulation sequence
    setIsBroadcasting(true);
    setBroadcastingStep(1); // "Estimating gas..."
    
    setTimeout(() => {
      setBroadcastingStep(2); // "Assembling telemetry..."
      setTimeout(() => {
        setBroadcastingStep(3); // "Broadcasting to miners..."
        setTimeout(() => {
          // Finished! Create Transaction Object
          const isNative = selectedToken.id.includes('-native');
          const finalGasFee = activeChain.id === 'ethereum' ? 4.50 : 0.05;

          const txHash = activeChain.id === 'solana'
            ? '63sXvP' + Math.random().toString(36).substring(2, 10).toUpperCase() + 'zTe'
            : '0x' + Math.random().toString(16).substring(2, 10) + '...f721';

          const newTx: Transaction = {
            id: 'tx-' + Date.now(),
            type: 'send',
            hash: txHash,
            from: walletAddress,
            to: recipient,
            amount: amount,
            symbol: selectedToken.symbol,
            chainId: activeChain.id,
            timestamp: Date.now(),
            status: 'success',
            gasFeeUsd: finalGasFee,
            notes: `Simulated transaction dispatched to ${activeChain.name}`
          };

          // Apply balance reductions
          const finalBal = selectedToken.balance - numericAmount;
          onUpdateBalance(selectedToken.id, finalBal);
          
          // Submit Tx to main log
          onAddTransaction(newTx);
          setTxSuccess(true);
          setIsBroadcasting(false);
          setBroadcastingStep(0);
        }, 1200);
      }, 1000);
    }, 1000);
  };

  const resetSendForm = () => {
    setRecipient('');
    setAmount('');
    setErrorMsg('');
    setTxSuccess(false);
    setIsBroadcasting(false);
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/85 backdrop-blur-xl flex items-center justify-center p-4 z-50 font-mono">
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 15 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 15 }}
        className="w-full max-w-md glass-panel rounded-3xl overflow-hidden shadow-[0_0_50px_rgba(99,102,241,0.25)] relative"
      >
        {/* Decorative Neon top lines */}
        <div className="h-1 w-full bg-gradient-to-r from-cyan-400 via-indigo-500 to-pink-500" />
        
        {/* Header section */}
        <div className="flex justify-between items-center px-6 py-4 border-b border-slate-800/80 bg-slate-950/40">
          <div className="flex gap-4">
            <button
              onClick={() => {
                setActiveTab('send');
                resetSendForm();
              }}
              className={`pb-1 text-xs uppercase tracking-wider font-semibold cursor-pointer ${
                activeTab === 'send' ? 'text-white border-b-2 border-indigo-500' : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              Send Assets
            </button>
            <button
              onClick={() => setActiveTab('receive')}
              className={`pb-1 text-xs uppercase tracking-wider font-semibold cursor-pointer ${
                activeTab === 'receive' ? 'text-white border-b-2 border-emerald-500' : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              Receive Assets
            </button>
          </div>
          <button onClick={onClose} className="p-1.5 rounded-full hover:bg-slate-900 border border-transparent hover:border-slate-800 text-slate-400 hover:text-white transition-all cursor-pointer">
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Modal content body */}
        <div className="p-6">
          <AnimatePresence mode="wait">
            
            {/* Tab 1: RECEIVE PANEL */}
            {activeTab === 'receive' && (
              <motion.div
                key="receive-tab"
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 10 }}
                className="space-y-6 text-center"
              >
                <div className="space-y-2">
                  <span className="text-[10px] text-indigo-400 font-bold uppercase tracking-widest bg-indigo-950/40 border border-indigo-500/20 px-2.5 py-1 rounded-full">
                    {activeChain.name} Incoming Channel
                  </span>
                  <p className="text-xs text-slate-400 mt-2">
                    Accept {activeChain.symbol} and associated tokens into this local non-custodial address.
                  </p>
                </div>

                {/* Simulated Holographic Neon QR Code */}
                <div className="relative w-44 h-44 mx-auto border-2 border-dashed border-emerald-500/30 rounded-2xl flex items-center justify-center p-4 bg-slate-950/70 shadow-[0_0_20px_rgba(16,185,129,0.05)]">
                  {/* Holographic lens scanning overlay */}
                  <div className="absolute inset-0 bg-gradient-to-b from-transparent via-emerald-500/10 to-transparent h-1/3 w-full animate-[holographic-scan_3s_infinite_linear] pointer-events-none" />
                  
                  {/* QR Core Graphic inside */}
                  <div className="w-full h-full relative border border-emerald-500/10 p-1.5 rounded-xl bg-slate-900 flex flex-col justify-between">
                    <div className="flex justify-between">
                      <div className="w-5 h-5 border-t-2 border-l-2 border-emerald-400" />
                      <div className="w-5 h-5 border-t-2 border-r-2 border-emerald-400" />
                    </div>
                    {/* Abstract QR Blocks representing address hash */}
                    <div className="w-28 h-28 mx-auto grid grid-cols-6 gap-1 p-2 opacity-80">
                      {Array.from({ length: 36 }).map((_, i) => (
                        <div
                          key={i}
                          className={`rounded-xs ${
                            (i * 7 + i % 3 + (walletAddress.charCodeAt(i % walletAddress.length) || 0)) % 2 === 0
                              ? 'bg-emerald-400 shadow-[0_0_4px_rgba(16,185,129,0.5)]'
                              : 'bg-transparent'
                          }`}
                        />
                      ))}
                    </div>
                    <div className="flex justify-between">
                      <div className="w-5 h-5 border-b-2 border-l-2 border-emerald-400" />
                      <div className="w-5 h-5 border-b-2 border-r-2 border-emerald-400" />
                    </div>
                  </div>
                </div>

                {/* Copyable Address Display */}
                <div className="p-3 rounded-2xl bg-slate-950 border border-slate-800 text-center relative">
                  <p className="text-[10px] text-slate-500 uppercase tracking-widest mb-1.5 font-bold">Public Deposit Address</p>
                  <p className="text-xs text-slate-200 select-all font-mono break-all font-semibold tracking-wider px-2">
                    {walletAddress}
                  </p>
                  <button
                    onClick={handleCopyAddress}
                    className="mt-3 py-1.5 px-4 mx-auto rounded-lg bg-slate-900 border border-slate-800 hover:border-emerald-500/30 text-[10px] uppercase font-bold text-slate-300 hover:text-emerald-400 flex items-center gap-1.5 transition-all cursor-pointer"
                  >
                    {copied ? (
                      <>
                        <Check className="w-3.5 h-3.5 text-emerald-400" />
                        Copied to Clipboard!
                      </>
                    ) : (
                      <>
                        <Copy className="w-3.5 h-3.5" />
                        Copy Full Address
                      </>
                    )}
                  </button>
                </div>

                <div className="flex justify-center items-center gap-1.5 text-[10px] text-slate-500 font-mono py-1">
                  <Info className="w-3.5 h-3.5" /> Only transmit {activeChain.symbol} compatible assets to avoid protocol failure.
                </div>
              </motion.div>
            )}

            {/* Tab 2: SEND PANEL */}
            {activeTab === 'send' && !txSuccess && (
              <motion.div
                key="send-tab"
                initial={{ opacity: 0, x: 10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
              >
                {!isBroadcasting ? (
                  <form onSubmit={handleSendTransaction} className="space-y-4">
                    {errorMsg && (
                      <div className="p-3 rounded-xl border border-rose-500/20 bg-rose-950/20 text-rose-300 text-[11px] flex items-center gap-2.5">
                        <AlertCircle className="w-4.5 h-4.5 text-rose-400 flex-shrink-0" />
                        <span>{errorMsg}</span>
                      </div>
                    )}

                    {/* SELECT TOKEN */}
                    <div>
                      <label className="block text-[10px] text-indigo-400 uppercase tracking-widest font-bold mb-1.5">Asset Asset</label>
                      <select
                        value={selectedTokenId}
                        onChange={(e) => setSelectedTokenId(e.target.value)}
                        className="w-full px-4 py-3 rounded-xl bg-slate-950 border border-slate-800 focus:border-indigo-500 text-xs text-slate-200 outline-none transition-all"
                      >
                        {tokens
                          .filter(t => t.chainId === activeChain.id)
                          .map((token) => (
                            <option key={token.id} value={token.id} className="bg-slate-950">
                              {token.name} ({token.symbol}) — Bal: {token.balance}
                            </option>
                          ))}
                      </select>
                    </div>

                    {/* RECIPIENT ADDRESS */}
                    <div>
                      <div className="flex justify-between items-center mb-1.5">
                        <label className="block text-[10px] text-indigo-400 uppercase tracking-widest font-bold">Recipient Address</label>
                        <button
                          type="button"
                          onClick={() => setRecipient(activeChain.id === 'solana' ? '9xQiyGx75f8S6MByvG6A6mCc4uN9KxWvM3fC' : '0x742d35Cc6634C0532925a3b844Bc454e4438f44e')}
                          className="text-[9px] text-slate-500 hover:text-indigo-400 flex items-center gap-0.5 cursor-pointer"
                        >
                          📋 Insert Demo Address
                        </button>
                      </div>
                      <input
                        required
                        type="text"
                        placeholder={activeChain.id === 'solana' ? 'Base58 Solana Address...' : 'Hexadecimal address starting with 0x...'}
                        value={recipient}
                        onChange={(e) => setRecipient(e.target.value)}
                        className="w-full px-4 py-3 rounded-xl bg-slate-950 border border-slate-800 focus:border-indigo-500 text-xs text-slate-200 outline-none transition-all placeholder:text-slate-650"
                      />
                    </div>

                    {/* AMOUNT INPUT */}
                    <div>
                      <div className="flex justify-between items-center mb-1.5">
                        <label className="block text-[10px] text-indigo-400 uppercase tracking-widest font-bold">Transfer Amount</label>
                        <span className="text-[10px] text-slate-500">
                          Balance: {selectedToken ? selectedToken.balance : '0'} {selectedToken?.symbol}
                        </span>
                      </div>
                      <div className="relative">
                        <input
                          required
                          type="number"
                          step="any"
                          placeholder="0.0"
                          value={amount}
                          onChange={(e) => setAmount(e.target.value)}
                          className="w-full px-4 py-3 rounded-xl bg-slate-950 border border-slate-800 focus:border-indigo-500 text-xs text-slate-200 outline-none transition-all font-semibold"
                        />
                        <button
                          type="button"
                          onClick={() => setAmount(getMaxAmount())}
                          className="absolute right-3 top-2.5 px-2 py-1 rounded bg-indigo-950/50 border border-indigo-500/20 text-[9px] font-bold text-indigo-400 hover:bg-indigo-500 hover:text-slate-950 cursor-pointer"
                        >
                          MAX
                        </button>
                      </div>
                    </div>

                    {/* TRANSACTION FEES INFO */}
                    <div className="p-3.5 rounded-2xl border border-slate-800/80 bg-slate-950/40 text-[10px] space-y-1.5 text-slate-400 font-mono">
                      <div className="flex justify-between">
                        <span>Gas Network Fee:</span>
                        <span className="text-slate-200">
                          {activeChain.id === 'ethereum' ? '0.001 ETH (~$3.45)' : '0.05 POL (~$0.03)'}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span>Speed Status:</span>
                        <span className="text-emerald-400 flex items-center gap-1">⚡ Supercharged</span>
                      </div>
                    </div>

                    <button
                      type="submit"
                      className="w-full mt-2 py-3 rounded-xl bg-gradient-to-r from-indigo-500 to-pink-500 hover:from-indigo-600 hover:to-pink-600 font-bold text-xs uppercase text-slate-950 tracking-wider shadow-lg shadow-indigo-950/50 cursor-pointer"
                    >
                      🚀 Launch Crypto Payload
                    </button>
                  </form>
                ) : (
                  /* Broadcasting Loading state */
                  <div className="py-12 flex flex-col items-center justify-center text-center space-y-6">
                    <div className="relative">
                      <div className="w-16 h-16 rounded-full border-4 border-slate-800 border-t-indigo-500 animate-spin" />
                      <Send className="absolute inset-0 m-auto w-6 h-6 text-indigo-300 animate-pulse" />
                    </div>
                    <div>
                      <h3 className="font-bold text-slate-100 uppercase tracking-widest text-xs">
                        Broadcasting Transaction...
                      </h3>
                      <div className="mt-3 space-y-1 font-mono text-[10px] text-slate-400">
                        <p className={broadcastingStep >= 1 ? "text-indigo-400 font-semibold" : ""}>
                          {broadcastingStep >= 1 ? '✅ Est. Gas Matrix Resolved' : '◦ Processing smart ledger telemetry...'}
                        </p>
                        <p className={broadcastingStep >= 2 ? "text-purple-400 font-semibold" : ""}>
                          {broadcastingStep >= 2 ? '✅ Assembling transaction block payload' : '◦ Generating distributed signature...'}
                        </p>
                        <p className={broadcastingStep >= 3 ? "text-pink-400 font-semibold" : ""}>
                          {broadcastingStep >= 3 ? '⚡ Mining block: Propagating to valid validators' : '◦ Syncing cross-chain logs...'}
                        </p>
                      </div>
                    </div>
                  </div>
                )}
              </motion.div>
            )}

            {/* SEND SUCCESS PANEL */}
            {txSuccess && (
              <motion.div
                key="success-panel"
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                className="py-8 text-center space-y-6"
              >
                <div className="w-16 h-16 mx-auto bg-emerald-500/20 border border-emerald-500/50 rounded-full flex items-center justify-center shadow-[0_0_20px_rgba(16,185,129,0.3)]">
                  <Check className="w-8 h-8 text-emerald-400" />
                </div>
                <div className="space-y-2">
                  <h3 className="text-base font-bold text-white uppercase tracking-wider">Payload Transmitted Successfully</h3>
                  <p className="text-xs text-slate-400 px-4">
                    Your simulated {selectedToken?.symbol} transfer was executed in the {activeChain.name} ledger and recorded in block metrics.
                  </p>
                </div>

                <div className="p-3.5 bg-slate-950 border border-slate-800 rounded-2xl text-[10px] space-y-1 text-left font-mono">
                  <p className="text-slate-500 uppercase tracking-wider font-bold">Block Details</p>
                  <p className="text-slate-300"><span className="text-slate-500">Hash:</span> {activeChain.id === 'solana' ? 'SolSol6297' : '0x62a8...e739'}</p>
                  <p className="text-slate-300"><span className="text-slate-500">Amount:</span> {amount} {selectedToken?.symbol}</p>
                  <p className="text-slate-300"><span className="text-slate-500">Recipient:</span> {recipient.substring(0, 8)}...{recipient.substring(recipient.length - 8)}</p>
                </div>

                <div className="flex gap-4">
                  <a
                    href={activeChain.blockExplorer}
                    target="_blank"
                    rel="noreferrer"
                    className="w-1/2 py-2.5 rounded-xl border border-slate-800 hover:border-slate-700 text-[10px] uppercase font-bold text-slate-300 flex items-center justify-center gap-1.5 transition-all"
                  >
                    View Etherscan <ExternalLink className="w-3.5 h-3.5" />
                  </a>
                  <button
                    onClick={() => {
                      resetSendForm();
                      onClose();
                    }}
                    className="w-1/2 py-2.5 rounded-xl bg-emerald-400 hover:bg-emerald-500 text-slate-950 text-[10px] font-bold uppercase tracking-wider shadow-lg"
                  >
                    Close Terminal
                  </button>
                </div>
              </motion.div>
            )}

          </AnimatePresence>
        </div>
      </motion.div>
    </div>
  );
}
