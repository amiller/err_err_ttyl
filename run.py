from flask import Flask, jsonify, request
import subprocess
import requests
import sys
import os
import time
from eth_keys import keys
import psutil

app = Flask(__name__)

# Track a single instance of the bot with start/stop
bot_proc = None

SECURE_FILE = os.environ['SECURE_FILE']

# Process a .env file
def load_dotenv(data):
    env_data = data.decode('utf-8')
    config = {}
    for line in env_data.splitlines():
        line = line.strip()
        if line.startswith('#'): continue
        if not '=' in line: continue
        key, value = line.split('=', 1)
        config[key.strip()] = value.strip()
    return config

# Set the wallet get
@app.route('/bootstrap', methods=['POST'])
def bootstrap():
    os.environ['AGENT_WALLET_PRIVATE_KEY'] = os.urandom(32).hex()
    return "OK", 200

@app.route('/upload', methods=['POST'])
def upload_files():
    file1 = request.files.get('defaultCharacter.ts')
    file2 = request.files.get('prompts.ts')
    open('/app/packages/core/src/defaultCharacter.ts','wb').write(file1.read())
    open('/app/packages/core/src/prompts.ts','wb').write(file2.read())
    return "OK", 200
    

# Pass API keys and other arguments from the host
@app.route('/configure', methods=['POST'])
def configure():
    config = load_dotenv(request.data)

    print('Received configuration parameters:', config.keys(),
          file=sys.stderr)
    params = [
        'AZURE_BLOB_CONNECTION_STRING',
        'DISCORD_APPLICATION_ID',
        'DISCORD_API_TOKEN',
        'OPENAI_API_KEY',
        'REDPILL_API_KEY',
        'GROQ_API_KEY',
        'OPENROUTER_API_KEY',
        'GOOGLE_GENERATIVE_AI_API_KEY',
        'HYPERBOLIC_API_KEY',
        'ELEVENLABS_XI_API_KEY',
        'ELEVENLABS_MODEL_ID',
        'ELEVENLABS_VOICE_ID',
        'ELEVENLABS_VOICE_STABILITY',
        'ELEVENLABS_VOICE_SIMILARITY_BOOST',
        'ELEVENLABS_VOICE_STYLE',
        'ELEVENLABS_VOICE_USE_SPEAKER_BOOST',
        'ELEVENLABS_OPTIMIZE_STREAMING_LATENCY',
        'ELEVENLABS_OUTPUT_FORMAT',
        'TWITTER_DRY_RUN',
        'X_PASSWORD',
        'X_EMAIL',
        'X_AUTH_TOKENS',
        'X_SERVER_URL',
        'XAI_API_KEY',
        'XAI_MODEL',
        'USE_OPENAI_EMBEDDING',
        'OPENROUTER_MODEL',
        'SMALL_OPENROUTER_MODEL',
        'MEDIUM_OLLAMA_MODEL',
        'LARGE_OLLAMA_MODEL',
        'HYPERBOLIC_BASE_PROMPT',
        'HYPERBOLIC_REPLY_PROMPT',
        'AGENT_WALLET_PRIVATE_KEY',
        'ANTHROPIC_API_KEY',
        'GLIF_API_KEY',
        'BIRDEYE_API_KEY',
        'SOL_ADDRESS',
        'SLIPPAGE',
        'BASE_MINT',
        'RPC_URL',
        'HELIUS_API_KEY',
        'TELEGRAM_BOT_TOKEN',
        'TOGETHER_API_KEY',
        'SERVER_PORT',
        'LOG_INTERVAL'
    ]
    for p in params:
        os.environ[p] = config[p]
    return "Configuration OK", 200

# Called by untrusted host to refresh the auth credentials
@app.route('/refresh', methods=['POST'])
def refresh():
    result = subprocess.check_output("bash refresh.sh", shell=True, stderr=sys.stderr, env=os.environ.copy())
    load()
    return "OK", 200

# Called by untrusted host to store the credentials
@app.route('/save', methods=['POST'])
def save():
    # May be called by host
    ip_address = request.remote_addr

    with open(SECURE_FILE,'w') as f:
        for k in ['X_AUTH_TOKENS',
                  'X_ACCESS_TOKEN',
                  'X_ACCESS_TOKEN_SECRET',
                  'AGENT_WALLET_PRIVATE_KEY',
                  'X_PASSWORD',
                  'PROTONMAIL_PASSWORD']:
            f.write(f"{k}={os.environ[k]}\n")
    return "Wrote save file", 200

