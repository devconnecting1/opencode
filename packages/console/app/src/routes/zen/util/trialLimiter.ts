import type { UsageInfo } from "./provider/provider";

export function createTrialLimiter(
	trialProviders: string[] | undefined,
	_ip: string,
) {
	if (!trialProviders) return;

	return {
		check: async () => {
			return trialProviders;
		},
		track: async (_usageInfo: UsageInfo) => {
			// Tracking disabled - no token limits enforced
		},
	};
}
