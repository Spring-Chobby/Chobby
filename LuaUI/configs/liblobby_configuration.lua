local onZKServer = false

return {
	server = {
		serverAddress = (onZKServer and "zero-k.info") or "springrts.com",
		serverName = (onZKServer and "Zero-K") or "Spring",
		ZKServer = onZKServer,
	}
}