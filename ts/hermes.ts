import { parseAbiParameters } from 'abitype'
import { type Hex, encodeAbiParameters } from 'viem'
import { HERMES_URLS } from './config'
import { tickers } from './config'
import { error } from './ffi'
import { type Pyth, formatPrice, isPythID, isPythTicker } from './types'

const hermes = {
  pricesV2: (ids: Pyth.ID[]) =>
    fetchHermes<Pyth.V2Response>(`/v2/updates/price/latest?ids[]=${ids.join('&ids[]=')}&binary=true`),
}

export async function fetchPythData(items: string[]) {
  const pythIds = items
    .map(item => {
      return isPythTicker(item) ? tickers[item] : item
    })
    .filter(isPythID)

  if (!pythIds.length) {
    error(`No valid Pyth IDs found: ${items.join(', ')}`)
  }

  const result = await hermes.pricesV2(pythIds)

  const payloads = result.binary.data.map<Hex>(d => `0x${d}`)
  const pythAssets = result.parsed.map(({ id, price, ema_price }) => ({
    id: `0x${id}` as const,
    price: formatPrice(price),
    emaPrice: formatPrice(ema_price),
  }))

  return encodeAbiParameters(pythPayloads, [payloads, pythAssets])
}

export const pythPayloads = parseAbiParameters([
  'bytes[] payload, PriceFeed[] assets',
  'struct PriceFeed { bytes32 id; Price price; Price emaPrice; }',
  'struct Price { int64 price; uint64 conf; int32 expo; uint256 publishTime; }',
])

async function fetchHermes<T = any>(endpoint: string, init?: RequestInit) {
  for (const baseUrl of HERMES_URLS) {
    try {
      const response = await fetch(baseUrl + endpoint, init)
      return (await response.json()) as T
    } catch (e: any) {
      console.info('Failed to fetch from: ', baseUrl + endpoint, 'Error:', e)
    }
  }
  throw new Error(`Failed to fetch from all ${HERMES_URLS.length} endpoints`)
}
