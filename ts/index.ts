import { Contract, getBytes, Interface, JsonRpcProvider, toBeHex, Wallet, type ContractRunner } from 'ethers'
import { AltoBundler } from './bundler'
import { ENTRY_POINT_V07, sendop, type Execution } from './sendop'

const chainId = '11155111'
const CLIENT_URL = 'http://localhost:8545'
const BUNDLER_URL = 'http://localhost:4337'

const client = new JsonRpcProvider(CLIENT_URL)

const PRIVATE_KEY = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
const signer = new Wallet(PRIVATE_KEY, client)

// *********************************************************
// ***************** Demo contract address *****************
// *********************************************************
const DEMO_ADDRESS = '0x227885f666bdE85b1D9DAB632f6Ff470d6d8be6E'

console.log('Sending user operation...')
const op = await sendop({
	bundler: new AltoBundler(chainId, BUNDLER_URL),
	executions: [
		{
			to: DEMO_ADDRESS,
			data: new Interface(['function setCaller()']).encodeFunctionData('setCaller', []),
			value: '0x0',
		},
	],
	opGetter: {
		getSender() {
			return DEMO_ADDRESS
		},
		async getNonce() {
			const nonceKey = 0
			const nonce: bigint = await getEntryPointContract(client).getNonce(DEMO_ADDRESS, nonceKey)
			return toBeHex(nonce)
		},
		getCallData(executions: Execution[]) {
			return executions[0].data
		},
		async getDummySignature() {
			return '0xfffffffffffffffffffffffffffffff0000000000000000000000000000000007aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1c'
		},
		async getSignature(userOpHash: string) {
			return await signer.signMessage(getBytes(userOpHash))
		},
	},
})

console.log('Waiting for receipt...')
await op.wait()

const demo = new Contract(DEMO_ADDRESS, new Interface(['function caller() view returns (address)']), client)
console.log('caller', await demo.caller())

function getEntryPointContract(runner: ContractRunner) {
	return new Contract(
		ENTRY_POINT_V07,
		[
			'function getUserOpHash(tuple(address sender, uint256 nonce, bytes initCode, bytes callData, bytes32 accountGasLimits, uint256 preVerificationGas, bytes32 gasFees, bytes paymasterAndData, bytes signature) userOp) external view returns (bytes32)',
			'function getNonce(address sender, uint192 key) external view returns (uint256 nonce)',
			'function handleOps(tuple(address sender, uint256 nonce, bytes initCode, bytes callData, bytes32 accountGasLimits, uint256 preVerificationGas, bytes32 gasFees, bytes paymasterAndData, bytes signature)[] ops, address payable beneficiary) external',
			'function depositTo(address account)',
			'function balanceOf(address account) public view returns (uint256)',
		],
		runner,
	)
}
