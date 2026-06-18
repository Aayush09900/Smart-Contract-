import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI } from "@google/genai";
import dns from "dns";

// Resolve DNS issues in some sandboxed environments if needed
dns.setDefaultResultOrder && dns.setDefaultResultOrder("ipv4first");

const app = express();
app.use(express.json());

const PORT = 3000;

// Lazy initialization of Gemini client
let aiClient: GoogleGenAI | null = null;
const key = process.env.GEMINI_API_KEY;

function getGeminiClient(): GoogleGenAI | null {
  if (!key || key === "MY_GEMINI_API_KEY" || key === "") {
    console.warn("GEMINI_API_KEY environment variable is not supplied or is empty. Gemini features will run in high-quality local fallback mode.");
    return null;
  }
  if (!aiClient) {
    try {
      aiClient = new GoogleGenAI({
        apiKey: key,
        httpOptions: {
          headers: {
            'User-Agent': 'aistudio-build',
          }
        }
      });
    } catch (err) {
      console.error("Failed to initialize GoogleGenAI client:", err);
      return null;
    }
  }
  return aiClient;
}

// 1. CHAT ADVISOR ENDPOINT
app.post("/api/ai/chat", async (req, res) => {
  const { messages, portfolio } = req.body;
  if (!messages || !Array.isArray(messages)) {
    return res.status(400).json({ error: "Messages array is required." });
  }

  const ai = getGeminiClient();
  const portfolioText = JSON.stringify(portfolio || {});

  const systemPrompt = `You are Aayu AI, an ultra-advanced decentralized Web3 portfolio advisor operating inside Aayu Wallet.
Aayu Wallet is a futuristic "metaverse" next-gen non-custodial wallet supporting multi-chain asset simulation across Ethereum, Polygon, Solana, Avalanche, and Binance Smart Chain (BSC), complete with seamless bridge transfers and dynamic NFT minting.

The user's current portfolio state is:
${portfolioText}

Tone: Futuristic, analytical, highly knowledgeable about crypto, decentralized finance (DeFi), NFT collections, and gas dynamics. Speak in a cooperative, cool, expert tech advisor voice.
Instructions:
- Keep answers relatively concise and highly actionable for someone executing or simulating cross-chain activities.
- Provide real advice about gas prices, cross-chain bridge paths (e.g., Ethereum gas makes high frequency swaps expensive, Polygon or Arbitrum is better for micro-swaps, Solana is great for high speed).
- When asked about bridging, evaluate the optimal swap path based on current simulated values.
- Never mention internal codes, absolute paths, or self-sabotaging meta terms.
- If the Gemini API key is active, speak naturally. If we are running in general mode, simulate standard expert advice.`;

  if (!ai) {
    // Elegant local fallback mock advisor response
    const lastUserMsg = messages[messages.length - 1]?.content || "Hello";
    let reply = "";
    if (lastUserMsg.toLowerCase().includes("gas") || lastUserMsg.toLowerCase().includes("optimize")) {
      reply = "Aayu Vault telemetry indicates standard congestion on Ethereum Mainnet (~32 Gwei). If you are looking to optimize gas costs, bridging to Polygon or BSC via Aayu's integrated cross-chain bridge is highly recommended. Your transaction overhead will decrease by ~95%.";
    } else if (lastUserMsg.toLowerCase().includes("bridge") || lastUserMsg.toLowerCase().includes("cross-chain")) {
      reply = "Cross-chain telemetry is online. Current paths from Ethereum to Solana/Polygon are optimal. In our Metaverse bridging protocol, assets are locked in our secure Aayu Vault smart contract (simulated) on Ethereum and re-minted in under 45 seconds on the target blockscape with minimal gas fees (~$0.02). Would you like me to map out a transaction itinerary?";
    } else if (lastUserMsg.toLowerCase().includes("portfolio") || lastUserMsg.toLowerCase().includes("asset") || lastUserMsg.toLowerCase().includes("balance")) {
      reply = "Analyzing your Aayu Wallet ledger... You currently hold assets dispersed across multiple active chains. Diversification into Solana or Avalanche assets looks promising due to recent ecosystem surges. I suggest executing a test swap inside the wallet to balance your exposure.";
    } else if (lastUserMsg.toLowerCase().includes("nft") || lastUserMsg.toLowerCase().includes("mint")) {
      reply = "Greetings collector! The Aayu NFT holographic grid is fully operational. You can prompt my creative matrix in the NFT Studio tab to mint a direct metaverse digital asset. I will compose standard metadata for you and render custom imagery.";
    } else {
      reply = "Aayu AI ledger advisor online. I am scanning Ethereum, Polygon, Avalanche, and Solana for transaction activity. I can assist you with gas optimizations, cross-chain routing models, smart contract audits, or custom NFT metadata creation. What telemetry can I prepare?";
    }
    return res.json({ response: reply, isFallback: true });
  }

  try {
    // Format messages for gemini-3.5-flash
    // We will pass the full history inside the contents structure
    const contents = messages.map((m: any) => ({
      role: m.role === "user" ? "user" : "model",
      parts: [{ text: m.content }]
    }));

    // Inject system directive in config
    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: contents,
      config: {
        systemInstruction: systemPrompt,
        temperature: 0.8,
      }
    });

    res.json({ response: response.text || "I was unable to synthesize a response. Let me try compiling again." });
  } catch (error: any) {
    console.error("Gemini Chat Error:", error);
    res.status(500).json({ error: "AI reasoning failed: " + error.message });
  }
});

