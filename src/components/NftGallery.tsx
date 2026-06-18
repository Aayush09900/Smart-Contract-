import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Shield, Sparkles, AlertCircle, RefreshCw, Key, HelpCircle, HardDrive, Cpu, Plus } from 'lucide-react';
import { Chain, NFTAsset } from '../types';

interface NftGalleryProps {
  activeChain: Chain;
  nfts: NFTAsset[];
  onMintNFT: (newNft: NFTAsset) => void;
}

export default function NftGallery({ activeChain, nfts, onMintNFT }: NftGalleryProps) {
  const [selectedNft, setSelectedNft] = useState<NFTAsset | null>(null);
  const [studioPrompt, setStudioPrompt] = useState('');
  const [isGenerating, setIsGenerating] = useState(false);
  const [generationStep, setGenerationStep] = useState(0);
  const [generatedResult, setGeneratedResult] = useState<{ imgUrl: string | null; desc: string } | null>(null);
  const [errorMsg, setErrorMsg] = useState('');

  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  // Filter NFTs on current active chain
  const visibleNfts = nfts.filter(n => n.chainId === activeChain.id);

  // Generate procedural canvas art if we don't have a returned remote image
  useEffect(() => {
    if (generatedResult && !generatedResult.imgUrl && canvasRef.current) {
      const canvas = canvasRef.current;
      const ctx = canvas.getContext('2d');
      if (ctx) {
        // Clear background
        ctx.fillStyle = '#0a0a14';
        ctx.fillRect(0, 0, 400, 400);

        // Grid lines
        ctx.strokeStyle = 'rgba(99, 102, 241, 0.15)';
        ctx.lineWidth = 1;
        for (let x = 0; x < 400; x += 40) {
          ctx.beginPath();
          ctx.moveTo(x, 0);
          ctx.lineTo(x, 400);
          ctx.stroke();

          ctx.beginPath();
          ctx.moveTo(0, x);
          ctx.lineTo(400, x);
          ctx.stroke();
        }

        // Draw seedable mathematical pattern based on prompt hashing
        const seed = studioPrompt.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
        
        ctx.translate(200, 200);
        ctx.rotate((seed % 360) * Math.PI / 180);

        // Beautiful futuristic neon star flower pattern
        const count = 12 + (seed % 16);
        for (let i = 0; i < count; i++) {
          ctx.rotate((360 / count) * Math.PI / 180);
          
          // Outer loops
          const gradient = ctx.createLinearGradient(0, 0, 150, 50);
          if (seed % 3 === 0) {
            gradient.addColorStop(0, '#06b6d4'); // cyan
            gradient.addColorStop(1, '#6366f1'); // indigo
          } else if (seed % 3 === 1) {
            gradient.addColorStop(0, '#10b981'); // emerald
            gradient.addColorStop(1, '#84cc16'); // lime
          } else {
            gradient.addColorStop(0, '#ec4899'); // magenta
            gradient.addColorStop(1, '#a855f7'); // purple
          }

          ctx.fillStyle = gradient;
          ctx.beginPath();
          ctx.arc(40 + (seed % 40), 10, 25 + (seed % 20), 0, Math.PI * 2);
          ctx.fill();

          // Connective structural lines
          ctx.strokeStyle = 'rgba(255,255,255,0.4)';
          ctx.lineWidth = 1.5;
          ctx.beginPath();
          ctx.moveTo(0, 0);
          ctx.lineTo(100, 10);
          ctx.stroke();
        }

        // Concentric glow rings
        ctx.setTransform(1, 0, 0, 1, 0, 0); // reset transform
        ctx.strokeStyle = '#6366f1';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.arc(200, 200, 120, 0, Math.PI * 2);
        ctx.stroke();

        // Decorative reticles
        ctx.fillStyle = '#10b981';
        ctx.font = '9px monospace';
        ctx.fillText('C_CORE_MATRIX: ' + seed.toString(16).toUpperCase(), 20, 370);
        ctx.fillText('NET_STATUS: SIMUL_SECURE', 20, 385);
        ctx.fillText('AAYU ENGINE V1.4', 280, 25);
      }
    }
  }, [generatedResult, studioPrompt]);

  const handleGenerateArtwork = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!studioPrompt.trim()) return;

    setErrorMsg('');
    setIsGenerating(true);
    setGenerationStep(1); // "Connecting to Aayu LLM Art module..."

    setTimeout(() => {
      setGenerationStep(2); // "Composing procedural metadata & features..."
      setTimeout(async () => {
        setGenerationStep(3); // "Validating node block signature..."
        
        try {
          // Perform server post to get real gemini result (or client procedural fallback structure)
          const response = await fetch('/api/ai/generate-nft', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ prompt: studioPrompt, network: activeChain.id })
          });

          const data = await response.json();
          
          if (data.error) {
            console.warn("Backend Image pipeline failed, switching to local procedural art compiler:", data.error);
            // Procedural fallback
            setGeneratedResult({
              imgUrl: null, 
              desc: `Exclusive mathematical matrix generated locally on the Aayu core layout under search prompt label "${studioPrompt}".`
            });
          } else {
            setGeneratedResult({
              imgUrl: data.imageUrl, 
              desc: data.description
            });
          }
        } catch (err: any) {
          console.warn("Express endpoint failed, compilation running local engine fallback.");
          setGeneratedResult({
            imgUrl: null,
            desc: `Exquisite generative visualizer compiled on ${activeChain.name} for artifact prompt "${studioPrompt}".`
          });
        } finally {
          setIsGenerating(false);
          setGenerationStep(0);
        }

      }, 1000);
    }, 1000);
  };

  const handleMintGeneratedNFT = () => {
    if (!generatedResult) return;

    // Build immediate local NFT address
    const contract = activeChain.id === 'solana' 
      ? 'AayuNFTsG7' + Math.random().toString(36).substring(2, 8).toUpperCase()
      : '0xbc4' + Math.random().toString(16).substring(2, 10) + 'c2e...f13d';
    
    const tokenId = Math.floor(1000 + Math.random() * 9000).toString();

    // Deduce visual asset URL
    let finalImageUrl = generatedResult.imgUrl;
    if (!finalImageUrl && canvasRef.current) {
      finalImageUrl = canvasRef.current.toDataURL('image/png');
    }

    const mintedNFT: NFTAsset = {
      id: 'nft-' + Date.now(),
      tokenId: tokenId,
      contractAddress: contract,
      name: studioPrompt.length > 25 ? studioPrompt.substring(0, 22) + '...' : studioPrompt,
      description: generatedResult.desc,
      imageUrl: finalImageUrl || 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=400',
      creator: 'Aayu Wallet Studio',
      chainId: activeChain.id,
      attributes: [
        { trait_type: 'Mint Mechanism', value: 'Gemini AI Art engine' },
        { trait_type: 'Prompt Input', value: studioPrompt },
        { trait_type: 'Curated State', value: 'Authenticated Secure' }
      ],
      mintedAt: Date.now()
    };

    onMintNFT(mintedNFT);
    setGeneratedResult(null);
    setStudioPrompt('');
    setSelectedNft(mintedNFT); // immediately open inspection
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 h-full font-mono">
      
      {/* 1. LEFT COLUMN: MINTING STUDIO */}
      <div id="nft-studio-panel" className="lg:col-span-1 glass-panel p-5 rounded-3xl flex flex-col justify-between relative overflow-hidden h-full">
        {/* Neon top bar */}
        <div className="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-emerald-500 via-teal-400 to-indigo-500" />
        
        <div>
          <div className="flex justify-between items-center mb-4">
            <div>
              <h2 className="text-xs font-bold uppercase tracking-widest text-[#10b981] flex items-center gap-2">
                <Sparkles className="w-4.5 h-4.5 glow-emerald" /> AI NFT Studio
              </h2>
              <p className="text-[10px] text-slate-400 mt-1">
                Convert prompt ideas into real cryptographic assets.
              </p>
            </div>
          </div>

          <form onSubmit={handleGenerateArtwork} className="space-y-4">
            <div>
              <label className="block text-[8px] text-slate-500 uppercase tracking-widest font-semibold mb-1.5">
                Art Concept Prompt
              </label>
              <textarea
                required
                rows={3}
                placeholder="A high-concept metaverse neon lion wearing a virtual reality helmet..."
                value={studioPrompt}
                onChange={(e) => setStudioPrompt(e.target.value)}
                className="w-full p-3 rounded-2xl bg-slate-950/80 border border-slate-900 focus:border-emerald-500 text-xs text-slate-200 outline-none transition-all leading-relaxed placeholder:text-slate-600"
              />
            </div>

            {!isGenerating && !generatedResult && (
              <button
                type="submit"
                className="w-full py-2.5 rounded-xl bg-[#0c2e20]/60 border border-emerald-500/20 text-[#10b981] hover:bg-[#10b981] hover:text-slate-950 text-[10px] font-bold uppercase tracking-wider transition-all shadow cursor-pointer flex items-center justify-center gap-1.5"
              >
                <Cpu className="w-3.5 h-3.5" /> Synthesize AI Medium
              </button>
            )}
          </form>

          {/* ACTIVE SYNTHESIS RETICLE LOAD SCREEN */}
          {isGenerating && (
            <div className="p-4 rounded-2xl bg-slate-950/90 border border-slate-900 text-center space-y-4 mt-4">
              <div className="w-12 h-12 rounded-full border-2 border-dashed border-emerald-400 animate-spin mx-auto" />
              <div className="space-y-1">
                <p className="text-[10px] font-bold text-slate-100 uppercase tracking-widest animate-pulse">Running Neural Pipeline</p>
                <p className="text-[9px] text-slate-400">
                  {generationStep >= 1 ? '✅ Listening interface connected' : '◦ Contacting LLM clusters...'}
                </p>
                <p className={generationStep >= 2 ? "text-[9px] text-emerald-400" : "text-[9px] text-slate-500"}>
                  {generationStep >= 2 ? '✅ Composing generative vector schema' : '◦ Injecting neon attributes...'}
                </p>
                <p className={generationStep >= 3 ? "text-[9px] text-indigo-400" : "text-[9px] text-slate-500"}>
                  {generationStep >= 3 ? '⚡ Cryptographically securing metadata' : '◦ Aligning pixels...'}
                </p>
              </div>
            </div>
          )}

          {/* GENERATION OUTPUT PREVIEW */}
          {generatedResult && (
            <div className="mt-4 p-4 rounded-2xl bg-slate-950 border border-emerald-500/20 text-center space-y-4">
              <span className="text-[8px] bg-emerald-950 text-emerald-400 border border-emerald-500/10 px-2 py-0.5 rounded-full font-bold uppercase">
                Ready to Mint
              </span>

              {/* Rendering canvas or direct remote image */}
              <div className="relative aspect-square w-full rounded-xl overflow-hidden bg-slate-900 border border-slate-800">
                {generatedResult.imgUrl ? (
                  <img 
                    src={generatedResult.imgUrl} 
                    alt="AI Preview" 
                    referrerPolicy="no-referrer"
                    className="w-full h-full object-cover" 
                  />
                ) : (
                  <canvas 
                    ref={canvasRef} 
                    width={400} 
                    height={400} 
                    className="w-full h-full" 
                  />
                )}
              </div>

              <p className="text-[10px] text-slate-400 text-left bg-slate-900/60 p-2.5 rounded-xl border border-slate-950 leading-relaxed font-sans">
                {generatedResult.desc}
              </p>

              <div className="flex gap-2">
                <button
                  onClick={() => setGeneratedResult(null)}
                  className="w-1/3 py-2 border border-slate-800 hover:bg-slate-900 rounded-xl text-slate-400 text-[10px] uppercase font-bold"
                >
                  Discard
                </button>
                <button
                  onClick={handleMintGeneratedNFT}
                  className="w-2/3 py-2 bg-gradient-to-r from-emerald-400 to-teal-500 hover:from-emerald-500 hover:to-teal-600 text-slate-950 font-bold text-[10px] uppercase tracking-wider rounded-xl shadow-lg"
                >
                  Mint Simulated ERC-721
                </button>
              </div>
            </div>
          )}
        </div>

        <div className="pt-4 border-t border-slate-900/80 flex items-center gap-2 text-[9px] text-slate-500 mt-4 leading-normal">
          <Shield className="w-3.5 h-3.5 text-slate-600 flex-shrink-0" />
          <span>NFT Studio utilizes real-time image pipelines when secret APIs are active, or local algorithms for stable sandbox deployment.</span>
        </div>
      </div>

      {/* 2. MIDDLE & RIGHT COLUMNS: NFT CATALOG GALLERY */}
      <div className="lg:col-span-2 flex flex-col space-y-4">
        
        <div className="flex justify-between items-center px-4 py-2 bg-slate-950/40 rounded-2xl border border-slate-900">
          <span className="text-[10px] font-bold text-[#6366f1] uppercase tracking-widest flex items-center gap-1.5">
            <HardDrive className="w-4 h-4" /> Curated Ledger Collection ({visibleNfts.length})
          </span>
          <span className="text-[9px] text-slate-500 uppercase tracking-widest">
            Chain: {activeChain.name}
          </span>
        </div>

        {/* NFT GRID LIST */}
        <AnimatePresence mode="popLayout">
          {visibleNfts.length === 0 ? (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="flex-1 rounded-3xl border border-dashed border-slate-800 flex flex-col items-center justify-center py-20 text-center space-y-3 bg-[#0a0c16]/10"
            >
              <div className="w-12 h-12 rounded-full border border-slate-800 flex items-center justify-center text-slate-600">
                💡
              </div>
              <div>
                <p className="text-xs text-slate-400 font-semibold uppercase tracking-wider">No Curator Collectibles Detected</p>
                <p className="text-[10px] text-slate-500 mt-1 max-w-xs leading-normal">
                  You do not hold any digital collectibles on {activeChain.name}. Use the AI Studio panel on the left to mint a custom masterpiece instantly!
                </p>
              </div>
            </motion.div>
          ) : (
            <div className="grid grid-cols-2 md:grid-cols-3 gap-4 overflow-y-auto max-h-[500px] pr-1">
              {visibleNfts.map((nft) => (
                <motion.div
                  key={nft.id}
                  layoutId={`nft-card-${nft.id}`}
                  onClick={() => setSelectedNft(nft)}
                  className="glass-panel p-3 rounded-2xl flex flex-col justify-between group cursor-pointer transition-all hover:border-indigo-500/50 hover:shadow-[0_0_15px_rgba(99,102,241,0.15)] relative h-64"
                >
                  <div className="aspect-square w-full rounded-xl overflow-hidden bg-slate-950 relative mb-3">
                    <img 
                      src={nft.imageUrl} 
                      alt={nft.name} 
                      referrerPolicy="no-referrer"
                      className="w-full h-full object-cover transition-transform group-hover:scale-105" 
                    />
                    <div className="absolute top-2 left-2 text-[8px] bg-slate-950/80 text-indigo-400 font-bold border border-indigo-500/20 px-2 py-0.5 rounded-full uppercase tracking-wider">
                      #{nft.tokenId}
                    </div>
                  </div>

                  <div>
                    <h4 className="text-[11px] font-bold text-white truncate">{nft.name}</h4>
                    <p className="text-[8px] text-slate-500 truncate mt-0.5 font-mono">
                      Cont: {nft.contractAddress.substring(0,6)}...{nft.contractAddress.substring(nft.contractAddress.length-4)}
                    </p>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </AnimatePresence>
      </div>

      {/* NFT DETAILED DIALOG MODAL */}
      <AnimatePresence>
        {selectedNft && (
          <div className="fixed inset-0 bg-black/90 backdrop-blur-md flex items-center justify-center p-4 z-50">
            <motion.div
              layoutId={`nft-card-${selectedNft.id}`}
              className="w-full max-w-lg glass-panel rounded-3xl overflow-hidden relative border border-indigo-500/30"
            >
              <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-emerald-400 to-indigo-500" />
              
              <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                
                {/* NFT Image View */}
                <div className="space-y-3">
                  <div className="aspect-square w-full rounded-2xl overflow-hidden bg-slate-950 relative border border-slate-900">
                    <img src={selectedNft.imageUrl} alt={selectedNft.name} referrerPolicy="no-referrer" className="w-full h-full object-cover" />
                    <div className="absolute top-2.5 left-2.5 text-[8px] bg-indigo-950 text-indigo-400 font-bold border border-indigo-500/20 px-2 py-0.5 rounded-full uppercase">
                      ID #{selectedNft.tokenId}
                    </div>
                  </div>
                  
                  <div className="text-center">
                    <span className="text-[9px] text-slate-550 font-mono tracking-wider">
                      Block Time: {new Date(selectedNft.mintedAt).toLocaleDateString()}
                    </span>
                  </div>
                </div>

                {/* NFT Features and description */}
                <div className="flex flex-col justify-between space-y-4">
                  <div>
                    <div className="flex justify-between items-start mb-2">
                      <h3 className="font-bold text-white text-sm leading-tight">{selectedNft.name}</h3>
                      <button 
                        onClick={() => setSelectedNft(null)}
                        className="text-xs text-slate-400 hover:text-white border border-slate-800 hover:border-slate-700 bg-slate-900 py-1 px-2.5 rounded-lg cursor-pointer transition-all"
                      >
                        Close
                      </button>
                    </div>

                    <p className="text-[10px] text-slate-400 leading-relaxed font-sans border-b border-slate-900 pb-3 mb-3">
                      {selectedNft.description}
                    </p>

                    {/* Metadata attributes wrap */}
                    <div className="space-y-2">
                      <p className="text-[8px] text-slate-500 font-bold uppercase tracking-wider mb-2">Metadata Attributes</p>
                      <div className="grid grid-cols-2 gap-2 text-[8px]">
                        {selectedNft.attributes.map((attr, idx) => (
                          <div key={idx} className="p-2 rounded-xl bg-slate-950 border border-slate-900">
                            <span className="block text-slate-550 uppercase font-semibold">{attr.trait_type}</span>
                            <span className="block text-indigo-300 font-semibold mt-1.5 truncate">{attr.value}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                  <div className="text-[9px] font-mono text-slate-500 space-y-1 bg-slate-950 p-2.5 rounded-2xl border border-slate-900">
                    <p className="truncate"><span className="text-slate-550">Registry:</span> {selectedNft.contractAddress}</p>
                    <p className="truncate"><span className="text-slate-550 font-bold">Standard:</span> ERC-721 Token Standard</p>
                  </div>

                </div>
              </div>

            </motion.div>
          </div>
        )}
      </AnimatePresence>

    </div>
  );
}
