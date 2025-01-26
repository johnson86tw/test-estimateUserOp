import { ENTRY_POINT_V07 } from './sendop'
import type { UserOp, UserOpReceipt } from './sendop'
import type { Bundler } from './sendop'

export class AltoBundler implements Bundler {
	chainId: string
	url: string
	bundler: RpcProvider

	constructor(chainId: string, url: string) {
		// TODO: check if the bundler url is valid
		this.chainId = chainId
		this.url = url
		this.bundler = new RpcProvider(url)
	}

	async getGasValues(userOp: UserOp) {
		// Get gas price
		const curGasPrice = await this.bundler.send({ method: 'pimlico_getUserOperationGasPrice' })
		if (!curGasPrice?.standard?.maxFeePerGas) {
			throw new Error('Invalid gas price response from bundler')
		}

		// Set and estimate gas
		userOp.maxFeePerGas = curGasPrice.standard.maxFeePerGas
		const estimateGas = await this.bundler.send({
			method: 'eth_estimateUserOperationGas',
			params: [userOp, ENTRY_POINT_V07],
		})
		if (!estimateGas) {
			throw new Error('Empty response from gas estimation')
		}

		// Validate estimation results
		const requiredFields = ['preVerificationGas', 'verificationGasLimit', 'callGasLimit']
		for (const field of requiredFields) {
			if (!(field in estimateGas)) {
				throw new Error(`Missing required gas estimation field: ${field}`)
			}
		}

		return {
			maxFeePerGas: userOp.maxFeePerGas,
			maxPriorityFeePerGas: curGasPrice.standard.maxPriorityFeePerGas,
			preVerificationGas: estimateGas.preVerificationGas,
			verificationGasLimit: estimateGas.verificationGasLimit,
			callGasLimit: estimateGas.callGasLimit,
			paymasterVerificationGasLimit: estimateGas.paymasterVerificationGasLimit,
			paymasterPostOpGasLimit: estimateGas.paymasterPostOpGasLimit,
		}
	}

	async sendUserOperation(userOp: UserOp): Promise<string> {
		return await this.bundler.send({
			method: 'eth_sendUserOperation',
			params: [userOp, ENTRY_POINT_V07],
		})
	}

	async getUserOperationReceipt(hash: string): Promise<UserOpReceipt> {
		return await this.bundler.send({ method: 'eth_getUserOperationReceipt', params: [hash] })
	}
}

export type RpcRequestArguments = {
	readonly method: string
	readonly params?: readonly unknown[] | object
}
export class RpcProvider {
	readonly url: string

	constructor(url: string) {
		this.url = url
	}

	async send(request: RpcRequestArguments) {
		console.log('Sending request:', request)

		const response = await fetch(this.url, {
			method: 'post',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({
				jsonrpc: '2.0',
				method: request.method,
				id: 1,
				params: request.params,
			}),
		})

		const data = await response.json()
		if (data.error) {
			const errorMessage = data.error.code
				? `JSON-RPC Error: ${request.method} (${data.error.code}): ${data.error.message}`
				: `JSON-RPC Error: ${request.method}: ${data.error.message}`
			throw new Error(errorMessage)
		}

		if (!response.ok) {
			const errorText = await response.text()
			throw new Error(`HTTP error! status: ${response.status}, message: ${errorText}`)
		}

		return data.result
	}
}
