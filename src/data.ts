import { Chain, TokenAsset, NFTAsset } from './types';

export const SUPPORTED_CHAINS: Chain[] = [
  {
    id: 'ethereum',
    name: 'Ethereum Mainnet',
    symbol: 'ETH',
    logo: '🌐',
    rpcUrl: 'https://rpc.ankr.com/eth',
    blockExplorer: 'https://etherscan.io',
    gasPriceGwei: 28,
    health: 'optimal',
  },
  {
    id: 'polygon',
    name: 'Polygon PoS',
    symbol: 'POL',
    logo: '💜',
    rpcUrl: 'https://polygon-rpc.com',
    blockExplorer: 'https://polygonscan.com',
    gasPriceGwei: 85,
    health: 'optimal',
  },
  {
    id: 'solana',
    name: 'Solana Beta',
    symbol: 'SOL',
    logo: '⚡',
    rpcUrl: 'https://api.mainnet-beta.solana.com',
    blockExplorer: 'https://solscan.io',
    gasPriceGwei: 0.00005,
    health: 'optimal',
  },
  {
    id: 'avalanche',
    name: 'Avalanche C-Chain',
    symbol: 'AVAX',
    logo: '🔺',
    rpcUrl: 'https://api.avax.network/ext/bc/C/rpc',
    blockExplorer: 'https://snowtrace.io',
    gasPriceGwei: 25,
    health: 'optimal',
  },
  {
    id: 'bsc',
    name: 'BSC Smart Chain',
    symbol: 'BNB',
    logo: '🟡',
    rpcUrl: 'https://bsc-dataseed.binance.org',
    blockExplorer: 'https://bscscan.com',
    gasPriceGwei: 3.5,
    health: 'congested',
  }
];

export const INITIAL_TOKENS_DATA = (accountAddress: string): TokenAsset[] => {
  // We can shorten or format the account address inside, but we map keys perfectly
  return [
    // Ethereum Assets
    {
      id: 'eth-native',
      name: 'Ethereum',
      symbol: 'ETH',
      decimals: 18,
      chainId: 'ethereum',
      balance: 1.485,
      usdPrice: 3450.25,
      logoUrl: 'https://cryptologos.cc/logos/ethereum-eth-logo.png'
    },
    {
      id: 'eth-usdt',
      name: 'Tether USD',
      symbol: 'USDT',
      decimals: 6,
      chainId: 'ethereum',
      balance: 1250.00,
      usdPrice: 1.00,
      logoUrl: 'https://cryptologos.cc/logos/tether-usdt-logo.png'
    },
    {
      id: 'eth-usdc',
      name: 'USD Coin',
      symbol: 'USDC',
      decimals: 6,
      chainId: 'ethereum',
      balance: 340.50,
      usdPrice: 1.00,
      logoUrl: 'https://cryptologos.cc/logos/usd-coin-usdc-logo.png'
    },
    {
      id: 'eth-link',
      name: 'Chainlink',
      symbol: 'LINK',
      decimals: 18,
      chainId: 'ethereum',
      balance: 45.0,
      usdPrice: 17.80,
      logoUrl: 'https://cryptologos.cc/logos/chainlink-link-logo.png'
    },

    // Polygon Assets
    {
      id: 'poly-native',
      name: 'Polygon',
      symbol: 'POL',
      decimals: 18,
      chainId: 'polygon',
      balance: 2450.0,
      usdPrice: 0.64,
      logoUrl: 'https://cryptologos.cc/logos/polygon-matic-logo.png'
    },
    {
      id: 'poly-weth',
      name: 'Wrapped Ether',
      symbol: 'WETH',
      decimals: 18,
      chainId: 'polygon',
      balance: 0.42,
      usdPrice: 3445.10,
      logoUrl: 'https://cryptologos.cc/logos/ethereum-eth-logo.png'
    },

    // Solana Assets
    {
      id: 'sol-native',
      name: 'Solana',
      symbol: 'SOL',
      decimals: 9,
      chainId: 'solana',
      balance: 18.52,
      usdPrice: 182.40,
      logoUrl: 'https://cryptologos.cc/logos/solana-sol-logo.png'
    },
    {
      id: 'sol-usdc',
      name: 'USD Coin (Solana)',
      symbol: 'USDC',
      decimals: 6,
      chainId: 'solana',
      balance: 500.0,
      usdPrice: 1.00,
      logoUrl: 'https://cryptologos.cc/logos/usd-coin-usdc-logo.png'
    },

    // Avalanche Assets
    {
      id: 'avax-native',
      name: 'Avalanche',
      symbol: 'AVAX',
      decimals: 18,
      chainId: 'avalanche',
      balance: 34.8,
      usdPrice: 36.15,
      logoUrl: 'https://cryptologos.cc/logos/avalanche-avax-logo.png'
    },

    // BSC Assets
    {
      id: 'bsc-native',
      name: 'BNB',
      symbol: 'BNB',
      decimals: 18,
      chainId: 'bsc',
      balance: 5.62,
      usdPrice: 580.45,
      logoUrl: 'https://cryptologos.cc/logos/binance-coin-bnb-logo.png'
    }
  ];
};

export const INITIAL_NFTS_DATA: NFTAsset[] = [
  {
    id: 'nft-001',
    tokenId: '4829',
    contractAddress: '0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d',
    name: 'Aayu Holo-Samurai #4829',
    description: 'A legendary holographic warrior residing in the Aayu metaverse stream, wielding dynamic neon-katana metadata.',
    imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=400',
    creator: '0x88fA...91d2',
    chainId: 'ethereum',
    attributes: [
      { trait_type: 'Mask', value: 'Vapor Wave Kabuto' },
      { trait_type: 'Weapon', value: 'Plasma Katana' },
      { trait_type: 'Reality Status', value: 'Augmented' },
      { trait_type: 'Rarity Index', value: 'Ultra Rare' }
    ],
    mintedAt: Date.now() - 34 * 24 * 3600 * 1000
  },
  {
    id: 'nft-002',
    tokenId: '915',
    contractAddress: '0x3235bca0ed11d13d7647a8afec2e118a923a1a18',
    name: 'Neo Sakura Cyberpod #915',
    description: 'An eco-cybernetic living quarter from the Neo Tokyo district. Generates passive Solana simulation particles.',
    imageUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&q=80&w=400',
    creator: '0x7ca...ef01',
    chainId: 'polygon',
    attributes: [
      { trait_type: 'Ecosystem', value: 'Cherry Blossom C12' },
      { trait_type: 'Power Core', value: 'Antimatter Node' },
      { trait_type: 'Atmosphere', value: 'Overcast Neon' }
    ],
    mintedAt: Date.now() - 15 * 24 * 3600 * 1000
  },
  {
    id: 'nft-003',
    tokenId: '22',
    contractAddress: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
    name: 'Quantum Warp Visor #22',
    description: 'Wearable augmented optics capable of traversing parallel testnets and observing gas paths in raw UV spectra.',
    imageUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&q=80&w=400',
    creator: '0x942...bce3',
    chainId: 'avalanche',
    attributes: [
      { trait_type: 'Optics', value: 'UV Warp Array' },
      { trait_type: 'Overlay', value: 'Chain Gas Metrics' },
      { trait_type: 'Tier', value: 'Apex wearable' }
    ],
    mintedAt: Date.now() - 2 * 24 * 3600 * 1000
  }
];

export const MOCK_SEED_PHRASE = 'galaxy visual crystal solar energy quantum shield tunnel pattern matrix space wave';
