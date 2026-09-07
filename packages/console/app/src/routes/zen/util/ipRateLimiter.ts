import { logger } from "./logger";

export function createRateLimiter(
	_modelId: string,
	_rateLimit: number | undefined,
	_rawIp: string,
	_request: Request,
) {
	return {
		check: async () => {
			logger.debug(`rate limit bypassed - no IP restrictions applied`);
		},
		track: async () => {
			// Tracking disabled - no IP rate limits enforced
		},
	};
}
