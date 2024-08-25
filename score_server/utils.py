import hmac
import hashlib

def generate_hmac(data, secret_key):
    # Generate HMAC using SHA-256
    h = hmac.new(secret_key.encode(), data.encode(), hashlib.sha256)
    return h.hexdigest()

def verify_hmac(data, secret_key, hmac_to_verify):
    # Generate HMAC for verification
    expected_hmac = generate_hmac(data, secret_key)
    # Compare the HMACs securely
    return hmac.compare_digest(expected_hmac, hmac_to_verify)
    