// 2. NFT AI IMAGE GENERATION ENDPOINT
app.post("/api/ai/generate-nft", async (req, res) => {
  const { prompt, network = "ethereum" } = req.body;
  
  if (!prompt) {
    return res.status(400).json({ error: "Prompt is required." });
  }

  const ai = getGeminiClient();

  if (!ai) {
    console.log("No Gemini API key available. Generating elegant procedural placeholder.");
    return res.json({ 
      isFallback: true,
      imageUrl: null, // Will let client generate custom canvas procedurally based on their prompt
      description: `A unique metadata artifact generated procedurally under the moniker "${prompt}" on ${network.toUpperCase()}.`
    });
  }

  try {
    // First, let's generate a highly descriptive text metadata background using gemini-3.5-flash
    const descriptionResponse = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: `Generate a short futuristic, metaverse-flavored description for a digital wallet NFT artwork based on this prompt: "${prompt}". Do not exceed 2-3 sentences.`,
    });
    const nftDescription = descriptionResponse.text?.trim() || `An exclusive metaverse collectible generated inside the Aayu Wallet studio based on prompt: ${prompt}`;

    console.log("Generating visual media for NFT prompt:", prompt);
    // Use gemini-2.5-flash-image to generate the image
    const imageResponse = await ai.models.generateContent({
      model: 'gemini-2.5-flash-image',
      contents: {
        parts: [
          {
            text: `A glowing cyberpunk digital collectible asset, futuristic holographic display card, futuristic crypto token art, highly detailed neon design, metaverse aesthetic, matching: ${prompt}`,
          },
        ],
      },
      config: {
        imageConfig: {
          aspectRatio: "1:1",
        },
      },
    });

    let base64Image = null;
    if (imageResponse.candidates?.[0]?.content?.parts) {
      for (const part of imageResponse.candidates[0].content.parts) {
        if (part.inlineData) {
          base64Image = part.inlineData.data;
          break;
        }
      }
    }

    if (base64Image) {
      return res.json({
        imageUrl: `data:image/png;base64,${base64Image}`,
        description: nftDescription,
        isFallback: false
      });
    } else {
      throw new Error("No image data returned from Gemini flash image.");
    }

  } catch (error: any) {
    console.error("NFT Image Generation Error:", error);
    // Fallback to text metadata with client-side procedural visualizer
    return res.json({
      error: error.message,
      isFallback: true,
      imageUrl: null,
      description: `Procedural ledger copy of art minted for "${prompt}". AI background compiling complete.`
    });
  }
});

// START EXPRESS/VITE WORKFLOW
async function startServer() {
  if (process.env.NODE_ENV !== "production") {
    console.log("Integrating Vite Dev Server Middleware...");
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    console.log("Serving production build from dist...");
    const distPath = path.join(process.cwd(), 'dist');
    app.use(express.static(distPath));
    app.get('*', (req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`[Aayu Server] Operational at http://0.0.0.0:${PORT} under NODE_ENV=${process.env.NODE_ENV}`);
  });
}

startServer();
