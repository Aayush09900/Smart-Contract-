import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { RefreshCw, ArrowRightLeft, ArrowDown, HelpCircle, CheckCircle, Flame, Server } from 'lucide-react';
import { Chain, TokenAsset, Transaction } from '../types';

interface BridgeModuleProps {
  chains: Chain[];
  tokens: TokenAsset[];
  onAddTransaction: (tx: Transaction) => void;
  onUpdateBalance: (tokenId: string, newBalance: number) => void;
}

export default function BridgeModule({
  chains,
  tokens,
  onAddTransaction,
  onUpdateBalance
}: BridgeModuleProps) {
  const [srcChainId, setSrcChainId] = useState<'ethereum' | 'polygon' | 'solana' | 'avalanche'>('ethereum');
  const [destChainId, setDestChainId] = useState<'polygon' | 'solana' | 'avalanche' | 'bsc'>('polygon');
  const [amount, setAmount] = useState('');
  const [selectedSymbol, setSelectedSymbol] = useState<'USDT' | 'USDC' | 'ETH'>('USDT');

  // Animation states
  const [isBridging, setIsBridging] = useState(false);
  const [bridgeStep, setBridgeStep] = useState(0);
  const [bridgeSuccess, setBridgeSuccess] = useState(false);
  const [txDetails, setTxDetails] = useState<any>(null);
  const [errorMsg, setErrorMsg] = useState('');

  const srcChain = chains.find(c => c.id === srcChainId)!;
  const destChain = chains.find(c => c.id === destChainId)!;

  // Find token matching symbol on source chain
  const srcToken = tokens.find(t => t.chainId === srcChainId && t.symbol.toUpperCase().includes(selectedSymbol));
  // Find token matching symbol on dest chain
  const destToken = tokens.find(t => t.chainId === destChainId && t.symbol.toUpperCase().includes(selectedSymbol));

  const handleSwapChains = () => {
    // If destination chain is a valid source chain base
    if (['ethereum', 'polygon', 'solana', 'avalanche'].includes(destChainId)) {
      const temp = srcChainId;
      setSrcChainId(destChainId as any);
      setDestChainId(temp as any);
    }
  };

  const handleBridge = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg('');

    if (srcChainId === destChainId) {
      setErrorMsg('Source network and Destination network must represent distinct blockscapes.');
      return;
    }

    if (!srcToken || !destToken) {
      setErrorMsg(`Asset route for ${selectedSymbol} is currently disconnected across these layers.`);
      return;
    }

    const numericAmount = parseFloat(amount);
    if (isNaN(numericAmount) || numericAmount <= 0) {
      setErrorMsg('Please enter a valid bridge amount.');
      return;
    }

    if (numericAmount > srcToken.balance) {
      setErrorMsg(`Insufficient ${selectedSymbol} balance on ${srcChain.name}. You hold ${srcToken.balance} ${selectedSymbol}.`);
      return;
    }

    // Launch bridge simulation checkpoint
    setIsBridging(true);
    setBridgeStep(1); // "Locking assets in Escrow Vault"

    setTimeout(() => {
      setBridgeStep(2); // "Syncing distributed oracle signatures"
      setTimeout(() => {
        setBridgeStep(3); // "Validating block receipts"
        setTimeout(() => {
          setBridgeStep(4); // "Minting assets on target blockscape"
          setTimeout(() => {
            // Success! Add transaction + update balance
            const bridgeGasFee = srcChainId === 'ethereum' ? 12.50 : 0.40;
            const hash = '0x' + Math.random().toString(16).substring(2, 10).toUpperCase() + '...BRID';

            const newTx: Transaction = {
              id: 'bridge-' + Date.now(),
              type: 'bridge',
              hash: hash,
              from: srcChain.name + ' Smart Contract',
              to: destChain.name + ' Smart Contract',
              amount: amount,
              symbol: selectedSymbol,
              chainId: srcChainId,
              targetChainId: destChainId,
              timestamp: Date.now(),
              status: 'success',
              gasFeeUsd: bridgeGasFee,
              notes: `Seamlessly bridged ${amount} ${selectedSymbol} from ${srcChain.name} to ${destChain.name}`
            };

            // Deduct source token balance
            onUpdateBalance(srcToken.id, srcToken.balance - numericAmount);
            // Credit dest token balance
            onUpdateBalance(destToken.id, destToken.balance + numericAmount);
            
            setTxDetails({
              amount,
              symbol: selectedSymbol,
              src: srcChain.name,
              dest: destChain.name,
              hash
            });

            onAddTransaction(newTx);
            setBridgeSuccess(true);
            setIsBridging(false);
            setBridgeStep(0);
          }, 1000);
        }, 1100);
      }, 1100);
    }, 1000);
  };

  return (
    <div id="bridge-module-container" className="glass-panel p-6 rounded-3xl relative overflow-hidden flex flex-col justify-between h-full">
      {/* Holographic scanner laser effect */}
      <div className="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-cyan-400 via-indigo-500 to-pink-500" />

      <div>
        <div className="flex justify-between items-center mb-5">
          <div>
            <h2 className="text-sm font-bold uppercase tracking-widest text-slate-100 flex items-center gap-2">
              <span>🌉 Cross-Chain Bridge</span>
            </h2>
            <p className="text-[10px] text-slate-400 mt-1">
              Frictional-free capital relay between isolated layer networks.
            </p>
          </div>
          <RefreshCw className="w-4 h-4 text-slate-500 hover:text-cyan-400 animate-spin-slow transition-all cursor-pointer" />
        </div>

        <AnimatePresence mode="wait">
          {!isBridging && !bridgeSuccess && (
            <motion.form
              key="bridge-form"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onSubmit={handleBridge}
              className="space-y-4 font-mono text-xs"
            >
              {errorMsg && (
                <div className="p-3 border border-rose-500/20 bg-rose-950/20 text-rose-300 text-[10px] rounded-xl">
                  {errorMsg}
                </div>
              )}

              {/* SOURCE CHAIN PANEL */}
              <div className="p-4 rounded-2xl bg-slate-950/80 border border-slate-900 relative">
                <span className="absolute top-2.5 right-3 text-[8px] bg-indigo-950/60 text-indigo-400 border border-indigo-500/20 px-2 py-0.5 rounded-full font-bold uppercase tracking-wider">
                  Origin network
                </span>
                <label className="block text-slate-500 uppercase tracking-widest text-[9px] mb-2 font-bold">Bridge Out From</label>
                
                <div className="flex items-center justify-between">
                  <select
                    value={srcChainId}
                    onChange={(e) => setSrcChainId(e.target.value as any)}
                    className="bg-transparent text-slate-100 font-semibold outline-none py-1 select-none pr-3 scale-105 cursor-pointer"
                  >
                    <option value="ethereum" className="bg-slate-950">🌐 Ethereum</option>
                    <option value="polygon" className="bg-slate-950">💜 Polygon</option>
                    <option value="solana" className="bg-slate-950">⚡ Solana</option>
                    <option value="avalanche" className="bg-slate-950">🔺 Avalanche</option>
                  </select>

                  <div className="text-right text-[10px]">
                    <span className="text-slate-500 block">Balance</span>
                    <span className="text-slate-200 font-bold">
                      {srcToken ? srcToken.balance.toFixed(3) : '0'} {selectedSymbol}
                    </span>
                  </div>
                </div>
              </div>

              {/* REVERSIBLE COMPACT SWITCHER BUTTON */}
              <div className="flex justify-center -my-2.5 relative z-10">
                <button
                  type="button"
                  onClick={handleSwapChains}
                  className="p-2.5 rounded-full bg-slate-900 border border-slate-800 text-indigo-400 hover:text-white hover:border-indigo-500/50 hover:bg-slate-950/90 transition-all cursor-pointer shadow-md shadow-black"
                >
                  <ArrowDown className="w-4 h-4" />
                </button>
              </div>

              {/* DESTINATION CHAIN PANEL */}
              <div className="p-4 rounded-2xl bg-slate-950/80 border border-slate-900 relative">
                <span className="absolute top-2.5 right-3 text-[8px] bg-emerald-950/60 text-emerald-400 border border-emerald-500/20 px-2 py-0.5 rounded-full font-bold uppercase tracking-wider">
                  Target network
                </span>
                <label className="block text-slate-500 uppercase tracking-widest text-[9px] mb-2 font-bold">Deliver asset To</label>
                
                <div className="flex items-center justify-between">
                  <select
                    value={destChainId}
                    onChange={(e) => setDestChainId(e.target.value as any)}
                    className="bg-transparent text-slate-100 font-semibold outline-none py-1 select-none pr-3 scale-105 cursor-pointer"
                  >
                    <option value="polygon" className="bg-slate-950">💜 Polygon PoS</option>
                    <option value="solana" className="bg-slate-950">⚡ Solana Beta</option>
                    <option value="avalanche" className="bg-slate-950">🔺 Avalanche C-Chain</option>
                    <option value="bsc" className="bg-slate-950">🟡 BSC Smart Chain</option>
                  </select>

                  <div className="text-right text-[10px]">
                    <span className="text-slate-500 block">Pending bal</span>
                    <span className="text-slate-200 font-bold">
                      {destToken ? destToken.balance.toFixed(3) : '0'} {selectedSymbol}
                    </span>
                  </div>
                </div>
              </div>

              {/* ASSET SELECT & AMOUNT */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-slate-500 uppercase tracking-widest text-[9px] mb-1.5 font-bold">Select Token</label>
                  <select
                    value={selectedSymbol}
                    onChange={(e) => setSelectedSymbol(e.target.value as any)}
                    className="w-full px-3 py-2.5 rounded-xl bg-slate-950 border border-slate-900 focus:border-indigo-500 text-slate-200 font-semibold outline-none"
                  >
                    <option value="USDT">Tether (USDT)</option>
                    <option value="USDC">USD Coin (USDC)</option>
                    <option value="ETH">Ethereum (ETH)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-slate-500 uppercase tracking-widest text-[9px] mb-1.5 font-bold">Transfer Amount</label>
                  <div className="relative">
                    <input
                      required
                      type="number"
                      step="any"
                      placeholder="0.0"
                      value={amount}
                      onChange={(e) => setAmount(e.target.value)}
                      className="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-900 focus:border-indigo-500 text-slate-200 leading-none outline-none text-xs font-semibold"
                    />
                    <button
                      type="button"
                      onClick={() => srcToken && setAmount(srcToken.balance.toString())}
                      className="absolute right-2.5 top-1.5 px-1.5 py-0.5 rounded bg-indigo-950 text-[8px] font-bold text-indigo-400 hover:bg-indigo-500 hover:text-slate-950 cursor-pointer"
                    >
                      MAX
                    </button>
                  </div>
                </div>
              </div>

              {/* QUOTE AND COST CHECKLIST */}
              <div className="p-3.5 rounded-2xl bg-slate-950/50 border border-slate-900/60 text-[10px] space-y-1 text-slate-400 font-mono">
                <div className="flex justify-between">
                  <span>Simulated Bridge Fee:</span>
                  <span className="text-slate-200 font-bold">{srcChainId === 'ethereum' ? '$8.50 USDT' : '$0.15 USDT'}</span>
                </div>
                <div className="flex justify-between">
                  <span>Transfer Speed:</span>
                  <span className="text-cyan-400 font-bold">~ 45 seconds</span>
                </div>
                <div className="flex justify-between">
                  <span>Slippage Protection:</span>
                  <span className="text-emerald-400 flex items-center gap-0.5 font-bold">🔒 Secure 0.1%</span>
                </div>
              </div>

              <button
                type="submit"
                className="w-full py-3 rounded-2xl bg-gradient-to-r from-cyan-500 via-indigo-500 to-emerald-400 hover:from-cyan-600 hover:to-emerald-500 text-slate-950 font-bold uppercase tracking-wider text-xs shadow-lg shadow-indigo-950/40 cursor-pointer"
              >
                🌉 Initiate Interchain Bridge
              </button>
            </motion.form>
          )}

          {/* ACTIVE BRIDGING CHECKPOINT ANIMATION */}
          {isBridging && (
            <motion.div
              key="bridging-loader"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="py-10 flex flex-col justify-center items-center text-center space-y-8"
            >
              {/* Spinning portals animation */}
              <div className="relative w-24 h-24 flex items-center justify-center">
                <div className="absolute inset-0 rounded-full border-2 border-dashed border-cyan-400 animate-[spin_10s_infinite_linear]" />
                <div className="absolute inset-2 rounded-full border-2 border-dotted border-indigo-500 animate-[spin_6s_infinite_linear_reverse]" />
                <div className="absolute inset-4 rounded-full border-2 border-slate-800 flex items-center justify-center bg-slate-950">
                  <ArrowRightLeft className="w-6 h-6 text-cyan-400 animate-pulse" />
                </div>
              </div>

              <div className="space-y-4">
                <div className="text-xs uppercase tracking-widest text-slate-100 font-bold">
                  Bridging: {srcChain.symbol} ➔ {destChain.symbol}
                </div>
                
                {/* Active checkpoints matching bridge steps */}
                <div className="space-y-2 text-[10px] text-left opacity-90 border border-slate-900 bg-slate-950/60 p-4 rounded-2xl max-w-xs mx-auto">
                  <div className={`flex items-center gap-2 ${bridgeStep >= 1 ? 'text-cyan-400 font-bold' : 'text-slate-500'}`}>
                    <div className={`w-1.5 h-1.5 rounded-full ${bridgeStep >= 1 ? 'bg-cyan-400' : 'bg-slate-700'}`} />
                    <span>{bridgeStep >= 1 ? '✅ Locked ' + amount + ' ' + selectedSymbol + ' on Escrow' : '◦ Intercepting core tokens'}</span>
                  </div>
                  
                  <div className={`flex items-center gap-2 ${bridgeStep >= 2 ? 'text-indigo-400 font-bold' : 'text-slate-500'}`}>
                    <div className={`w-1.5 h-1.5 rounded-full ${bridgeStep >= 2 ? 'bg-indigo-400' : 'bg-slate-700'}`} />
                    <span>{bridgeStep >= 2 ? '✅ Distributed Oracles Authenticated' : '◦ Validating node signatures'}</span>
                  </div>

                  <div className={`flex items-center gap-2 ${bridgeStep >= 3 ? 'text-pink-400 font-bold' : 'text-slate-500'}`}>
                    <div className={`w-1.5 h-1.5 rounded-full ${bridgeStep >= 3 ? 'bg-pink-400' : 'bg-slate-700'}`} />
                    <span>{bridgeStep >= 3 ? '✅ Interchain State Confirmed' : '◦ Generating relay block root'}</span>
                  </div>

                  <div className={`flex items-center gap-2 ${bridgeStep >= 4 ? 'text-emerald-400 font-bold' : 'text-slate-500'}`}>
                    <div className={`w-1.5 h-1.5 rounded-full ${bridgeStep >= 4 ? 'bg-emerald-400 animate-pulse' : 'bg-slate-700'}`} />
                    <span>{bridgeStep >= 4 ? '⚡ Redeeming wrapped asset on ' + destChain.symbol : '◦ Processing smart contracts'}</span>
                  </div>
                </div>
              </div>
            </motion.div>
          )}

          {/* BRIDGE COMPLETED SUCCESS SCREEN */}
          {bridgeSuccess && txDetails && (
            <motion.div
              key="bridge-success"
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="py-6 text-center space-y-6 font-mono"
            >
              <div className="w-14 h-14 bg-emerald-500/10 border border-emerald-500/30 rounded-full flex items-center justify-center mx-auto shadow-[0_0_20px_rgba(16,185,129,0.15)]">
                <CheckCircle className="w-8 h-8 text-emerald-400" />
              </div>

              <div>
                <h3 className="text-cyan-400 font-bold text-xs uppercase tracking-widest">Asset Inter-bridged!</h3>
                <p className="text-[10px] text-slate-400 mt-1.5 px-4">
                  Successfully relocated {txDetails.amount} {txDetails.symbol} across the ledger barrier.
                </p>
              </div>

              <div className="p-4 bg-slate-950 border border-slate-900 rounded-2xl text-[10px] space-y-2 text-left">
                <div className="flex justify-between">
                  <span className="text-slate-500">Relay Root:</span>
                  <span className="text-slate-300 font-semibold">{txDetails.hash}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">From blockscape:</span>
                  <span className="text-slate-350">{txDetails.src}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Into blockscape:</span>
                  <span className="text-slate-350">{txDetails.dest}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Credited payload:</span>
                  <span className="text-emerald-400 font-bold">+{txDetails.amount} {txDetails.symbol}</span>
                </div>
              </div>

              <button
                onClick={() => {
                  setBridgeSuccess(false);
                  setAmount('');
                  setTxDetails(null);
                }}
                className="w-full py-2.5 rounded-xl border border-slate-800 hover:border-slate-700 bg-slate-900 hover:bg-slate-950 text-[10px] uppercase font-bold text-slate-300 tracking-wider shadow"
              >
                Perform another bridge
              </button>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Safety warnings footer */}
      <div className="pt-4 border-t border-slate-900/80 flex items-center gap-2.5 text-[9px] text-slate-500 font-mono">
        <Server className="w-3.5 h-3.5 text-slate-600 flex-shrink-0" />
        <span>Bridge operations use the simulated Aayu Protocol. No actual real assets are locked, allowing free experimentation.</span>
      </div>
    </div>
  );
}
