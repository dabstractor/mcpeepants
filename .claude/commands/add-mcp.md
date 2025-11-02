
Do a full web search and deep dive on the mcp listed in this prompt. Spawn multiple agents to do deep research on github issues, reddit, forum posts, twitter, etc. into its honest strengths, weakness, true use cases, common pitfalls and specific basic usage examples from the official documentation. Compile the information you need to match the following example format:

```

  "database-connector": {
    "config": {
      "command": "npx",
      "args": [
        "your-db-connector-package@latest"
      ],
      "env": {
        "DB_CONNECTION_STRING": "$DB_CONNECTION_STRING",
        "TIMEOUT_SECONDS": "30"
      }
    },
    "description": "Provides secure database access and query execution capabilities through MCP for various database systems.",
    "keywords": [
      "database",
      "sql",
      "query",
      "data-access",
      "connectivity"
    ],
    "useCases": [
      "Executing parameterized SQL queries and returning structured results.",
      "Validating database schema and providing metadata introspection.",
      "Performing data migrations or bulk operations across multiple tables."
    ],
    "notGoodFor": [
      "File system operations (use desktop-commander instead).",
      "Real-time data streaming or pub/sub patterns.",
      "Large-scale data warehousing without proper connection pooling."
    ],
    "limitations": [
      "Requires database credentials to be configured securely.",
      "Query performance depends on database optimization and indexes.",
      "Connection limits may be reached under high concurrent usage."
    ],
    "examplePrompt": "Query the users table to find all active accounts created in the last 30 days and return their email addresses."
  }

  "messaging-service": {
    "config": {
      "type": "stdio",
      "command": "node",
      "args": [
        "./messaging-server.js"
      ],
      "env": {
        "SLACK_BOT_TOKEN": "$SLACK_BOT_TOKEN",
        "DISCORD_WEBHOOK_URL": "$DISCORD_WEBHOOK_URL"
      }
    },
    "description": "Enables sending and receiving messages through various messaging platforms with structured content and attachments.",
    "keywords": [
      "messaging",
      "notifications",
      "slack",
      "discord",
      "communication"
    ],
    "useCases": [
      "Sending formatted notifications or alerts to channels.",
      "Retrieving message history and performing sentiment analysis.",
      "Automating status updates or deployment notifications."
    ],
    "notGoodFor": [
      "Direct browser automation (use Playwright instead).",
      "File system access or local machine operations.",
      "Real-time chat applications requiring low-latency responses."
    ],
    "limitations": [
      "Rate limiting may restrict high-frequency message sending.",
      "Platform-specific APIs may limit available functionality.",
      "Authentication tokens require secure storage and rotation."
    ],
    "examplePrompt": "Send a deployment notification to the #devops channel with the build number and deployment status."
  }
```

Once the information gathering is complete, add the mcp server information to the list in servers.json.

Check if any of the other servers have a similar use case and alert the user if so.
