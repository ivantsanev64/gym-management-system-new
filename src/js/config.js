// Feature flags for progressive rollout
const FEATURE_FLAGS = {
  AI_RECOMMENDATIONS: true,
  FACE_CHECKIN: false,
  ADVANCED_ANALYTICS: false,
  PAYMENT_GATEWAY: false
};

// Check if feature is enabled
function isFeatureEnabled(featureName) {
  return FEATURE_FLAGS[featureName] === true;
}