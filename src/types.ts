export type ChainId = 'ethereum' | 'polygon' | 'solana' | 'avalanche' | 'bsc';

export interface Chain {
  id: ChainId;
  name: string;
  symbol: string;
  logo: string;
  rpcUrl: string;
  blockExplorer: string;
  gasPriceGwei: number;
  health: 'optimal' | 'congested' | 'degraded';
}

export interface WalletAccount {
  name: string;
  address: string;
  avatarSeed: string;
}

export interface TokenAsset {
  id: string;
  name: string;
  symbol: string;
  decimals: number;
  chainId: ChainId;
  balance: number;
  usdPrice: number;
  logoUrl: string;
}

export type TransactionType = 'send' | 'receive' | 'bridge' | 'mint' | 'swap';

export interface Transaction {
  id: string;
  type: TransactionType;
  hash: string;
  from: string;
  to: string;
  amount: string;
  symbol: string;
  chainId: ChainId;
  targetChainId?: ChainId; // for bridges
  timestamp: number;
  status: 'pending' | 'success' | 'failed';
  gasFeeUsd: number;
  notes?: string;
}

export interface NFTAsset {
  id: string;
  tokenId: string;
  contractAddress: string;
  name: string;
  description: string;
  imageUrl: string;
  creator: string;
  chainId: ChainId;
  attributes: { trait_type: string; value: string | number }[];
  mintedAt: number;
}

export interface WalletVault {
  seedPhrase: string;
  accounts: WalletAccount[];
  activeAccountIndex: number;
}
