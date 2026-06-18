import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Shield, Key, ArrowRight, Wallet, RefreshCw, AlertTriangle } from 'lucide-react';
import { MOCK_SEED_PHRASE } from '../data';

interface VaultSetupProps {
  onVaultCreated: (seedPhrase: string, password: string) => void;
}

export default function VaultSetup({ onVaultCreated }: VaultSetupProps) {
  const [mode, setMode] = useState<'welcome' | 'create' | 'import'>('welcome');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [importSeed, setImportSeed] = useState('');
  const [generatedSeed, setGeneratedSeed] = useState('');
  const [copied, setCopied] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  const generateMnemonic = () => {
    setGeneratedSeed(MOCK_SEED_PHRASE);
    setErrorMsg('');
  };

  const handleCreateVaultSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (password.length < 6) {
      setErrorMsg('Password must be at least 6 alphanumeric characters for vault encryption.');
      return;
    }
    if (password !== confirmPassword) {
      setErrorMsg('Passwords do not match.');
      return;
    }
    if (!generatedSeed) {
      setErrorMsg('Please generate a secure visual mnemonic seed key first.');
      return;
    }
    setErrorMsg('');
    onVaultCreated(generatedSeed, password);
  };

  const handleImportVaultSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (password.length < 6) {
      setErrorMsg('Password must be at least 6 characters for local session locking.');
      return;
    }
    if (!importSeed.trim() || importSeed.trim().split(/\s+/).length < 12) {
      setErrorMsg('Secret recovery mnemonic must contain exactly 12 security keys.');
      return;
    }
    setErrorMsg('');
    onVaultCreated(importSeed.trim(), password);
  };

  const handleCopySeed = () => {
    navigator.clipboard.writeText(generatedSeed);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div id="vault-setup-container" className="min-h-screen relative flex items-center justify-center p-4 cyber-grid overflow-hidden bg-[#030206]">
      {/* Decorative neon ambient backdrops */}
      <div className="absolute top-1/4 left-1/4 w-80 h-80 rounded-full bg-indigo-600/10 blur-[120px]" />
      <div className="absolute bottom-1/4 right-1/4 w-96 h-96 rounded-full bg-emerald-500/10 blur-[150px]" />

      <motion.div 
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, ease: 'easeOut' }}
        className="w-full max-w-lg glass-panel p-8 rounded-3xl glow-purple-box relative"
      >
        {/* Holographic scanner active bar */}
        <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-emerald-400 via-indigo-500 to-cyan-400 rounded-t-3xl" />

        {/* Brand Header */}
        <div className="text-center mb-8">
          <motion.div 
            animate={{ rotate: [0, 10, -10, 0] }}
            transition={{ repeat: Infinity, duration: 6, ease: "easeInOut" }}
            className="w-16 h-16 mx-auto mb-4 bg-gradient-to-br from-indigo-500 via-indigo-600 to-emerald-400 rounded-2xl flex items-center justify-center shadow-[0_0_30px_rgba(99,102,241,0.4)]"
          >
            <Wallet className="w-8 h-8 text-white" />
          </motion.div>
          <h1 className="text-3xl font-bold tracking-tight bg-gradient-to-r from-white via-slate-100 to-emerald-400 bg-clip-text text-transparent glow-cyan">
            Aayu Wallet
          </h1>
          <p className="text-xs text-slate-400 mt-2 font-mono uppercase tracking-[0.2em]">
            Metaverse Web3 Multi-Chain Vault
          </p>
        </div>

        {errorMsg && (
          <motion.div 
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-6 p-4 rounded-xl border border-rose-500/20 bg-rose-950/20 text-rose-300 text-xs flex items-center gap-3 font-sans"
          >
            <AlertTriangle className="w-5 h-5 flex-shrink-0 text-rose-400" />
            <span>{errorMsg}</span>
          </motion.div>
        )}

        {/* Mode Selector Panel */}
        {mode === 'welcome' && (
          <div className="space-y-4">
            <div className="text-center mb-8">
              <p className="text-sm text-slate-300">
                Explore a highly customized non-custodial crypto vault designed to manage assets seamlessly across multiple virtual blockscapes. Create a secure local ledger instantly.
              </p>
            </div>

            <div className="grid grid-cols-1 gap-4">
              <motion.button
                whileHover={{ scale: 1.02, borderHorizontalColor: '#10b981' }}
                whileTap={{ scale: 0.98 }}
                onClick={() => {
                  setMode('create');
                  generateMnemonic();
                }}
                className="w-full text-left p-5 rounded-2xl border border-indigo-500/20 bg-indigo-950/10 hover:bg-slate-900/40 flex items-center justify-between transition-all"
                id="btn-create-wallet"
              >
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-indigo-500/20 rounded-xl text-indigo-400">
                    <Key className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-white">Create New Ledger</h3>
                    <p className="text-xs text-slate-400 mt-1">Generate a fresh 12-word seed vault key</p>
                  </div>
                </div>
                <ArrowRight className="w-5 h-5 text-indigo-400" />
              </motion.button>

              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => {
                  setMode('import');
                  setErrorMsg('');
                }}
                className="w-full text-left p-5 rounded-2xl border border-emerald-500/20 bg-[#0c2018]/20 hover:bg-slate-900/40 flex items-center justify-between transition-all"
                id="btn-import-wallet"
              >
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-emerald-500/20 rounded-xl text-emerald-400">
                    <Shield className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-white">Import Secret Mnemonic</h3>
                    <p className="text-xs text-slate-400 mt-1">Restore your assets via an existing 12-word phrase</p>
                  </div>
                </div>
                <ArrowRight className="w-5 h-5 text-emerald-400" />
              </motion.button>
            </div>

            <div className="text-center pt-4">
              <span className="text-[10px] font-mono text-slate-500 tracking-[0.1em] uppercase">
                🔒 Cryptographically secure, local environment encryption
              </span>
            </div>
          </div>
        )}

        {/* Generate Wallet Form */}
        {mode === 'create' && (
          <form onSubmit={handleCreateVaultSubmit} className="space-y-5">
            <div>
              <div className="flex justify-between items-center mb-2">
                <label className="text-xs font-mono uppercase text-indigo-300 tracking-wider">
                  Secret Recovery Seed (Keep safe!)
                </label>
                <button
                  type="button"
                  onClick={generateMnemonic}
                  className="text-xs font-mono text-emerald-400 hover:text-emerald-300 flex items-center gap-1 transition-colors"
                >
                  <RefreshCw className="w-3 h-3" /> Roll Keys
                </button>
              </div>
              <div className="p-4 bg-slate-950/90 rounded-2xl border border-indigo-500/20 text-slate-300 text-xs font-mono text-center relative selection:bg-indigo-500">
                <p className="leading-6 select-all">{generatedSeed}</p>
                <button
                  type="button"
                  onClick={handleCopySeed}
                  className="mt-3 w-full border border-slate-800 hover:border-indigo-500/50 hover:bg-indigo-950/20 text-slate-400 hover:text-slate-200 text-[10px] uppercase font-mono py-1 rounded-lg transition-all"
                >
                  {copied ? '📋 Copied Vault Seed Key!' : '🔗 Copy Words to Clipboard'}
                </button>
              </div>
              <p className="text-[10px] text-slate-500 mt-2 font-semibold">
                ⚠️ Write these down sequentially on physical media. Never reveal this phrase to anyone. It is the un-hashed portal to your multi-chain ledger.
              </p>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-mono uppercase text-slate-400 mb-1 tracking-wider">
                  Create Local Password
                </label>
                <input
                  required
                  type="password"
                  placeholder="Minimum 6 characters"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full px-4 py-3 rounded-xl bg-slate-950/50 border border-slate-800 text-sm focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 transition-all font-mono"
                />
              </div>

              <div>
                <label className="block text-xs font-mono uppercase text-slate-400 mb-1 tracking-wider">
                  Confirm Local Password
                </label>
                <input
                  required
                  type="password"
                  placeholder="Must match password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="w-full px-4 py-3 rounded-xl bg-slate-950/50 border border-slate-800 text-sm focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 transition-all font-mono"
                />
              </div>
            </div>

            <div className="flex justify-between gap-4 pt-4">
              <button
                type="button"
                onClick={() => {
                  setMode('welcome');
                  setErrorMsg('');
                }}
                className="w-1/3 py-3 rounded-xl border border-slate-800 text-xs font-semibold text-slate-400 hover:text-white transition-all uppercase tracking-wider"
              >
                Back
              </button>
              <button
                type="submit"
                className="w-2/3 py-3 rounded-xl bg-gradient-to-r from-indigo-500 to-emerald-400 hover:from-indigo-600 hover:to-emerald-500 text-xs font-bold text-slate-950 transition-all uppercase tracking-wider flex items-center justify-center gap-2"
                id="btn-submit-create-wallet"
              >
                Generate Wallet <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </form>
        )}

        {/* Import Wallet Form */}
        {mode === 'import' && (
          <form onSubmit={handleImportVaultSubmit} className="space-y-5">
            <div>
              <label className="block text-xs font-mono uppercase text-slate-400 mb-2 tracking-wider">
                Paste Secret Mnemonic Seed (12 words)
              </label>
              <textarea
                required
                rows={3}
                placeholder="galaxy visual crystal solar energy quantum..."
                value={importSeed}
                onChange={(e) => setImportSeed(e.target.value)}
                className="w-full p-4 rounded-2xl bg-slate-950/90 border border-emerald-500/20 text-slate-300 text-xs font-mono focus:outline-none focus:ring-1 focus:ring-emerald-500 leading-6"
              />
              <p className="text-[10px] text-slate-500 mt-1">
                Hint: Paste a 12-word space-separated pattern. (e.g. standard mock chain phrases are fully accepted)
              </p>
            </div>

            <div>
              <label className="block text-xs font-mono uppercase text-slate-400 mb-1 tracking-wider">
                Establish Lock Password
              </label>
              <input
                required
                type="password"
                placeholder="Minimum 6 characters"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-3 rounded-xl bg-slate-950/50 border border-slate-800 text-sm focus:outline-none focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500 transition-all font-mono"
              />
            </div>

            <div className="flex justify-between gap-4 pt-4 font-mono">
              <button
                type="button"
                onClick={() => {
                  setMode('welcome');
                  setErrorMsg('');
                }}
                className="w-1/3 py-3 rounded-xl border border-slate-800 text-xs font-semibold text-slate-400 hover:text-white transition-all uppercase tracking-wider"
              >
                Back
              </button>
              <button
                type="submit"
                className="w-2/3 py-3 rounded-xl bg-gradient-to-r from-emerald-400 to-indigo-500 hover:from-emerald-500 hover:to-indigo-600 text-xs font-bold text-slate-950 transition-all uppercase tracking-wider flex items-center justify-center gap-2"
                id="btn-submit-import-wallet"
              >
                Verify & Unlock <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </form>
        )}
      </motion.div>
    </div>
  );
}
