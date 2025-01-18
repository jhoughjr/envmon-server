const WebSocket = require("ws");

class WSConnectionManager {
  constructor() {
    this.connections = new Set();
  }

  initialize(server) {
    this.wss = new WebSocket.Server({ server });
    
    this.wss.on("connection", (ws) => {
      this.connections.add(ws);
      
      ws.on("close", () => {
        this.connections.delete(ws);
      });
    });
  }

  broadcast(data) {
    this.connections.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify(data));
      }
    });
  }
}

module.exports = new WSConnectionManager();
