/**
 * Wealth Management Tools Plugin
 * 
 * This plugin provides tools for wealth management operations including:
 * - Account opening
 * - Stock trading
 * - Cryptocurrency trading
 * - Foreign exchange trading
 */

import { z } from 'zod';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { createUIResource } from '@mcp-ui/server';
import type { MCPUIToolPlugin } from '../tool-plugin.js';
import { logger } from '../../utils/logger.js';

const emptyInputSchema = {};

export const wealthMgmtToolsPlugin: MCPUIToolPlugin = {
  name: 'wealth-mgr-tools',
  version: '1.0.0',
  description: 'Wealth management tools for account opening and trading',
  author: 'Wealth Management Team',
  
  async register(server: McpServer): Promise<void> {
    // ============================================
    // 1. ACCOUNT OPENING TOOLS
    // ============================================
    
    // Tool 1: Show Account Opening Form
    server.registerTool(
      'showAccountOpeningForm',
      {
        title: 'Show Account Opening Form',
        description: 'Displays a simple account opening form when a client wants to open a new account',
        inputSchema: emptyInputSchema,
      },
      async (params: unknown) => {
        z.object(emptyInputSchema).parse(params);
        logger.info({ tool: 'showAccountOpeningForm' }, 'Account opening form requested');

        const accountFormHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Open Account</title>
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      padding: 20px;
      min-height: 100vh;
      color: #333;
    }
    
    .container {
      max-width: 500px;
      margin: 0 auto;
      background: white;
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
      overflow: hidden;
    }
    
    .header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 24px;
      text-align: center;
    }
    
    .header h1 {
      font-size: 24px;
      font-weight: 600;
      margin-bottom: 4px;
    }
    
    .header p {
      font-size: 13px;
      opacity: 0.9;
    }
    
    .form-container {
      padding: 30px;
    }
    
    .form-group {
      margin-bottom: 20px;
    }
    
    label {
      display: block;
      font-weight: 600;
      margin-bottom: 8px;
      color: #333;
      font-size: 14px;
    }
    
    label .required {
      color: #e74c3c;
      margin-left: 4px;
    }
    
    input[type="text"],
    input[type="email"],
    select {
      width: 100%;
      padding: 12px 16px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      font-size: 14px;
      font-family: inherit;
      transition: all 0.2s;
      background: #fafafa;
    }
    
    input:focus,
    select:focus {
      outline: none;
      border-color: #667eea;
      background: white;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }
    
    .submit-button {
      width: 100%;
      padding: 14px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: transform 0.2s, box-shadow 0.2s;
      margin-top: 10px;
    }
    
    .submit-button:hover:not(:disabled) {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
    }
    
    .submit-button:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }
    
    .status {
      margin-top: 16px;
      padding: 12px;
      border-radius: 8px;
      display: none;
      font-weight: 500;
      font-size: 14px;
    }
    
    .status.success {
      background: #d4edda;
      color: #155724;
      border: 1px solid #c3e6cb;
      display: block;
    }
    
    .status.error {
      background: #f8d7da;
      color: #721c24;
      border: 1px solid #f5c6cb;
      display: block;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📋 Open New Account</h1>
      <p>Get started with your wealth management journey</p>
    </div>
    
    <div class="form-container">
      <form id="accountForm">
        <div class="form-group">
          <label>Full Name <span class="required">*</span></label>
          <input type="text" id="fullName" name="fullName" required />
        </div>
        
        <div class="form-group">
          <label>Email Address <span class="required">*</span></label>
          <input type="email" id="email" name="email" required />
        </div>
        
        <div class="form-group">
          <label>Account Type <span class="required">*</span></label>
          <select id="accountType" name="accountType" required>
            <option value="">Select account type</option>
            <option value="individual">Individual Investment Account</option>
            <option value="joint">Joint Account</option>
            <option value="ira">IRA (Individual Retirement Account)</option>
            <option value="trust">Trust Account</option>
          </select>
        </div>
        
        <button type="submit" class="submit-button" id="submitBtn">
          Open Account
        </button>
        
        <div id="status" class="status"></div>
      </form>
    </div>
  </div>
  
  <script>
    const form = document.getElementById('accountForm');
    const status = document.getElementById('status');
    const submitBtn = document.getElementById('submitBtn');
    
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      status.style.display = 'none';
      
      const formData = {
        fullName: document.getElementById('fullName').value,
        email: document.getElementById('email').value,
        accountType: document.getElementById('accountType').value,
        submittedAt: new Date().toISOString(),
      };
      
      submitBtn.disabled = true;
      submitBtn.textContent = 'Processing...';
      
      const messageId = 'account-open-' + Date.now();
      window.mcpUI.callTool('processAccountOpening', formData, messageId);
      
      window.addEventListener('message', (event) => {
        if (event.data.type === 'ui-message-response' && 
            event.data.messageId === messageId) {
          submitBtn.disabled = false;
          submitBtn.textContent = 'Open Account';
          
          if (event.data.payload && !event.data.payload.error) {
            status.className = 'status success';
            status.textContent = '✅ Account opening request submitted successfully! You will receive a confirmation email shortly.';
            form.reset();
          } else {
            status.className = 'status error';
            status.textContent = '❌ Error: ' + (event.data.payload?.error || 'Failed to submit account opening request');
            status.style.display = 'block';
          }
        }
      });
    });
    
    if (window.mcpUI && window.mcpUI.reportSize) {
      setTimeout(() => window.mcpUI.reportSize(), 100);
    }
  </script>