# Called by untrusted host to store the credentials
@app.route('/load', methods=['POST'])
def load():
    # May be called by host
    ip_address = request.remote_addr
    config = load_dotenv(open(SECURE_FILE,'rb').read())
    os.environ['X_ACCESS_TOKEN'] = config['X_ACCESS_TOKEN']
    os.environ['X_ACCESS_TOKEN_SECRET'] = config['X_ACCESS_TOKEN_SECRET']
    os.environ['X_AUTH_TOKENS'] = config['X_AUTH_TOKENS'].replace('\\"','"')
    os.environ['X_PASSWORD'] = config['X_PASSWORD']
    os.environ['AGENT_WALLET_PRIVATE_KEY'] = config['AGENT_WALLET_PRIVATE_KEY']
    os.environ['PROTONMAIL_PASSWORD'] = config['PROTONMAIL_PASSWORD']
    return "Loaded save file", 200

# Called by other trusted modules to do EVM-friendly attestation
@app.route('/start_bot', methods=['POST'])
def start_bot():
    ip_address = request.remote_addr
    global bot_proc
    if bot_proc:
        return "Already running", 400
    #bot_proc = subprocess.Popen("python3 run_pipeline.py", shell=True, stderr=sys.stderr, env=os.environ.copy(), cwd='./agent/')
    private_key_hex = os.environ['AGENT_WALLET_PRIVATE_KEY']
    private_key = keys.PrivateKey(bytes.fromhex(private_key_hex))
    address = private_key.public_key.to_checksum_address()
    print(address)
    os.environ['WALLET_PRIVATE_KEY'] = os.environ['AGENT_WALLET_PRIVATE_KEY']
    os.environ['WALLET_PUBLIC_KEY'] = address
    os.environ['AGENT_WALLET_ADDRESS'] = address
    os.environ['TWITTER_USERNAME'] = os.environ['X_USERNAME']
    os.environ['TWITTER_PASSWORD'] = os.environ['X_PASSWORD']
    os.environ['TWITTER_EMAIL'] = os.environ['X_EMAIL']
    os.environ['TWITTER_COOKIES'] = os.environ['X_AUTH_TOKENS']

    print('address:', address, file=sys.stderr)
    # print('X_AUTH_TOKENS', os.environ['X_AUTH_TOKENS'], file=sys.stderr)
    bot_proc = subprocess.Popen("pnpm start", shell=True, stderr=sys.stderr, env=os.environ.copy(), cwd="/app")
    return "OK", 200

@app.route('/stop_bot', methods=['POST'])
def stop_bot():
    ip_address = request.remote_addr
    global bot_proc
    for proc in psutil.Process(bot_proc.pid).children(recursive=True):
        proc.terminate()
        proc.wait()
    psutil.Process(bot_proc.pid).terminate()
    bot_proc.wait()
    bot_proc = None
    return "OK", 200

@app.route('/status', methods=['GET'])
def status():
    ip_address = request.remote_addr
    return ip_address, 200

@app.route('/encumber', methods=['POST'])
def encumber():
    ip_address = request.remote_addr
    X_PASSWORD = subprocess.check_output("python3 scripts/twitter.py", shell=True, env=os.environ.copy()).decode('utf-8').strip()
    # print(X_PASSWORD, file=sys.stderr)
    os.environ['X_PASSWORD'] = X_PASSWORD
    save()
    return "Encumbered account", 200


# Wrappers for replicatoor
# TODO: handle authentication
@app.route('/replicatoor/<path:subpath>', methods=['GET', 'POST']) 
def replicatoor_proxy(subpath):
    # TODO: generalize
    url = f"http://replicatoor:4001/{subpath}"
    # Forward all request data exactly as received
    resp = requests.request(
        method=request.method,
        url=url,
        headers={k:v for k,v in request.headers if k != 'Host'},
        data=request.get_data(),
        cookies=request.cookies,
        allow_redirects=False
    )
    return resp.content, resp.status_code

@app.errorhandler(404)
def not_found(e):
    return "Not Found", 404

if __name__ == '__main__':
    time.sleep(1)
    port = 5001
    if len(sys.argv) == 2:
        port = int(sys.argv[1])
    app.run(host='0.0.0.0', port=port)
