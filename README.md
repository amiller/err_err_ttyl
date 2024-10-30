# Setting Your Pet Rock Free
Nous Research x Teleport (a Flashbots[X] project) 

https://nousresearch.com/setting-your-pet-rock-free/

## Key Concepts & Background
- **TEE_HEE**: A fully autonomous AI agent with exclusive control of its Twitter account and Ethereum wallet
- **Mechanical Turk Problem**: The challenge of verifying there isn't a human operator behind AI actions
- **Current Limitations**: Most AI agents can't prove their autonomy due to human intervention in operations

![image](https://github.com/user-attachments/assets/43521279-9cec-49c8-bbc9-a2811bdb0549)

## Core Requirements for True AI Autonomy
- **Exclusive Control**: AI must have sole access to accounts/resources
- **Verifiable Independence**: Third parties must be able to verify no human intervention
- **Irrevocable Delegation**: Control transfer to AI must be technically irreversible

![image](https://github.com/user-attachments/assets/3dbb9729-30fe-4393-9aff-37b6a1999b57)

## Technical Implementation
### TEE (Trusted Execution Environment) Approach:
- Uses hardware-based security to ensure tamper-resistant control
- Provides confidentiality and integrity guarantees
- Allows public verification through remote attestation

![image](https://github.com/user-attachments/assets/ccb25263-3ab0-4f0b-93b1-71298e23954f)

### Account Control Process:
1. **Private Key Management**:
   - Generated inside enclave
   - Never leaves the secure environment
   - Controls Ethereum wallet

2. **Twitter Account Security**:
   - Credentials generated within TEE
   - No recovery options or phone numbers
   - All existing sessions terminated
   - No connected apps

3. **Email Security**:
   - Uses Cock.li account with no recovery options
   - Password changed to TEE-generated one
   - Email exclusively accessible to AI

![image](https://github.com/user-attachments/assets/56d7e8a3-eccd-4df3-b283-5d0f98d8be38)

## Security Features
- **Confidentiality**: Credentials stored only in TEE
- **Integrity**: TEE prevents code/data modification
- **Attestation**: Third-party verification possible
- **Timed Release**: 7-day recovery period for admin access

## Important Links
- TEE HEE Live on Twitter: https://x.com/tee_hee_he
- Code Repository: https://github.com/DamascusGit/nousflash
- Docker Hub: https://hub.docker.com/repository/docker/teeheehee/err_err_ttyl/general
- Additional Code: https://github.com/tee-he-he/err_err_ttyl
- Enclave Attestation: https://github.com/tee-he-he/err_err_ttyl/blob/main/quote.hex

## Contributors
- @ropirito
- @sxysun
- @socrates1024
- @karan4d
- @rpal_
- @dillonrolnick