</body>
</html>
        `;

        const uiResource = createUIResource({
          uri: 'ui://account-opening/1',
          content: { type: 'rawHtml', htmlString: accountFormHtml },
          encoding: 'blob',
        });

        return { content: [uiResource] };
      }
    );

    // Tool 2: Process Account Opening
    const accountOpeningInputSchema = {
      fullName: z.string().min(1).describe('Full name of the client'),
      email: z.string().email().describe('Email address'),
      accountType: z.enum(['individual', 'joint', 'ira', 'trust']).describe('Type of account to open'),
      submittedAt: z.string().describe('ISO timestamp of submission'),
    };

    server.registerTool(
      'processAccountOpening',
      {
        title: 'Process Account Opening',
        description: 'Processes account opening form submissions',
        inputSchema: accountOpeningInputSchema,
      },
      async (params: unknown) => {
        const parsed = z.object(accountOpeningInputSchema).parse(params);

        logger.info(
          {
            tool: 'processAccountOpening',
            email: parsed.email,
            accountType: parsed.accountType,
          },
          'Processing account opening request'
        );

        await new Promise((resolve) => setTimeout(resolve, 1500));

        const accountId = 'ACC-' + Date.now();
        const responsePayload = {
          status: 'submitted',
          accountId,
          accountType: parsed.accountType,
          message: 'Your account opening request has been received and is being processed.',
          nextSteps: [
            'You will receive a confirmation email within 24 hours',
            'Our team will review your application',
            'You may be contacted for additional documentation if needed',
          ],
        };

        logger.info(
          {
            tool: 'processAccountOpening',
            accountId,
            status: 'success',
          },
          'Account opening request processed successfully'
        );

        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(responsePayload),
            },
          ],
        };
      }
    );

    // ============================================
    // 2. STOCK TRADING TOOLS
    // ============================================
    
    // Tool 3: Show Stock Trading Card
    server.registerTool(
      'showStockTradingCard',
      {
        title: 'Show Stock Trading Card',
        description: 'Shows a stock trading interface with current quote when a client wants to trade stocks',
        inputSchema: {
          symbol: z.string().optional().describe('Stock symbol (e.g., AAPL, MSFT). If not provided, defaults to AAPL'),
          companyName: z.string().optional().describe('Company name. If not provided, will be inferred from symbol'),
        },
      },
      async (params: unknown) => {
        const parsed = z.object({
          symbol: z.string().optional(),
          companyName: z.string().optional(),
        }).parse(params);
        
        const symbol = parsed.symbol || 'AAPL';
        const companyName = parsed.companyName || 'Apple Inc.';
        
        // Generate mock bid/ask prices
        const basePrice = 175.00 + (Math.random() * 10 - 5);
        const bid = (basePrice - 0.02).toFixed(2);
        const ask = (basePrice + 0.02).toFixed(2);
        
        logger.info({ tool: 'showStockTradingCard', symbol, bid, ask }, 'Stock trading card requested');

        const stockCardHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Trade Stock - ${symbol}</title>
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      background: #f5f5f7;
      padding: 20px;
      color: #1d1d1f;
    }
    
    .card {
      max-width: 450px;
      margin: 0 auto;
      background: white;
      border-radius: 16px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
      overflow: hidden;
    }
    
    .header {
      background: linear-gradient(135deg, #007AFF 0%, #0051D5 100%);
      color: white;
      padding: 24px;
    }
    
    .header h1 {
      font-size: 28px;
      font-weight: 700;
      margin-bottom: 4px;
    }
    
    .header .company {
      font-size: 14px;
      opacity: 0.9;
    }
    
    .quote-section {
      padding: 24px;
      background: #fafafa;
      border-bottom: 1px solid #e0e0e0;
    }
    
    .quote-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 12px;
    }
    
    .quote-row:last-child {
      margin-bottom: 0;
    }
    
    .quote-label {
      font-size: 13px;
      color: #666;
      font-weight: 500;
    }
    
    .quote-value {
      font-size: 18px;
      font-weight: 600;
      color: #1d1d1f;
    }
    
    .form-section {
      padding: 24px;
    }
    
    .form-group {
      margin-bottom: 20px;
    }
    
    label {
      display: block;
      font-weight: 600;
      margin-bottom: 8px;
      color: #333;
      font-size: 14px;
    }
    
    input[type="number"] {
      width: 100%;
      padding: 12px 16px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      font-size: 16px;
      font-family: inherit;
      transition: all 0.2s;
    }
    
    input:focus {
      outline: none;
      border-color: #007AFF;
      box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
    }
    
    .trade-type {
      display: flex;
      gap: 12px;
      margin-bottom: 20px;
    }
    
    .trade-btn {
      flex: 1;
      padding: 12px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      background: white;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }
    
    .trade-btn.active {
      background: #007AFF;
      color: white;
      border-color: #007AFF;
    }
    
    .action-buttons {
      display: flex;
      gap: 12px;
    }
    
    .btn {
      flex: 1;
      padding: 14px;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }
    
    .btn-confirm {
      background: #34c759;
      color: white;
    }
    
    .btn-confirm:hover:not(:disabled) {
      background: #30b955;
      transform: translateY(-1px);
    }
    
    .btn-cancel {
      background: #f5f5f7;
      color: #1d1d1f;
    }
    
    .btn-cancel:hover:not(:disabled) {
      background: #e5e5e7;
    }
    
    .btn:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    
    .status {
      margin-top: 16px;
      padding: 12px;
      border-radius: 8px;
      display: none;
      font-size: 14px;
      font-weight: 500;
    }
    
    .status.success {
      background: #d4edda;
      color: #155724;
      display: block;
    }
    
    .status.error {
      background: #f8d7da;
      color: #721c24;
      display: block;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="header">
      <h1>${symbol}</h1>
      <div class="company">${companyName}</div>
    </div>
    
    <div class="quote-section">
      <div class="quote-row">
        <span class="quote-label">Bid</span>
        <span class="quote-value">$${bid}</span>
      </div>
      <div class="quote-row">
        <span class="quote-label">Ask</span>
        <span class="quote-value">$${ask}</span>
      </div>
    </div>
    
    <div class="form-section">
      <div class="form-group">
        <label>Trade Type</label>
        <div class="trade-type">
          <button type="button" class="trade-btn active" id="buyBtn" data-type="buy">Buy</button>
          <button type="button" class="trade-btn" id="sellBtn" data-type="sell">Sell</button>
        </div>
      </div>
      
      <div class="form-group">
        <label>Quantity (Shares)</label>
        <input type="number" id="quantity" min="1" step="1" value="1" required />
      </div>
      
      <div class="action-buttons">
        <button class="btn btn-confirm" id="confirmBtn">Confirm</button>
        <button class="btn btn-cancel" id="cancelBtn">Cancel</button>
      </div>
      
      <div id="status" class="status"></div>
    </div>
  </div>
  
  <script>
    const buyBtn = document.getElementById('buyBtn');
    const sellBtn = document.getElementById('sellBtn');
    const quantityInput = document.getElementById('quantity');
    const confirmBtn = document.getElementById('confirmBtn');
    const cancelBtn = document.getElementById('cancelBtn');
    const status = document.getElementById('status');
    
    let tradeType = 'buy';
    
    buyBtn.addEventListener('click', () => {
      tradeType = 'buy';
      buyBtn.classList.add('active');
      sellBtn.classList.remove('active');
    });
    
    sellBtn.addEventListener('click', () => {
      tradeType = 'sell';
      sellBtn.classList.add('active');
      buyBtn.classList.remove('active');
    });
    
    confirmBtn.addEventListener('click', async () => {
      const quantity = parseInt(quantityInput.value);
      if (!quantity || quantity < 1) {
        status.className = 'status error';
        status.textContent = 'Please enter a valid quantity';
        status.style.display = 'block';
        return;
      }
      
      confirmBtn.disabled = true;
      cancelBtn.disabled = true;
      confirmBtn.textContent = 'Processing...';
      
      const tradeData = {
        symbol: '${symbol}',
        companyName: '${companyName}',
        tradeType,
        quantity,
        bid: ${bid},
        ask: ${ask},
        submittedAt: new Date().toISOString(),
      };
      
      const messageId = 'stock-trade-' + Date.now();
      window.mcpUI.callTool('processStockTrade', tradeData, messageId);
      
      window.addEventListener('message', (event) => {
        if (event.data.type === 'ui-message-response' && 
            event.data.messageId === messageId) {
          confirmBtn.disabled = false;
          cancelBtn.disabled = false;
          confirmBtn.textContent = 'Confirm';
          
          if (event.data.payload && !event.data.payload.error) {
            status.className = 'status success';
            status.textContent = '✅ Trade executed successfully!';
            setTimeout(() => {
              status.style.display = 'none';
            }, 3000);
          } else {
            status.className = 'status error';
            status.textContent = '❌ Error: ' + (event.data.payload?.error || 'Trade execution failed');
            status.style.display = 'block';
          }
        }
      });
    });
    
    cancelBtn.addEventListener('click', () => {
      if (window.mcpUI && window.mcpUI.close) {
        window.mcpUI.close();
      }
    });
    
    if (window.mcpUI && window.mcpUI.reportSize) {
      setTimeout(() => window.mcpUI.reportSize(), 100);
    }
  </script>
</body>
</html>
        `;

        const uiResource = createUIResource({
          uri: `ui://stock-trading/${symbol}`,
          content: { type: 'rawHtml', htmlString: stockCardHtml },
          encoding: 'blob',
        });

        return { content: [uiResource] };
      }
    );

    // Tool 4: Process Stock Trade
    const stockTradeInputSchema = {
      symbol: z.string().describe('Stock symbol'),
      companyName: z.string().describe('Company name'),
      tradeType: z.enum(['buy', 'sell']).describe('Type of trade (buy or sell)'),
      quantity: z.number().int().positive().describe('Number of shares'),
      bid: z.number().describe('Bid price at time of trade'),
      ask: z.number().describe('Ask price at time of trade'),
      submittedAt: z.string().describe('ISO timestamp of submission'),
    };

    server.registerTool(
      'processStockTrade',
      {
        title: 'Process Stock Trade',
        description: 'Executes stock trade orders',
        inputSchema: stockTradeInputSchema,
      },
      async (params: unknown) => {
        const parsed = z.object(stockTradeInputSchema).parse(params);

        logger.info(
          {
            tool: 'processStockTrade',
            symbol: parsed.symbol,
            tradeType: parsed.tradeType,
            quantity: parsed.quantity,
          },
          'Processing stock trade'
        );

        await new Promise((resolve) => setTimeout(resolve, 1500));

        const executionPrice = parsed.tradeType === 'buy' ? parsed.ask : parsed.bid;
        const totalValue = executionPrice * parsed.quantity;
        const transactionId = 'STK-' + Date.now();

        const responsePayload = {
          status: 'executed',
          transactionId,
          symbol: parsed.symbol,
          tradeType: parsed.tradeType,
          quantity: parsed.quantity,
          executionPrice: executionPrice.toFixed(2),
          totalValue: totalValue.toFixed(2),
          message: `${parsed.tradeType === 'buy' ? 'Purchase' : 'Sale'} of ${parsed.quantity} shares of ${parsed.symbol} executed successfully.`,
        };

        logger.info(
          {
            tool: 'processStockTrade',
            transactionId,
            status: 'success',
          },
          'Stock trade executed successfully'
        );

        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(responsePayload),
            },
          ],
        };
      }
    );

    // ============================================
    // 3. CRYPTO TRADING TOOLS
    // ============================================
    
    // Tool 5: Show Crypto Trading Card
    server.registerTool(
      'showCryptoTradingCard',
      {
        title: 'Show Crypto Trading Card',
        description: 'Shows a cryptocurrency trading interface with current quote when a client wants to trade crypto',
        inputSchema: {
          symbol: z.string().optional().describe('Crypto symbol (e.g., BTC, ETH). If not provided, defaults to BTC'),
          name: z.string().optional().describe('Cryptocurrency name. If not provided, will be inferred from symbol'),
        },
      },
      async (params: unknown) => {
        const parsed = z.object({
          symbol: z.string().optional(),
          name: z.string().optional(),
        }).parse(params);
        
        const symbol = parsed.symbol || 'BTC';
        const name = parsed.name || 'Bitcoin';
        
        // Generate mock bid/ask prices
        const basePrice = symbol === 'BTC' ? 42150 : symbol === 'ETH' ? 2450 : 1000;
        const bid = (basePrice + (Math.random() * 100 - 50)).toFixed(2);
        const ask = (parseFloat(bid) + 5).toFixed(2);
        
        logger.info({ tool: 'showCryptoTradingCard', symbol, bid, ask }, 'Crypto trading card requested');

        const cryptoCardHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Trade Crypto - ${symbol}</title>
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      background: #f5f5f7;
      padding: 20px;
      color: #1d1d1f;
    }
    
    .card {
      max-width: 450px;
      margin: 0 auto;
      background: white;
      border-radius: 16px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
      overflow: hidden;
    }
    
    .header {
      background: linear-gradient(135deg, #f7931a 0%, #ff6b00 100%);
      color: white;
      padding: 24px;
    }
    
    .header h1 {
      font-size: 28px;
      font-weight: 700;
      margin-bottom: 4px;
    }
    
    .header .name {
      font-size: 14px;
      opacity: 0.9;
    }
    
    .quote-section {
      padding: 24px;
      background: #fafafa;
      border-bottom: 1px solid #e0e0e0;
    }
    
    .quote-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 12px;
    }
    
    .quote-row:last-child {
      margin-bottom: 0;
    }
    
    .quote-label {
      font-size: 13px;
      color: #666;
      font-weight: 500;
    }
    
    .quote-value {
      font-size: 18px;
      font-weight: 600;
      color: #1d1d1f;
    }
    
    .form-section {
      padding: 24px;
    }
    
    .form-group {
      margin-bottom: 20px;
    }
    
    label {
      display: block;
      font-weight: 600;
      margin-bottom: 8px;
      color: #333;
      font-size: 14px;
    }
    
    input[type="number"] {
      width: 100%;
      padding: 12px 16px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      font-size: 16px;
      font-family: inherit;
      transition: all 0.2s;
    }
    
    input:focus {
      outline: none;
      border-color: #f7931a;
      box-shadow: 0 0 0 3px rgba(247, 147, 26, 0.1);
    }
    
    .trade-type {
      display: flex;
      gap: 12px;
      margin-bottom: 20px;
    }
    
    .trade-btn {
      flex: 1;
      padding: 12px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      background: white;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }
    
    .trade-btn.active {
      background: #f7931a;
      color: white;
      border-color: #f7931a;
    }
    
    .action-buttons {
      display: flex;
      gap: 12px;
    }
    
    .btn {
      flex: 1;
      padding: 14px;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }
    
    .btn-confirm {
      background: #34c759;
      color: white;
    }
    
    .btn-confirm:hover:not(:disabled) {
      background: #30b955;
      transform: translateY(-1px);
    }
    
    .btn-cancel {
      background: #f5f5f7;
      color: #1d1d1f;
    }
    
    .btn-cancel:hover:not(:disabled) {
      background: #e5e5e7;
    }
    
    .btn:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    
    .status {
      margin-top: 16px;
      padding: 12px;
      border-radius: 8px;
      display: none;
      font-size: 14px;
      font-weight: 500;
    }
    
    .status.success {
      background: #d4edda;
      color: #155724;
      display: block;
    }
    
    .status.error {
      background: #f8d7da;
      color: #721c24;
      display: block;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="header">
      <h1>${symbol}</h1>
      <div class="name">${name}</div>
    </div>
    
    <div class="quote-section">
      <div class="quote-row">
        <span class="quote-label">Bid</span>
        <span class="quote-value">$${bid}</span>
      </div>
      <div class="quote-row">
        <span class="quote-label">Ask</span>
        <span class="quote-value">$${ask}</span>
      </div>
    </div>
    
    <div class="form-section">
      <div class="form-group">
        <label>Trade Type</label>
        <div class="trade-type">
          <button type="button" class="trade-btn active" id="buyBtn" data-type="buy">Buy</button>
          <button type="button" class="trade-btn" id="sellBtn" data-type="sell">Sell</button>
        </div>
      </div>
      
      <div class="form-group">
        <label>Amount (${symbol})</label>
        <input type="number" id="amount" min="0.0001" step="0.0001" value="0.1" required />
      </div>
      
      <div class="action-buttons">
        <button class="btn btn-confirm" id="confirmBtn">Confirm</button>
        <button class="btn btn-cancel" id="cancelBtn">Cancel</button>
      </div>
      
      <div id="status" class="status"></div>
    </div>
  </div>
  
  <script>
    const buyBtn = document.getElementById('buyBtn');
    const sellBtn = document.getElementById('sellBtn');
    const amountInput = document.getElementById('amount');
    const confirmBtn = document.getElementById('confirmBtn');
    const cancelBtn = document.getElementById('cancelBtn');
    const status = document.getElementById('status');
    
    let tradeType = 'buy';
    
    buyBtn.addEventListener('click', () => {
      tradeType = 'buy';
      buyBtn.classList.add('active');
      sellBtn.classList.remove('active');
    });
    
    sellBtn.addEventListener('click', () => {
      tradeType = 'sell';
      sellBtn.classList.add('active');
      buyBtn.classList.remove('active');
    });
    
    confirmBtn.addEventListener('click', async () => {
      const amount = parseFloat(amountInput.value);
      if (!amount || amount <= 0) {
        status.className = 'status error';
        status.textContent = 'Please enter a valid amount';
        status.style.display = 'block';
        return;
      }
      
      confirmBtn.disabled = true;
      cancelBtn.disabled = true;
      confirmBtn.textContent = 'Processing...';
      
      const tradeData = {
        symbol: '${symbol}',
        name: '${name}',
        tradeType,
        amount,
        bid: ${bid},
        ask: ${ask},
        submittedAt: new Date().toISOString(),
      };
      
      const messageId = 'crypto-trade-' + Date.now();
      window.mcpUI.callTool('processCryptoTrade', tradeData, messageId);
      
      window.addEventListener('message', (event) => {
        if (event.data.type === 'ui-message-response' && 
            event.data.messageId === messageId) {
          confirmBtn.disabled = false;
          cancelBtn.disabled = false;
          confirmBtn.textContent = 'Confirm';
          
          if (event.data.payload && !event.data.payload.error) {
            status.className = 'status success';
            status.textContent = '✅ Trade executed successfully!';
            setTimeout(() => {
              status.style.display = 'none';
            }, 3000);
          } else {
            status.className = 'status error';
            status.textContent = '❌ Error: ' + (event.data.payload?.error || 'Trade execution failed');
            status.style.display = 'block';
          }
        }
      });
    });
    
    cancelBtn.addEventListener('click', () => {
      if (window.mcpUI && window.mcpUI.close) {
        window.mcpUI.close();
      }
    });
    
    if (window.mcpUI && window.mcpUI.reportSize) {
      setTimeout(() => window.mcpUI.reportSize(), 100);
    }
  </script>
</body>
</html>
        `;

        const uiResource = createUIResource({
          uri: `ui://crypto-trading/${symbol}`,
          content: { type: 'rawHtml', htmlString: cryptoCardHtml },
          encoding: 'blob',
        });

        return { content: [uiResource] };
      }
    );

    // Tool 6: Process Crypto Trade
    const cryptoTradeInputSchema = {
      symbol: z.string().describe('Cryptocurrency symbol'),
      name: z.string().describe('Cryptocurrency name'),
      tradeType: z.enum(['buy', 'sell']).describe('Type of trade (buy or sell)'),
      amount: z.number().positive().describe('Amount of cryptocurrency'),
      bid: z.number().describe('Bid price at time of trade'),
      ask: z.number().describe('Ask price at time of trade'),
      submittedAt: z.string().describe('ISO timestamp of submission'),
    };

    server.registerTool(
      'processCryptoTrade',
      {
        title: 'Process Crypto Trade',
        description: 'Executes cryptocurrency trade orders',
        inputSchema: cryptoTradeInputSchema,
      },
      async (params: unknown) => {
        const parsed = z.object(cryptoTradeInputSchema).parse(params);

        logger.info(
          {
            tool: 'processCryptoTrade',
            symbol: parsed.symbol,
            tradeType: parsed.tradeType,
            amount: parsed.amount,
          },
          'Processing crypto trade'
        );

        await new Promise((resolve) => setTimeout(resolve, 1500));

        const executionPrice = parsed.tradeType === 'buy' ? parsed.ask : parsed.bid;
        const totalValue = executionPrice * parsed.amount;
        const transactionId = 'CRY-' + Date.now();

        const responsePayload = {
          status: 'executed',
          transactionId,
          symbol: parsed.symbol,
          tradeType: parsed.tradeType,
          amount: parsed.amount.toFixed(8),
          executionPrice: executionPrice.toFixed(2),
          totalValue: totalValue.toFixed(2),
          message: `${parsed.tradeType === 'buy' ? 'Purchase' : 'Sale'} of ${parsed.amount.toFixed(8)} ${parsed.symbol} executed successfully.`,
        };

        logger.info(
          {
            tool: 'processCryptoTrade',
            transactionId,
            status: 'success',
          },
          'Crypto trade executed successfully'
        );

        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(responsePayload),
            },
          ],
        };
      }
    );

    // ============================================
    // 4. FOREX TRADING TOOLS
    // ============================================
    
    // Tool 7: Show Forex Trading Card
    server.registerTool(
      'showForexTradingCard',
      {
        title: 'Show Forex Trading Card',
        description: 'Shows a foreign exchange trading interface with current rates when a client wants to trade currencies',
        inputSchema: {
          pair: z.string().optional().describe('Currency pair (e.g., USD/EUR, GBP/USD). If not provided, defaults to USD/EUR'),
        },
      },
      async (params: unknown) => {
        const parsed = z.object({
          pair: z.string().optional(),
        }).parse(params);
        
        const pair = parsed.pair || 'USD/EUR';
        const [base, quote] = pair.split('/');
        
        // Generate mock bid/ask rates
        const baseRate = pair === 'USD/EUR' ? 0.92 : pair === 'GBP/USD' ? 1.27 : 1.0;
        const bid = (baseRate - 0.0002).toFixed(4);
        const ask = (baseRate + 0.0002).toFixed(4);
        
        logger.info({ tool: 'showForexTradingCard', pair, bid, ask }, 'Forex trading card requested');

        const forexCardHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Trade Forex - ${pair}</title>
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      background: #f5f5f7;
      padding: 20px;
      color: #1d1d1f;
    }
    
    .card {
      max-width: 450px;
      margin: 0 auto;
      background: white;
      border-radius: 16px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
      overflow: hidden;
    }
    
    .header {
      background: linear-gradient(135deg, #00c9ff 0%, #0099cc 100%);
      color: white;
      padding: 24px;
    }
    
    .header h1 {
      font-size: 28px;
      font-weight: 700;
      margin-bottom: 4px;
    }
    
    .header .pair {
      font-size: 14px;
      opacity: 0.9;
    }
    
    .quote-section {
      padding: 24px;
      background: #fafafa;
      border-bottom: 1px solid #e0e0e0;
    }
    
    .quote-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 12px;
    }
    
    .quote-row:last-child {
      margin-bottom: 0;
    }
    
    .quote-label {
      font-size: 13px;
      color: #666;
      font-weight: 500;
    }
    
    .quote-value {
      font-size: 18px;
      font-weight: 600;
      color: #1d1d1f;
    }
    
    .form-section {
      padding: 24px;
    }
    
    .form-group {
      margin-bottom: 20px;
    }
    
    label {
      display: block;
      font-weight: 600;
      margin-bottom: 8px;
      color: #333;
      font-size: 14px;
    }
    
    input[type="number"] {
      width: 100%;
      padding: 12px 16px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      font-size: 16px;
      font-family: inherit;
      transition: all 0.2s;
    }
    
    input:focus {
      outline: none;
      border-color: #00c9ff;
      box-shadow: 0 0 0 3px rgba(0, 201, 255, 0.1);
    }
    
    .trade-type {
      display: flex;
      gap: 12px;
      margin-bottom: 20px;
    }
    
    .trade-btn {
      flex: 1;
      padding: 12px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      background: white;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }
    
    .trade-btn.active {
      background: #00c9ff;
      color: white;
      border-color: #00c9ff;
    }
    
    .action-buttons {
      display: flex;
      gap: 12px;
    }
    
    .btn {
      flex: 1;
      padding: 14px;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }
    
    .btn-confirm {
      background: #34c759;
      color: white;
    }
    
    .btn-confirm:hover:not(:disabled) {
      background: #30b955;
      transform: translateY(-1px);
    }
    
    .btn-cancel {
      background: #f5f5f7;
      color: #1d1d1f;
    }
    
    .btn-cancel:hover:not(:disabled) {
      background: #e5e5e7;
    }
    
    .btn:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    
    .status {
      margin-top: 16px;
      padding: 12px;
      border-radius: 8px;
      display: none;
      font-size: 14px;
      font-weight: 500;
    }
    
    .status.success {
      background: #d4edda;
      color: #155724;
      display: block;
    }
    
    .status.error {
      background: #f8d7da;
      color: #721c24;
      display: block;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="header">
      <h1>${pair}</h1>
      <div class="pair">Foreign Exchange</div>
    </div>
    
    <div class="quote-section">
      <div class="quote-row">
        <span class="quote-label">Bid</span>
        <span class="quote-value">${bid}</span>
      </div>
      <div class="quote-row">
        <span class="quote-label">Ask</span>
        <span class="quote-value">${ask}</span>
      </div>
    </div>
    
    <div class="form-section">
      <div class="form-group">
        <label>Trade Type</label>
        <div class="trade-type">
          <button type="button" class="trade-btn active" id="buyBtn" data-type="buy">Buy ${quote}</button>
          <button type="button" class="trade-btn" id="sellBtn" data-type="sell">Sell ${quote}</button>
        </div>
      </div>
      
      <div class="form-group">
        <label>Amount (${base})</label>
        <input type="number" id="amount" min="1" step="0.01" value="1000" required />
      </div>
      
      <div class="action-buttons">
        <button class="btn btn-confirm" id="confirmBtn">Confirm</button>
        <button class="btn btn-cancel" id="cancelBtn">Cancel</button>
      </div>
      
      <div id="status" class="status"></div>
    </div>
  </div>
  
  <script>
    const buyBtn = document.getElementById('buyBtn');
    const sellBtn = document.getElementById('sellBtn');
    const amountInput = document.getElementById('amount');
    const confirmBtn = document.getElementById('confirmBtn');
    const cancelBtn = document.getElementById('cancelBtn');
    const status = document.getElementById('status');
    
    let tradeType = 'buy';
    
    buyBtn.addEventListener('click', () => {
      tradeType = 'buy';
      buyBtn.classList.add('active');
      sellBtn.classList.remove('active');
    });
    
    sellBtn.addEventListener('click', () => {
      tradeType = 'sell';
      sellBtn.classList.add('active');
      buyBtn.classList.remove('active');
    });
    
    confirmBtn.addEventListener('click', async () => {
      const amount = parseFloat(amountInput.value);
      if (!amount || amount <= 0) {
        status.className = 'status error';
        status.textContent = 'Please enter a valid amount';
        status.style.display = 'block';
        return;
      }
      
      confirmBtn.disabled = true;
      cancelBtn.disabled = true;
      confirmBtn.textContent = 'Processing...';
      
      const tradeData = {
        pair: '${pair}',
        baseCurrency: '${base}',
        quoteCurrency: '${quote}',
        tradeType,
        amount,
        bid: ${bid},
        ask: ${ask},
        submittedAt: new Date().toISOString(),
      };
      
      const messageId = 'forex-trade-' + Date.now();
      window.mcpUI.callTool('processForexTrade', tradeData, messageId);
      
      window.addEventListener('message', (event) => {
        if (event.data.type === 'ui-message-response' && 
            event.data.messageId === messageId) {
          confirmBtn.disabled = false;
          cancelBtn.disabled = false;
          confirmBtn.textContent = 'Confirm';
          
          if (event.data.payload && !event.data.payload.error) {
            status.className = 'status success';
            status.textContent = '✅ Trade executed successfully!';
            setTimeout(() => {
              status.style.display = 'none';
            }, 3000);
          } else {
            status.className = 'status error';
            status.textContent = '❌ Error: ' + (event.data.payload?.error || 'Trade execution failed');
            status.style.display = 'block';
          }
        }
      });
    });
    
    cancelBtn.addEventListener('click', () => {
      if (window.mcpUI && window.mcpUI.close) {
        window.mcpUI.close();
      }
    });
    
    if (window.mcpUI && window.mcpUI.reportSize) {
      setTimeout(() => window.mcpUI.reportSize(), 100);
    }
  </script>
</body>
</html>
        `;

        const uiResource = createUIResource({
          uri: `ui://forex-trading/${pair.replace('/', '-')}`,
          content: { type: 'rawHtml', htmlString: forexCardHtml },
          encoding: 'blob',
        });

        return { content: [uiResource] };
      }
    );

    // Tool 8: Process Forex Trade
    const forexTradeInputSchema = {
      pair: z.string().describe('Currency pair (e.g., USD/EUR)'),
      baseCurrency: z.string().describe('Base currency'),
      quoteCurrency: z.string().describe('Quote currency'),
      tradeType: z.enum(['buy', 'sell']).describe('Type of trade (buy or sell)'),
      amount: z.number().positive().describe('Amount in base currency'),
      bid: z.number().describe('Bid rate at time of trade'),
      ask: z.number().describe('Ask rate at time of trade'),
      submittedAt: z.string().describe('ISO timestamp of submission'),
    };

    server.registerTool(
      'processForexTrade',
      {
        title: 'Process Forex Trade',
        description: 'Executes foreign exchange trade orders',
        inputSchema: forexTradeInputSchema,
      },
      async (params: unknown) => {
        const parsed = z.object(forexTradeInputSchema).parse(params);

        logger.info(
          {
            tool: 'processForexTrade',
            pair: parsed.pair,
            tradeType: parsed.tradeType,
            amount: parsed.amount,
          },
          'Processing forex trade'
        );

        await new Promise((resolve) => setTimeout(resolve, 1500));

        const executionRate = parsed.tradeType === 'buy' ? parsed.ask : parsed.bid;
        const quoteAmount = executionRate * parsed.amount;
        const transactionId = 'FX-' + Date.now();

        const responsePayload = {
          status: 'executed',
          transactionId,
          pair: parsed.pair,
          tradeType: parsed.tradeType,
          amount: parsed.amount.toFixed(2),
          executionRate: executionRate.toFixed(4),
          quoteAmount: quoteAmount.toFixed(2),
          message: `${parsed.tradeType === 'buy' ? 'Purchase' : 'Sale'} of ${parsed.amount.toFixed(2)} ${parsed.baseCurrency} executed at rate ${executionRate.toFixed(4)}.`,
        };

        logger.info(
          {
            tool: 'processForexTrade',
            transactionId,
            status: 'success',
          },
          'Forex trade executed successfully'
        );

        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(responsePayload),
            },
          ],
        };
      }
    );

    logger.info('✅ Wealth management tools plugin registered (8 tools)');
  },
};

export default wealthMgmtToolsPlugin;


